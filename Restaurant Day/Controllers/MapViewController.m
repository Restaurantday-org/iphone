//
//  FirstViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "MapViewController.h"
#import "Restaurant.h"
#import "RestaurantViewController.h"

@interface MapViewController (hidden)
- (void)showSplash;
- (void)hideSplash;
@end

@implementation MapViewController

@synthesize map;

@dynamic restaurants;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
    
    map.delegate = self;
    map.showsUserLocation = YES;
    
    CLLocationCoordinate2D defaultCoordinate = CLLocationCoordinate2DMake(60.1695, 24.9388);
    [map setRegion:MKCoordinateRegionMakeWithDistance(defaultCoordinate, 4000, 4000) animated:NO];
    
    updatedToUserLocation = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAdded:) name:kFavoriteAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteRemoved:) name:kFavoriteRemoved object:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-locate"] style:UIBarButtonItemStyleBordered target:self action:@selector(focusOnUserLocation)];
    
    dataProvider = [[RestaurantDataProvider alloc] init];
    dataProvider.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.titleView = [[UIView alloc] init]; 
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidUnload
{    
    self.map = nil;
    [super viewDidUnload];
}

- (NSArray *)restaurants
{
    return restaurants;
}

- (void)setRestaurants:(NSArray *)newRestaurants
{
    [map removeAnnotations:restaurants];
    restaurants = nil;
    
    [self addRestaurants:newRestaurants];
}

- (void)addRestaurants:(NSArray *)newRestaurants
{
    NSLog(@"number of new restaurants: %d", newRestaurants.count);
    if (restaurants == nil) {
        restaurants = [NSMutableArray arrayWithArray:newRestaurants];
        [map addAnnotations:restaurants];
    } else {
        for (Restaurant *restaurant in newRestaurants) {
            if ([restaurants containsObject:restaurant]) {
                [restaurants addObject:restaurant];
                [map addAnnotation:restaurant];
            }
        }
    }
        
    if (map.userLocation != nil) {
        for (Restaurant *restaurant in restaurants) {
            [restaurant updateDistanceWithLocation:map.userLocation.location];
        }
    }
}

- (void)favoriteAdded:(NSNotification *)notification
{
    Restaurant *restaurant = (Restaurant *) notification.object;
    [map removeAnnotation:restaurant];
    [map addAnnotation:restaurant];
}

- (void)favoriteRemoved:(NSNotification *)notification
{
    Restaurant *restaurant = (Restaurant *) notification.object;
    [map removeAnnotation:restaurant];
    [map addAnnotation:restaurant];
}

- (IBAction)focusOnUserLocation
{
    if (map.userLocation != nil) {
        CLLocationCoordinate2D userCoordinate = map.userLocation.coordinate;
        if (userCoordinate.latitude != 0 && userCoordinate.longitude != 0) {
            [map setCenterCoordinate:map.userLocation.coordinate animated:YES];
        }
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!updatedToUserLocation) {
        [mapView setRegion:MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000) animated:YES];
        updatedToUserLocation = YES;
    }
    
    for (Restaurant *restaurant in restaurants) {
        [restaurant updateDistanceWithLocation:userLocation.location];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[Restaurant class]]) {
        
        static NSString *restaurantViewId = @"RestaurantView";
        MKAnnotationView *restaurantView = [mapView dequeueReusableAnnotationViewWithIdentifier:restaurantViewId];
        if (restaurantView == nil) {
            restaurantView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:restaurantViewId];
            restaurantView.canShowCallout = YES;
            restaurantView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } else {
            restaurantView.annotation = annotation;
        }
        
        Restaurant *restaurant = (Restaurant *) annotation;
        if (restaurant.isOpen) {
            restaurantView.image = [UIImage imageNamed:(restaurant.favorite) ? @"pin-open-star" : @"pin-open"];
        } else if (restaurant.isAlreadyClosed) {
            restaurantView.image = [UIImage imageNamed:(restaurant.favorite) ? @"pin-closed-star" : @"pin-closed"];
        } else {
            restaurantView.image = [UIImage imageNamed:(restaurant.favorite) ? @"pin-generic-star" : @"pin-generic"];
        }
                
        return restaurantView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[Restaurant class]]) {
        RestaurantViewController *restaurantViewController = [[RestaurantViewController alloc] init];
        restaurantViewController.restaurant = view.annotation;
        [self.navigationController pushViewController:restaurantViewController animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSInteger kilometers = (mapView.region.span.latitudeDelta*111)+1;
    CLLocationCoordinate2D center = mapView.region.center;
    [dataProvider startLoadingRestaurantsWithCenter:center distance:kilometers];
}

- (void)gotRestaurants:(NSArray *)newRestaurants
{
    [self addRestaurants:newRestaurants];
}

- (void)failedToGetRestaurants
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Errors.LoadingRestaurantsFailed.Title", @"") message:NSLocalizedString(@"Errors.LoadingRestaurantsFailed.Message", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Buttons.OK", @"") otherButtonTitles:nil];
    [alert show];
}

@end
