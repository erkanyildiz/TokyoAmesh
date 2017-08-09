// erkanyildiz
// 20170519-1549+0900
//
// EYUtils.m

#import "EYUtils.h"
#import <objc/runtime.h>
#include <CommonCrypto/CommonDigest.h>

NSString* JSONFromObject(id object)
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    if(error){ NSLog(@"Can not create JSON from object:\n%@", error); }
    return [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
}


void afterDelay(NSTimeInterval delay, void(^block)(void))
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}


void onMainThread(void(^block)(void))
{
    dispatch_async(dispatch_get_main_queue(), block);
}



#pragma mark -
@implementation NSObject (EYUtils)
- (void)dump
{
    NSLog(@"%@", [self description]);
}


- (void)dumpWith:(NSString *)logText
{
    NSLog(@"%@: %@", logText, [self description]);
}
@end



#pragma mark -
@implementation NSString (EYUtils)

+ (NSString *)randomStringWithLength:(NSUInteger)length
{
    NSMutableString* random = [NSMutableString stringWithCapacity:length];

    for (NSUInteger i=0; i<length; i++)
    {
        char c = '0' + (unichar)arc4random()%36;
        if(c > '9') c += ('a'-'9'-1);
        [random appendFormat:@"%c", c];
    }

    return random;
}

#pragma mark Encryption

- (NSString *)stringByEncryptingWithKey:(NSString *)key
{
    NSData* rawData = [self dataUsingEncoding:NSUTF8StringEncoding];
    const char* rawBytes = rawData.bytes;
    NSUInteger keyLength = key.length;
    NSMutableData* encData = NSMutableData.data;

    for (int i = 0; i < rawData.length; i++)
    {
        NSUInteger keyIndex = i % keyLength;
        char encChar = rawBytes[i] ^ [key characterAtIndex:keyIndex];
        [encData appendBytes:&encChar length:1];
    }

    return [encData base64EncodedStringWithOptions:0];
}


- (NSString *)stringByDecryptingWithKey:(NSString *)key
{
    NSData* encData = [NSData.alloc initWithBase64EncodedString:self options:0];
    const char* encBytes = encData.bytes;
    NSUInteger keyLength = key.length;
    NSMutableData* rawData = NSMutableData.data;

    for (int i = 0; i < encData.length; i++)
    {
        NSUInteger keyIndex = i % keyLength;
        char encChar = encBytes[i] ^ [key characterAtIndex:keyIndex];
        [rawData appendBytes:&encChar length:1];
    }

    return [NSString.alloc initWithData:rawData encoding:NSUTF8StringEncoding];
}

#pragma mark Hashing

- (NSString *)SHA256
{
    const char* s = [self UTF8String];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(s, (CC_LONG)strlen(s), digest);

    NSMutableString *hash = NSMutableString.new;
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02x", digest[i]];

    return hash;
}


- (NSString *)MD5
{
    const char *s = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(s, (CC_LONG)strlen(s), digest);

    NSMutableString *hash = NSMutableString.new;
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02x", digest[i]];

    return hash;
}

#pragma mark Network Operations

- (NSURL *)URL
{
    return [NSURL URLWithString:self];
}


- (NSURLRequest *)request
{
    return [NSURLRequest requestWithURL:[self URL]];
}
@end



#pragma mark -
@implementation NSURLRequest (EYUtils)

- (void)fetchJSON:(void (^)(id JSONResponse, NSError* error))handler
{
    NSURLSessionTask* task = [NSURLSession.sharedSession dataTaskWithRequest:self completionHandler:^(NSData* data, NSURLResponse* response, NSError* error)
    {
        if(error)
        {
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
            userInfo[@"response"] = response;
            NSError* errorWithResponse = [NSError.alloc initWithDomain:error.domain code:error.code userInfo:userInfo];

            onMainThread(^
            {
                handler(nil, errorWithResponse);
            });
        }
        else
        {
            NSError* jsonError = nil;
            id JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

            onMainThread(^
            {
                if(jsonError)
                {
                     handler(nil, jsonError);
                }
                else
                {
                     handler(JSON, nil);
                }
            });
        }
    }];

    [task resume];
}


- (void)fetchImage:(void (^)(UIImage* image, NSError* error))handler
{
    NSURLSessionTask* task = [NSURLSession.sharedSession dataTaskWithRequest:self completionHandler:^(NSData* data, NSURLResponse* response, NSError* error)
    {
        if(error)
        {
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
            userInfo[@"response"] = response;
            NSError* errorWithResponse = [NSError.alloc initWithDomain:error.domain code:error.code userInfo:userInfo];

            onMainThread(^
            {
                handler(nil, errorWithResponse);
            });
        }
        else
        {
            UIImage* image = [UIImage imageWithData:data];

            onMainThread(^
            {
                if(image)
                {
                    handler(image, nil);
                }
                else
                {
                    handler(nil, [NSError errorWithDomain:@"EYUtilsRequestImageError" code:1000 userInfo:@{@"Description:":@"Invalid image data"}]);
                }
            });
        }
    }];

    [task resume];
}


