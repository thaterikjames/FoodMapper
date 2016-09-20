//
//  PlaceSearchManager.m
//  RestarauntFinderTest
//
//  Created by Erik James on 9/10/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

#import "PlaceSearchManager.h"

@implementation PlaceSearchManager

-(void)findPlacesNear:(CLLocationCoordinate2D)location withRadius:(CGFloat)radius
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%f&type=restaurant&keyword=Japanese,sushi&sensor=true&key=AIzaSyA1ABt8DXq_SQw9GJ-pDJq4JbubG_f_xHY",
                                                          location.latitude, location.longitude, radius]]];
    [request setHTTPMethod:@"GET"];
    
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          
          if (error!=nil)
          {
              NSLog(@"error %@", error);
          }
          else
          {
              NSError *jsonError = nil;
                if ([self.delegate respondsToSelector:@selector(placesUpdated:)]) {
                    NSDictionary *returnData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                    NSArray *returnArray = (NSArray *)[returnData objectForKey:@"results"];

                  [self.delegate placesUpdated:returnArray];
              }
              
          }
          
          
      }] resume];
}

@end
