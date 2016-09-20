//
//  ViewController.m
//  RestarauntFinderTest
//
//  Created by Erik James on 9/8/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

#import "RestaurantFinderViewController.h"
#import "PlacesLoadingAnimation.h"
#import "InfoWindow.h"

#define MIN_ZOOM 12
#define MAX_ZOOM 20
#define INITIAL_ZOOM 13
#define TOOLBAR_HEIGHT 90
#define REDO_SEARCH_TEXT @"Redo Search In This Area"
#define NO_RESULTS_TEXT @"No Results Found"

@interface RestaurantFinderViewController ()
{
    CLLocationManager *locationManager;
    GMSMapView *_mapView;
    BOOL firstLocationUpdate;
    BOOL initialSearchCompleted;
    PlaceSearchManager *searchManager;
    UIButton *redoSearchButton;
    PlacesLoadingAnimation *loadingAnimation;
    NSMutableDictionary *imageCache;
    NSString *currentButtonText;
}
@end

@implementation RestaurantFinderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    firstLocationUpdate = NO;
    initialSearchCompleted = NO;
    currentButtonText = REDO_SEARCH_TEXT;
    
    locationManager = [CLLocationManager new];
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    _mapView = [GMSMapView mapWithFrame:self.view.frame camera:[GMSCameraPosition cameraWithLatitude:-33.86
                                                                                     longitude:151.20
                                                                                          zoom:6]];
    
    _mapView.myLocationEnabled = YES;
    _mapView.settings.compassButton = YES;
    _mapView.settings.myLocationButton = YES;
    _mapView.delegate = self;
    _mapView.mapType = kGMSTypeNormal;
    
    [_mapView setMinZoom:MIN_ZOOM maxZoom:MAX_ZOOM];
    
    self.view = _mapView;
    
    [_mapView addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    
    searchManager = [PlaceSearchManager new];
    searchManager.delegate = self;
    
    redoSearchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self setRedoButtonRect];
    redoSearchButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [redoSearchButton addTarget:self action:@selector(searchArea) forControlEvents:UIControlEventTouchUpInside];
    [redoSearchButton setBackgroundColor:[UIColor whiteColor]];
    [redoSearchButton setTitle:currentButtonText forState:UIControlStateNormal];
    [redoSearchButton setHidden:YES];
    [_mapView addSubview:redoSearchButton];
    
    loadingAnimation = [[PlacesLoadingAnimation alloc] initWithFrame:_mapView.frame];
    
}

-(void)setRedoButtonRect
{
    redoSearchButton.frame = CGRectMake((_mapView.bounds.size.width- 200)/2, 20, 200, 30);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)orientationChanged:(NSNotification *)notification{
    if(initialSearchCompleted){
        [self setRedoButtonRect];
        [redoSearchButton setHidden:YES];
        [self performSelector:@selector(unhideRedo) withObject:nil afterDelay:0.3f];
        [loadingAnimation setFrame:_mapView.frame];
        [loadingAnimation reCenter];
    }
}

-(void)unhideRedo
{
    [redoSearchButton setHidden:NO];
}
-(void)searchArea
{
    CGPoint point = _mapView.center;
    CLLocationCoordinate2D center = [_mapView.projection coordinateForPoint:point];
    CLLocationCoordinate2D shortestDistance;
    if(UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])){
       shortestDistance = [_mapView.projection coordinateForPoint:CGPointMake(0, _mapView.center.y)];
    } else {
        shortestDistance = [_mapView.projection coordinateForPoint:CGPointMake(_mapView.center.x, 0)];
    }
    CGFloat distance = [self returnDistanceFrom:shortestDistance to:center];
    
    [searchManager findPlacesNear:center withRadius:distance];
    [redoSearchButton setHidden:YES];
    currentButtonText = NO_RESULTS_TEXT;
    [redoSearchButton setTitle:currentButtonText forState:UIControlStateNormal];
    [self.view addSubview:loadingAnimation];
    
}

-(void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    currentButtonText = REDO_SEARCH_TEXT;
    [redoSearchButton setHidden:YES];
    [redoSearchButton setTitle:currentButtonText forState:UIControlStateNormal];
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    if(initialSearchCompleted){
        [self setRedoButtonRect];
        [redoSearchButton setHidden:NO];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate) {
        firstLocationUpdate = YES;
        _mapView.camera = [GMSCameraPosition cameraWithTarget:_mapView.myLocation.coordinate
                                                         zoom:INITIAL_ZOOM];
        
        [self searchArea];
     }
}