- (void)fetchData:(void (^)(NSData* data, NSError* error))handler
{
    NSURLSessionTask* task = [NSURLSession.sharedSession dataTaskWithRequest:self completionHandler:^(NSData* data, NSURLResponse* response, NSError* error)
    {
        if(error)
        {
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
            userInfo[@"response"] = response;
            NSError* errorWithResponse = [NSError.alloc initWithDomain:error.domain code:error.code userInfo:userInfo];
        
            onMainThread(^
            {
                handler(nil, errorWithResponse);
            });
        }
        else
        {
            onMainThread(^
            {
                handler(data, nil);
            });
        }
    }];

    [task resume];
}
@end



#pragma mark -
@implementation NSURL (EYUtils)
- (NSURL *)URLByAddingQueryParameters:(NSDictionary *)parameters
{
    if (!parameters)
        return self;

    NSURLComponents* components = [NSURLComponents.alloc initWithURL:self resolvingAgainstBaseURL:NO];
    NSMutableArray* queryItems = components.queryItems ? components.queryItems.mutableCopy : @[].mutableCopy;

    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL* stop)
    {
        NSURLQueryItem* queryItem = [NSURLQueryItem.alloc initWithName:key value:value];
        [queryItems addObject:queryItem];
    }];

    [components setQueryItems:queryItems];

    return [components URL];
}
@end



#pragma mark -
@implementation NSArray (EYUtils)
- (NSString *)JSON
{
    return JSONFromObject(self);
}
@end



#pragma mark -
@implementation NSDictionary (EYUtils)
- (NSString *)JSON
{
    return JSONFromObject(self);
}
@end



#pragma mark -
@implementation UIButton (EYUtils)
static char tapBlockAssocKey;

- (void)addTapBlock:(void (^)(id sender)) tapBlock
{
    objc_setAssociatedObject(self, &tapBlockAssocKey, tapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)onClick:(id)sender
{
    void(^tapBlock)(id sender) = objc_getAssociatedObject(self, &tapBlockAssocKey);
    if(tapBlock) tapBlock(sender);
}
@end



#pragma mark -
@implementation UIColor (EYUtils)
- (UIColor *)colorByMixingWithColor:(UIColor *)color atRatio:(CGFloat)ratio
{
    CGFloat oR, oG, oB, oA;
    [self getRed:&oR green:&oG blue:&oB alpha:&oA];

    CGFloat cR, cG, cB, cA;
    [color getRed:&cR green:&cG blue:&cB alpha:&cA];

    CGFloat dR = cR - oR;
    CGFloat dG = cG - oG;
    CGFloat dB = cB - oB;
    CGFloat dA = cA - oA;

    CGFloat r = MAX(MIN(ratio, 1.0),0.0);

    return [UIColor colorWithRed:oR + dR * r green:oG + dG * r blue:oB + dB * r alpha:oA + dA * r];
}


+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    unsigned hexInt = 0;
    [[NSScanner scannerWithString:hexString] scanHexInt:&hexInt];
    return RGB((hexInt & 0xFF0000) >> 16, (hexInt & 0x00FF00) >> 8, (hexInt & 0x0000FF));
}
@end



#pragma mark -
@implementation UIImage (EYUtils)
- (UIImage *)imageByCombiningWithImage:(UIImage *)upperImage
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    [self drawAtPoint:CGPointZero];
    CGPoint p = (CGPoint){0.5 * (self.size.width - upperImage.size.width), 0.5 * (self.size.height - upperImage.size.height)};
    [upperImage drawAtPoint:p];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}


+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = (CGRect){0.0f, 0.0f, size.width, size.height};
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}
@end



#pragma mark -
@implementation UIViewController (EYUtils)
+ (instancetype)createFromXIB
{
    NSString* fileName = NSStringFromClass(self.class);
    if([NSBundle.mainBundle pathForResource:fileName ofType:@"nib"])
        return [self.alloc initWithNibName:fileName bundle:nil];
    
    return [self.alloc init];
}
@end



