//
//  TAViewController.m
//  TokyoAmesh
//
//  Created by Erkan YILDIZ on 20150826.
//  Copyright (c) 2015 Erkan YILDIZ. All rights reserved.
//

#import "TAViewController.h"
#import "SDWebImageManager.h"
#import "UIViewController+Activity.h"

@interface TAViewController ()
{
    NSDateFormatter* df_URL;
    NSDateFormatter* df_timeDisplay;
}
@end

@implementation TAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Tokyo"]];

    df_URL = NSDateFormatter.new;
    df_URL.dateFormat = @"YYYYMMddHHmm";

    df_timeDisplay = NSDateFormatter.new;
    df_timeDisplay.dateFormat = @"HH:mm";

    [self onChange_slider:self.sld_time];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(willEnterForeground:)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];

    self.scr_zoom.zoomScale = 3.1;
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(BOOL)prefersStatusBarHidden
{
    return NO;
}


-(void)willEnterForeground:(NSNotification*)notification
{
    [self.sld_time setValue:24];
    [self onChange_slider:self.sld_time];
}


- (IBAction)onChange_slider:(id)sender 
{
    //NOTE: snapping between 0 and 24
    UISlider *slider = sender;
    slider.value = (NSInteger)slider.value;

    //NOTE: convert slider value into minutes    
    NSInteger minutes = (24 - slider.value) * 5;
    
    //NOTE: requesting rain radar image with caching
    [self showActivityIndicator];
    NSURL* URL = [self ameshURLForMinutesOffset:minutes];
    [SDWebImageManager.sharedManager downloadImageWithURL:URL options:0 progress:nil
                                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) 
    {
        //NOTE: setting image view on completion, if the slider value is still the same
        if (image && [imageURL isEqual:[self ameshURLForMinutesOffset:(24 - slider.value) * 5]])
        {
            self.img_rain.image = image;
        }
        
        [self hideActivityIndicator];
    }];

    //NOTE: setting time labels
    self.lbl_time.text = [df_timeDisplay stringFromDate:[self roundedDateForMinutesOffset:minutes]];
    self.lbl_ago.text = (minutes == 0)?@"Latest":[NSString stringWithFormat:@"%li mins ago", minutes];
}


-(NSDate*)roundedDateForMinutesOffset:(NSInteger)minutesOffset
{
    //NOTE: backwards time offset up to 120 mins
    NSDate* targetDate = [NSDate.date dateByAddingTimeInterval:-minutesOffset*60];
    
    //NOTE: rounding minute digit to 0 or 5
    NSTimeInterval time = floor([targetDate timeIntervalSinceReferenceDate]/300.0)*300.0;
    targetDate = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
    
    return targetDate;
}


-(NSURL*)ameshURLForMinutesOffset:(NSInteger)minutesOffset
{
    NSDate* roundedDate = [self roundedDateForMinutesOffset:minutesOffset];

    NSString* URL = [NSString stringWithFormat:@"http://tokyo-ame.jwa.or.jp/mesh/000/%@.gif", [df_URL stringFromDate:roundedDate]];

    return [NSURL URLWithString:URL];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //TODO: double tap zoom
    //TODO: content size fixing for edges
    return self.vw_container;
}
@end