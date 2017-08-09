//
//  TAOverlayRenderer.m
//  TokyoAmesh
//
//  Created by erkanyildiz on 20170808.
//  Copyright (c) 2015 erkanyildiz. All rights reserved.
//

#import "TAOverlayRenderer.h"
#import "TAImageManager.h"

@implementation TAOverlayRenderer

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    MKMapRect boundingMapRect = self.overlay.boundingMapRect;
    CGRect rect = [self rectForMapRect:boundingMapRect];

//    CGContextSetRGBFillColor(context, 1, 0, 0, 0.7);
//    CGContextFillRect(context, rect);
    
    CGContextSetAlpha(context, 0.5);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -rect.size.height);
    CGImageRef imageReference = TAImageManager.currentImage.CGImage;
    CGContextDrawImage(context, rect, imageReference);
}

@end


#pragma mark -


@implementation TAOverlay

- (CLLocationCoordinate2D)coordinate
{
    return (CLLocationCoordinate2D){35.670000, 139.475000};
}


- (MKMapRect)boundingMapRect
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([self coordinate], 124000, 196000);

    MKMapPoint tl = MKMapPointForCoordinate((CLLocationCoordinate2D){region.center.latitude + region.span.latitudeDelta * 0.5, region.center.longitude - region.span.longitudeDelta * 0.5});
    MKMapPoint br = MKMapPointForCoordinate((CLLocationCoordinate2D){region.center.latitude - region.span.latitudeDelta * 0.5, region.center.longitude + region.span.longitudeDelta * 0.5});
    MKMapRect bounds = MKMapRectMake(MIN(tl.x, br.x), MIN(tl.y,br.y), ABS(br.x - tl.x), ABS(br.y - tl.y));
    
    return bounds;
}

@end
