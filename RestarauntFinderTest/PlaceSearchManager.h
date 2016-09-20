//
//  PlaceSearchManager.h
//  RestarauntFinderTest
//
//  Created by Erik James on 9/10/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@protocol PlaceSearchManagerDelegate

-(void)placesUpdated:(NSArray *)places;

@end

@interface PlaceSearchManager : NSObject

-(void)findPlacesNear:(CLLocationCoordinate2D)location withRadius:(CGFloat)radius;

@property (nonatomic, weak) id delegate;

@end
