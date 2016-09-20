//
//  InfoWindow.h
//  RestarauntFinderTest
//
//  Created by Erik James on 9/10/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface InfoWindow : UIView
@property (weak, nonatomic) IBOutlet UIImageView *restaurantImage;
@property (weak, nonatomic) IBOutlet UILabel *labelOne;
@property (weak, nonatomic) IBOutlet UILabel *labelTwo;
@property (weak, nonatomic) IBOutlet UILabel *labelThree;

@property (weak, nonatomic) GMSMarker* marker;

@end
