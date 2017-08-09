//
//  TAOverlayRenderer.h
//  TokyoAmesh
//
//  Created by erkanyildiz on 20170808.
//  Copyright (c) 2015 erkanyildiz. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface TAOverlayRenderer : MKOverlayRenderer

@end


#pragma mark -


@interface TAOverlay : NSObject <MKOverlay>
- (MKMapRect)boundingMapRect;
- (CLLocationCoordinate2D)coordinate;
@end