#pragma mark -
@implementation NSMutableData (EYUtils)
- (void)appendString:(NSString *)string
{
    [self appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}
@end



#pragma mark -
@implementation UIView (EYUtils)

#pragma mark Positioning
- (void)moveRight:(CGFloat)value
{
    CGPoint p = self.center;
    p.x += value;
    self.center = p;
}


- (void)moveLeft:(CGFloat)value
{
    CGPoint p = self.center;
    p.x -= value;
    self.center = p;
}


- (void)moveUp:(CGFloat)value
{
    CGPoint p = self.center;
    p.y -= value;
    self.center = p;
}


- (void)moveDown:(CGFloat)value
{
    CGPoint p = self.center;
    p.y += value;
    self.center = p;
}

#pragma mark ---

- (void)centerInSuperView
{
    self.center = (CGPoint){0.5 * self.superview.bounds.size.width, 0.5 * self.superview.bounds.size.height};
}


- (void)centerRightInSuperView
{
    [self centerInSuperView];
    [self stickToRightInSuperView];
}


- (void)centerLeftInSuperView
{
    [self centerInSuperView];
    [self stickToLeftInSuperView];
}

- (void)centerTopInSuperView
{
    [self centerInSuperView];
    [self stickToTopInSuperView];
}


- (void)centerBottomInSuperView
{
    [self centerInSuperView];
    [self stickToBottomInSuperView];
}

#pragma mark ---

- (void)stickToRightInSuperView
{
    [self setOriginX:self.superview.bounds.size.width - self.bounds.size.width];
}


- (void)stickToLeftInSuperView
{
    [self setOriginX:0.0];
}


- (void)stickToTopInSuperView
{
    [self setOriginY:0.0];
}


- (void)stickToBottomInSuperView
{
    [self setOriginY:self.superview.bounds.size.height - self.bounds.size.height];
}

#pragma mark ---

- (void)setCenterX:(CGFloat)value
{
    self.center = (CGPoint){value, self.center.y};
}


- (void)setCenterY:(CGFloat)value
{
    self.center = (CGPoint){self.center.x, value};
}


- (void)setOriginX:(CGFloat)value
{
    CGRect r = self.frame;
    r.origin.x = value;
    self.frame = r;
}


- (void)setOriginY:(CGFloat)value
{
    CGRect r = self.frame;
    r.origin.y = value;
    self.frame = r;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect r = self.frame;
    r.origin = origin;
    self.frame = r;
}

#pragma mark Resizing

- (void)setHeight:(CGFloat)value
{
    CGRect r = self.frame;
    r.size.height = value;
    self.frame = r ;
}


- (void)setWidth:(CGFloat)value
{
    CGRect r = self.frame;
    r.size.width = value;
    self.frame = r;
}


- (void)expandRight:(CGFloat)value
{
    CGFloat newValue = self.bounds.size.width + value;
    [self setWidth:newValue];
}


- (void)expandLeft:(CGFloat)value
{
    [self moveLeft:value];

    [self expandRight:value];
}


- (void)expandUp:(CGFloat)value
{
    [self moveUp:value];

    [self expandDown:value];
}


- (void)expandDown:(CGFloat)value
{
    CGFloat newValue = self.bounds.size.height + value;
    [self setHeight:newValue];
}

#pragma mark Bordering

- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth
{
    CALayer* border = CALayer.layer;
    border.backgroundColor = color.CGColor;
    border.frame = (CGRect){0.0, 0.0, self.frame.size.width, borderWidth};
    [self.layer addSublayer:border];
}


- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth
{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = (CGRect){0.0, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth};
    [self.layer addSublayer:border];
}


- (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth
{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = (CGRect){0.0, 0.0, borderWidth, self.frame.size.height};
    [self.layer addSublayer:border];
}


- (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth
{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = (CGRect){self.frame.size.width - borderWidth, 0.0, borderWidth, self.frame.size.height};
    [self.layer addSublayer:border];
}


- (void)addBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = color.CGColor;
}

#pragma mark Animated Positioning

- (void)moveAnimatedRight:(CGFloat)value
{
    [UIView animateWithDuration:0.25 delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ [self moveRight:value]; } completion:nil];
}


- (void)moveAnimatedLeft:(CGFloat)value
{
    [UIView animateWithDuration:0.25 delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ [self moveLeft:value]; } completion:nil];
}


- (void)moveAnimatedUp:(CGFloat)value
{
    [UIView animateWithDuration:0.25 delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ [self moveUp:value]; } completion:nil];
}


- (void)moveAnimatedDown:(CGFloat)value
{
    [UIView animateWithDuration:0.25 delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ [self moveDown:value]; } completion:nil];
}


- (void)centerAnimatedInSuperView
{
    [UIView animateWithDuration:0.25 delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ [self centerInSuperView]; } completion:nil];
}

#pragma mark Image Rendering

- (UIImage *)renderedImage
{
    BOOL isOpaque = self.opaque;
    BOOL isHidden = self.hidden;
    self.opaque = NO;
    self.hidden = NO;

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, UIScreen.mainScreen.scale);
    [UIColor.clearColor set];
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.opaque = isOpaque;
    self.hidden = isHidden;

    return image;
}


- (BOOL)saveRenderedImageToDocuments
{
    NSData* imageData = UIImagePNGRepresentation([self renderedImage]);
    NSURL* documentsDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    NSString* fileName = [NSString stringWithFormat:@"%@-%@.png", NSStringFromClass(self.class), NSDate.date.description];
    NSURL *file = [documentsDirectory URLByAppendingPathComponent:fileName];

    return [imageData writeToFile:file.path atomically:YES];
}

#pragma mark Creating

+ (instancetype)createFromXIB;
{
    return [NSBundle.mainBundle loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil].firstObject;
}

#pragma mark Debugging

- (void)dumpFrame:(NSString *)comment
{
    NSLog(@"\n%@Frame: %@\nCenter: %@", (comment)?[comment stringByAppendingString:@": \n"]:@"",
                                        NSStringFromCGRect(self.frame),
                                        NSStringFromCGPoint(self.center));
}
@end
