//
//  TAAppDelegate.h
//  TokyoAmesh
//
//  Created by Erkan YILDIZ on 20150826.
//  Copyright (c) 2015 Erkan YILDIZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TAViewController;
@interface TAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) TAViewController* viewController;
@property (strong, nonatomic) UIWindow *window;

@end