-(void)placesUpdated:(NSArray *)places
{
    imageCache = [NSMutableDictionary new];
    [_mapView clear];
    
    for(NSDictionary *dict in places){
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake([dict[@"geometry"][@"location"][@"lat"] doubleValue], [dict[@"geometry"][@"location"][@"lng"] doubleValue]);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = dict[@"name"];
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.userData = dict;
        marker.icon = [UIImage imageNamed:@"foodIcon"];
        marker.map = _mapView;
    }
    initialSearchCompleted = YES;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if(places.count){
            currentButtonText = REDO_SEARCH_TEXT;
            [redoSearchButton setHidden:YES];
        }else{
            [redoSearchButton setHidden:NO];
        }
        [redoSearchButton setTitle:currentButtonText forState:UIControlStateNormal];
        [loadingAnimation removeFromSuperview];
    }];
}

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    mapView.selectedMarker = marker;
    
    
    return YES;
}


-(CGFloat)returnDistanceFrom:(CLLocationCoordinate2D)coord1 to:(CLLocationCoordinate2D)coord2
{
    CLLocation* location1 = [[CLLocation alloc] initWithLatitude: coord1.latitude longitude: coord1.longitude];
    CLLocation* location2 =
    [[CLLocation alloc] initWithLatitude: coord2.latitude longitude: coord2.longitude];
    
    return [location1 distanceFromLocation: location2];
}

-(UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    InfoWindow *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"CustomInfoWindow" owner:self options:nil] objectAtIndex:0];
    infoWindow.labelOne.text = marker.userData[@"name"];
    infoWindow.labelTwo.text = [marker.userData[@"vicinity"] componentsSeparatedByString:@","][0];
    infoWindow.marker = marker;
    if(marker.userData[@"photos"] && marker.userData[@"photos"][0][@"photo_reference"]){
        if(imageCache[marker.userData[@"photos"][0][@"photo_reference"]]){
            infoWindow.restaurantImage.image = imageCache[marker.userData[@"photos"][0][@"photo_reference"]];
        } else {
            [self getImage:marker.userData[@"photos"][0][@"photo_reference"] forImageView:infoWindow];
        }
        
    } else {
        infoWindow.restaurantImage.image = [UIImage imageNamed:@"happy-sushi"];
    }
    
    CGPoint markerPoint = [_mapView.projection pointForCoordinate:marker.position];
    CGSize infoWindowSize = infoWindow.frame.size;
    CGRect mapMinusToolbar = CGRectInset(_mapView.frame, 0, TOOLBAR_HEIGHT);
    CGRect infoWindowRect = CGRectMake(markerPoint.x - infoWindowSize.width/2, markerPoint.y - infoWindowSize.height, infoWindowSize.width, infoWindowSize.height);
    CGPoint shift = CGPointMake(0, 0);
    
    if(mapMinusToolbar.origin.x > infoWindowRect.origin.x){
        shift.x = infoWindowRect.origin.x - mapMinusToolbar.origin.x;
    } else if (CGRectGetMaxX(infoWindowRect) > CGRectGetMaxX(mapMinusToolbar)){
        shift.x = CGRectGetMaxX(infoWindowRect) - CGRectGetMaxX(mapMinusToolbar);
    }
    
    if(mapMinusToolbar.origin.y > infoWindowRect.origin.y){
        shift.y = infoWindowRect.origin.y - mapMinusToolbar.origin.y;
    } else if (CGRectGetMaxY(infoWindowRect) > CGRectGetMaxY(mapMinusToolbar)){
        shift.y = CGRectGetMaxY(infoWindowRect) - CGRectGetMaxY(mapMinusToolbar);
    }
    
    GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate scrollByX:shift.x Y:shift.y];
    
    [_mapView animateWithCameraUpdate:cameraUpdate];
    
    return infoWindow;
}

-(void)getImage:(NSString *)photoRef forImageView:(InfoWindow *)infoWindow
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=AIzaSyA1ABt8DXq_SQw9GJ-pDJq4JbubG_f_xHY", photoRef]];
    NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
                                                   downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                       // 3
                                                       UIImage *downloadedImage = [UIImage imageWithData:
                                                                                   [NSData dataWithContentsOfURL:location]];
                                                       [imageCache setObject:downloadedImage forKey:photoRef];
                                                       
                                                       if(_mapView.selectedMarker == infoWindow.marker){
                                                           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                               _mapView.selectedMarker = infoWindow.marker;
                                                           }];
                                                       }
                                                   }];
    
    [downloadPhotoTask resume];
        
    
}

@end



