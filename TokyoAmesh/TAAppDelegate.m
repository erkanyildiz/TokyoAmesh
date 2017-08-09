//
//  TAAppDelegate.m
//  TokyoAmesh
//
//  Created by erkanyildiz on 20150826.
//  Copyright (c) 2015 erkanyildiz. All rights reserved.
//

#import "TAAppDelegate.h"
#import "TAViewController.h"

@implementation TAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{        
    self.window = [UIWindow.alloc initWithFrame:UIScreen.mainScreen.bounds];

    self.viewController = [TAViewController createFromXIB];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}
@end
