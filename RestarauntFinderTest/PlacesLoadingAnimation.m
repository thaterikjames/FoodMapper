//
//  PlacesLoadingAnimation.m
//  RestarauntFinderTest
//
//  Created by Erik James on 9/10/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

#import "PlacesLoadingAnimation.h"

@implementation PlacesLoadingAnimation
{
    UIImageView *loaderImage;
    UIActivityIndicatorView *activityIndicator;
}

-  (id)initWithFrame:(CGRect)aRect
{
    if (self = [super initWithFrame:aRect])
    {
        [self initView];
    }
    
    return self;
}

-(void)initView
{
    
    loaderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingBKG"]];
    
    [self addSubview: loaderImage];
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview: activityIndicator];
    [activityIndicator startAnimating];
    [self reCenter];
}

-(void)reCenter
{
    activityIndicator.center = CGPointMake((self.frame.size.width / 2.0), (self.frame.size.height / 2.0));
    loaderImage.center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
}

@end
