//
//  TAViewController.h
//  TokyoAmesh
//
//  Created by Erkan YILDIZ on 20150826.
//  Copyright (c) 2015 Erkan YILDIZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *img_rain;
@property (weak, nonatomic) IBOutlet UISlider *sld_time;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;
@property (weak, nonatomic) IBOutlet UILabel *lbl_ago;
@property (weak, nonatomic) IBOutlet UIScrollView *scr_zoom;
@property (weak, nonatomic) IBOutlet UIView *vw_container;

- (IBAction)onChange_slider:(id)sender;

@end