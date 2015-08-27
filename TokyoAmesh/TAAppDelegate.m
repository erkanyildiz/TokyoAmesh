//
//  TAAppDelegate.m
//  TokyoAmesh
//
//  Created by Erkan YILDIZ on 20150826.
//  Copyright (c) 2015 Erkan YILDIZ. All rights reserved.
//

#import "TAAppDelegate.h"
#import "TAViewController.h"

@implementation TAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{        
    self.window = [UIWindow.alloc initWithFrame:UIScreen.mainScreen.bounds];

    self.viewController = [TAViewController.alloc initWithNibName:@"TAViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}
@end