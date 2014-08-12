//
//  CompanyViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantViewController.h"

#import "RestaurantLocationViewController.h"
#import "WebViewController.h"

@interface RestaurantViewController ()
@property (nonatomic, weak) UITapGestureRecognizer *recognizerForModalDismiss;
@end

@implementation RestaurantViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = [NSString stringWithFormat:@"Restaurant / %@", self.restaurant.name];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (IS_IOS_7_OR_LATER) {
        UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
        statusBar.backgroundColor = [UIColor blackColor];
        statusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:statusBar];
    }
    
    UIView *titleView = [[UIView alloc] init];
    titleView.width = 160;
    titleView.height = 44;
    titleView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    
    UILabel *titleNameLabel = [[UILabel alloc] init];
    titleNameLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    titleNameLabel.x = 0;
    titleNameLabel.y = 0;
    titleNameLabel.width = 160;
    titleNameLabel.height = 44;
    titleNameLabel.text = self.restaurant.name;
    titleNameLabel.textColor = [UIColor whiteColor];
    titleNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    titleNameLabel.minimumScaleFactor = 0.75;
    titleNameLabel.adjustsFontSizeToFitWidth = YES;
    titleNameLabel.textAlignment = NSTextAlignmentCenter;
    titleNameLabel.numberOfLines = 2;

    [titleView addSubview:titleNameLabel];
    self.navigationItem.titleView = titleView;
        
    [self.mapView setCenterCoordinate:self.restaurant.coordinate];
    [self.mapView setRegion:MKCoordinateRegionMake(self.restaurant.coordinate, MKCoordinateSpanMake(0.002, 0.002))];
    [self.mapView addAnnotation:self.restaurant];
    self.mapView.userInteractionEnabled = NO;
    self.scrollView.alwaysBounceVertical = YES;
    
    self.restaurantShortDescLabel.text = self.restaurant.shortDesc;
    self.restaurantAddressLabel.text = self.restaurant.fullAddress;
    self.restaurantDistanceLabel.text = self.restaurant.distanceText;
    
    NSString *openingDateString = self.restaurant.openingDateText;
    NSString *openingHoursString = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Restaurant.HoursTitle", nil), self.restaurant.openingHoursText];
    
    self.restaurantInfoLabel.text = [NSString stringWithFormat:@"%@ · %@", openingDateString, openingHoursString];
    
    NSString *categoryString = @"";
    
    for (NSString *category in self.restaurant.type) {
        NSString *localizeString = [NSString stringWithFormat:@"Restaurant.Category.%@", category];
        if ([categoryString isEqualToString:@""]) {
            categoryString = NSLocalizedString(localizeString, nil);
        } else {
            categoryString = [NSString stringWithFormat:@"%@, %@", categoryString, NSLocalizedString(localizeString, nil)];
        }
    }
    
    self.restaurantCategoriesLabel.text = categoryString;
                       
    CGSize shortDescSize = [self.restaurantShortDescLabel sizeThatFits:CGSizeMake(self.restaurantShortDescLabel.width, 10000)];
    self.restaurantShortDescLabel.height = shortDescSize.height;
    self.restaurantShortDescLabel.numberOfLines = 0;
    self.restaurantInfoLabel.y = self.restaurantShortDescLabel.y + self.restaurantShortDescLabel.height + 6;
    self.restaurantCategoriesLabel.y = self.restaurantInfoLabel.y + self.restaurantInfoLabel.height - 4;
    self.lowerContent.y = self.restaurantCategoriesLabel.y + self.restaurantCategoriesLabel.height + 3;
    
    self.mapBoxShadowView.image = [[UIImage imageNamed:@"box-shadow"] stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    
    self.scrollView.contentSize = CGSizeMake(0, self.lowerContent.y + self.lowerContent.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(favoriteButtonPressed)];
    if (self.restaurant.favorite) {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon-star-full"];
    } else {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon-star-empty"];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.navigationController.view.layer.cornerRadius = 5;
        self.navigationController.view.clipsToBounds = YES;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.recognizerForModalDismiss == nil) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
        recognizer.cancelsTouchesInView = NO;
        [self.view.window addGestureRecognizer:recognizer];
        self.recognizerForModalDismiss = recognizer;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.recognizerForModalDismiss) {
        [self.recognizerForModalDismiss.view removeGestureRecognizer:self.recognizerForModalDismiss];
    }
    
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        CGPoint location = [sender locationInView:nil]; // Passing nil gives us coordinates in the window
        
        // Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        
        if (![self.navigationController.view pointInside:[self.navigationController.view convertPoint:location fromView:self.view.window] withEvent:nil]) {
            // Remove the recognizer first so it's view.window is valid.
            [self.view.window removeGestureRecognizer:sender];
            [self dismiss];
        }
    }
}

- (void)dismiss
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)favoriteButtonPressed
{
    if (self.restaurant.favorite) {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon-star-empty"];
        self.restaurant.favorite = NO;
        [self.dataSource removeFavorite:self.restaurant];
    } else {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon-star-full"];
        self.restaurant.favorite = YES;
        [self.dataSource addFavorite:self.restaurant];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Restaurant"
                                                          action:@"Toggle favorite"
                                                           label:self.restaurant.name
                                                           value:@(self.restaurant.favorite)] build]];
}

- (IBAction)mapButtonPressed:(id)sender
{
    RestaurantLocationViewController *viewController = [[RestaurantLocationViewController alloc] init];
    viewController.restaurant = self.restaurant;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
