// erkanyildiz
// 20170519-1549+0900
//
// EYUtils.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef DEBUG_MODE
#define DEBUG_MODE 1
#endif

#if DEBUG_MODE
#define DLOG(...) NSLog(__VA_ARGS__)
#else
#define DLOG(...)
#endif

#define MLOG DLOG(@"%s",__FUNCTION__)

#pragma mark ---

#define SCREEN_W (MIN(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height))
#define SCREEN_H (MAX(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height))

#define IS_PAD (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
#define IS_PAD_PRO (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad && SCREEN_H == 1366)
#define IS_IPHONE (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)

#define IS_480 (IS_IPHONE && SCREEN_H == 480)
#define IS_568 (IS_IPHONE && SCREEN_H == 568)
#define IS_667 (IS_IPHONE && SCREEN_H == 667)
#define IS_736 (IS_IPHONE && SCREEN_H == 736)

#define VFD(a,b,c,d) (IS_480?(a):IS_568?(b):IS_667?(c):(d))

#pragma mark ---

#define IS_IOS7 (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0 && NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0)
#define IS_IOS8 (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0 && NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_9_0)
#define IS_IOS9 (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_0 && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_9_x_Max)
#define IS_IOS10 [UIDevice.currentDevice.systemVersion hasPrefix:@"10"]

#define IS_IOS7_OR_EARLIER (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0)
#define IS_IOS8_OR_LATER (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0)
#define IS_IOS9_OR_LATER (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_0)
#define IS_IOS10_OR_LATER (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_9_x_Max)

#pragma mark ---

#define IMG(n) [UIImage imageNamed:(n)]

#define FONT(n,s) [UIFont fontWithName:(n) size:(s)]

#define RGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define RGBW(w, a) [UIColor colorWithWhite:(w)/255.0 alpha:(a)]

#define NSUD NSUserDefaults.standardUserDefaults
#define LS(str) NSLocalizedString(str, nil)

#pragma mark ---

#define D2R(angle) ((angle) * M_PI / 180.0)
#define R2D(angle) ((angle) * 180.0 / M_PI)

#pragma mark -

void afterDelay(NSTimeInterval delay, void(^block)(void));
void onMainThread(void(^block)(void));

#pragma mark -
@interface NSObject (EYUtils)
- (void)dump;
- (void)dumpWith:(NSString *)logText;
@end


#pragma mark -
@interface NSString (EYUtils)
+ (NSString *)randomStringWithLength:(NSUInteger)length;

#pragma mark Encryption | Hashing
- (NSString *)stringByEncryptingWithKey:(NSString *)key;
- (NSString *)stringByDecryptingWithKey:(NSString *)key;

- (NSString *)SHA256;
- (NSString *)MD5;

#pragma mark Network Operations
- (NSURL *)URL;
- (NSURLRequest *)request;
@end


#pragma mark -
@interface NSURLRequest (EYUtils)
- (void)fetchJSON:(void (^)(id JSONResponse, NSError* error))handler;
- (void)fetchImage:(void (^)(UIImage* image, NSError* error))handler;
- (void)fetchData:(void (^)(NSData* data, NSError* error))handler;
@end


#pragma mark -
@interface NSURL (EYUtils)
- (NSURL *)URLByAddingQueryParameters:(NSDictionary *)parameters;
@end


#pragma mark -
@interface NSArray (EYUtils)
- (NSString *)JSON;
@end


#pragma mark -
@interface NSDictionary (EYUtils)
- (NSString *)JSON;
@end


#pragma mark -
@interface UIButton (EYUtils)
- (void)addTapBlock:(void (^)(id sender)) handler;
@end


#pragma mark -
@interface UIColor (EYUtils)
- (UIColor *)colorByMixingWithColor:(UIColor *)color atRatio:(CGFloat)ratio;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
@end


#pragma mark -
@interface UIImage (EYUtils)
- (UIImage *)imageByCombiningWithImage:(UIImage *)upperImage;
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
@end


#pragma mark -
@interface UIViewController (EYUtils)
+ (instancetype)createFromXIB;
@end


#pragma mark -
@interface NSMutableData (EYUtils)
- (void)appendString:(NSString *)string;
@end


#pragma mark -
@interface UIView (EYUtils)

#pragma mark Positioning
- (void)moveRight:(CGFloat)value;
- (void)moveLeft:(CGFloat)value;
- (void)moveUp:(CGFloat)value;
- (void)moveDown:(CGFloat)value;

- (void)centerInSuperView;
- (void)centerRightInSuperView;
- (void)centerLeftInSuperView;
- (void)centerTopInSuperView;
- (void)centerBottomInSuperView;

- (void)stickToRightInSuperView;
- (void)stickToLeftInSuperView;
- (void)stickToTopInSuperView;
- (void)stickToBottomInSuperView;

- (void)setCenterX:(CGFloat)value;
- (void)setCenterY:(CGFloat)value;
- (void)setOriginX:(CGFloat)value;
- (void)setOriginY:(CGFloat)value;
- (void)setOrigin:(CGPoint)origin;

#pragma mark Resizing
- (void)setHeight:(CGFloat)value;
- (void)setWidth:(CGFloat)value;
- (void)expandRight:(CGFloat)value;
- (void)expandLeft:(CGFloat)value;
- (void)expandUp:(CGFloat)value;
- (void)expandDown:(CGFloat)value;

#pragma mark Bordering
- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth;
- (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth;
- (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth;
- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth;
- (void)addBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth;

#pragma mark Animated Positioning
- (void)moveAnimatedRight:(CGFloat)value;
- (void)moveAnimatedLeft:(CGFloat)value;
- (void)moveAnimatedUp:(CGFloat)value;
- (void)moveAnimatedDown:(CGFloat)value;
- (void)centerAnimatedInSuperView;

#pragma mark Image Rendering
- (UIImage *)renderedImage;
- (BOOL)saveRenderedImageToDocuments;

#pragma mark Creating
+ (instancetype)createFromXIB;

#pragma mark Debugging
- (void)dumpFrame:(NSString *)comment;
@end
