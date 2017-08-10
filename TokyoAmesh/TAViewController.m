//
//  TAViewController.m
//  TokyoAmesh
//
//  Created by erkanyildiz on 20150826.
//  Copyright (c) 2015 erkanyildiz. All rights reserved.
//

#import "TAViewController.h"
#import "TAImageManager.h"
#import "UIViewController+Activity.h"
#import "TAOverlayRenderer.h"

@interface TAViewController ()
{
    NSDateFormatter* df_timeDisplay;
    TAOverlayRenderer* overlayRenderer;
}

@property (weak, nonatomic) IBOutlet UISlider* sld_time;
@property (weak, nonatomic) IBOutlet UILabel* lbl_time;
@property (weak, nonatomic) IBOutlet UILabel* lbl_ago;
@property (weak, nonatomic) IBOutlet MKMapView* map_main;

@end


@implementation TAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Tokyo"]];

    df_timeDisplay = NSDateFormatter.new;
    df_timeDisplay.dateFormat = @"HH:mm";

    [self onChange_slider:self.sld_time];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(willEnterForeground:)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];

    [self.map_main addOverlay:TAOverlay.new];
    
    //NOTE: initial map position
    CLLocationCoordinate2D hachiko = (CLLocationCoordinate2D){35.6583959, 139.6978787};
    MKCoordinateRegion hachiko5km = MKCoordinateRegionMakeWithDistance(hachiko, 5000, 5000);
    [self.map_main setRegion:hachiko5km animated:YES];
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (BOOL)prefersStatusBarHidden
{
    return NO;
}


#pragma mark -


-(void)willEnterForeground:(NSNotification*)notification
{
    //NOTE: bring slider to the lastest after app comes back from background
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

    [TAImageManager.sharedInstance ameshImageForDate:[self roundedDateForMinutesOffset:minutes] completion:^(UIImage *image, NSError *error)
    {
        //TODO: update the map for downloaded rain image, if the slider value is still the same
        //TODO: handle if radar image is not ready yet due to server delays (esp. first minute of every 5 min interval)
        [overlayRenderer setNeedsDisplayInMapRect:overlayRenderer.overlay.boundingMapRect];

        [self hideActivityIndicator];
    }];

    //NOTE: setting time labels
    self.lbl_time.text = [df_timeDisplay stringFromDate:[self roundedDateForMinutesOffset:minutes]];
    self.lbl_ago.text = (minutes == 0) ? @"Latest" : [NSString stringWithFormat:@"%li mins ago", (long)minutes];
}


- (NSDate *)roundedDateForMinutesOffset:(NSInteger)minutesOffset
{
    //NOTE: backwards time offset up to 120 mins
    NSDate* targetDate = [NSDate.date dateByAddingTimeInterval: -minutesOffset * 60];
    
    //NOTE: rounding minute digit to 0 or 5
    NSTimeInterval time = floor([targetDate timeIntervalSinceReferenceDate] / 300.0) * 300.0;
    targetDate = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
    
    return targetDate;
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    overlayRenderer = [TAOverlayRenderer.alloc initWithOverlay:overlay];
    return overlayRenderer;
}

@end
