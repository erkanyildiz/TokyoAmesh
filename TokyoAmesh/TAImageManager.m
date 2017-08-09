//
//  TAImageManager.m
//  TokyoAmesh
//
//  Created by erkanyildiz on 20170109.
//  Copyright (c) 2015 erkanyildiz. All rights reserved.
//

#import "TAImageManager.h"
#import "EYUtils.h"

@interface TAImageManager ()
{
    NSDateFormatter* dateFormatter;
}
@end

static UIImage* last = nil;

@implementation TAImageManager
+ (instancetype)sharedInstance
{
    static id s_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ s_sharedInstance = self.new; });
    return s_sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Tokyo"]];
        dateFormatter = NSDateFormatter.new;
        dateFormatter.dateFormat = @"YYYYMMddHHmm";
    }
    return self;
}


- (void)ameshImageForDate:(NSDate *)date completion:(void (^)(UIImage* image, NSError* error))handler
{
    //TODO: use cache
    NSURLRequest* request = [[self ameshURLStringForDate:date] request];
    [request fetchImage:^(UIImage *image, NSError *error)
    {
        last = image;
        handler(image, error);
    }];
}


- (NSString *)ameshURLStringForDate:(NSDate *)date
{
    NSString* URLString = [NSString stringWithFormat:@"http://tokyo-ame.jwa.or.jp/mesh/000/%@.gif", [dateFormatter stringFromDate:date]];
    
    return URLString;
}


+ (UIImage *)currentImage
{
    return last;
}

@end
