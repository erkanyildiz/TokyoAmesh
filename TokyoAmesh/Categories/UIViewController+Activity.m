//
//  UIViewController+Activity.m
//  TokyoAmesh
//
//  Created by Erkan YILDIZ on 20150826.
//  Copyright (c) 2015 Erkan YILDIZ. All rights reserved.
//

#import "UIViewController+Activity.h"

@implementation UIViewController (Activity)
NSInteger activityCount;
UIActivityIndicatorView* indicator;
UIView* overlayView;

-(void)showActivityIndicator;
{
    if(activityCount == 0)
        [self performSelector:@selector(show) withObject:nil afterDelay:0.1];
    
    activityCount++;
}


-(void)show
{
    indicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.hidesWhenStopped = YES;
    [indicator startAnimating];
    indicator.center = (CGPoint){UIScreen.mainScreen.bounds.size.width*0.5,UIScreen.mainScreen.bounds.size.height*0.5};
    [UIApplication.sharedApplication.windows.lastObject addSubview:indicator];

    CGRect r = indicator.frame;
    r.size.width += 40;
    r.size.height += 40;
    r.origin.x -= 20;
    r.origin.y -= 20;
    overlayView = [UIView.alloc initWithFrame:r];
    overlayView.layer.cornerRadius = 10;
    overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [UIApplication.sharedApplication.windows.lastObject insertSubview:overlayView belowSubview:indicator];
}


-(void)hideActivityIndicator
{
    activityCount--;

    if(activityCount == 0)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(show) object:nil];
        
        [indicator removeFromSuperview];
        [overlayView removeFromSuperview];
    }
}

@end