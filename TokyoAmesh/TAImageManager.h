//
//  TAImageManager.h
//  TokyoAmesh
//
//  Created by erkanyildiz on 20170109.
//  Copyright (c) 2015 erkanyildiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAImageManager : NSObject
+ (instancetype)sharedInstance;
+ (UIImage *)currentImage;
- (void)ameshImageForDate:(NSDate *)date completion:(void (^)(UIImage* image, NSError* error))handler;
@end
