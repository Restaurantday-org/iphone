//
//  CompanyViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantViewController.h"

#import "HTTPClient.h"
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
    NSString *capacityString = [NSString stringWithFormat:NSLocalizedString(@"Restaurant.CapacityTitle", nil), self.restaurant.capacity];
    
    self.restaurantInfoLabel.text = [NSString stringWithFormat:@"%@ · %@ · %@", openingDateString, openingHoursString, capacityString];
    
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
                       
    CGSize shortDescSize = [self.restaurant.shortDesc sizeWithFont:self.restaurantShortDescLabel.font constrainedToSize:CGSizeMake(self.restaurantShortDescLabel.width, 10000) lineBreakMode:NSLineBreakByWordWrapping];
    self.restaurantShortDescLabel.height = shortDescSize.height;
    self.restaurantShortDescLabel.numberOfLines = 0;
    self.restaurantInfoLabel.y = self.restaurantShortDescLabel.y + self.restaurantShortDescLabel.height + 6;
    self.restaurantCategoriesLabel.y = self.restaurantInfoLabel.y + self.restaurantInfoLabel.height - 4;
    self.lowerContent.y = self.restaurantCategoriesLabel.y + self.restaurantCategoriesLabel.height + 3;
    
    self.mapBoxShadowView.image = [[UIImage imageNamed:@"box-shadow"] stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    
    self.webview.delegate = self;
    
    [[HTTPClient sharedInstance] getDetailsForRestaurant:self.restaurant success:^(NSString *details) {
        [self gotDetails:details];
    } failure:^(NSError *error) {
        
    }];
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

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGSize size = [webView sizeThatFits:CGSizeMake(300, 10000)];
    webView.height = size.height;
    
    [self.scrollView setContentSize:CGSizeMake(320, size.height + webView.y + self.lowerContent.y + 20)];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        WebViewController *webViewController = [[WebViewController alloc] init];
        webViewController.request = request;
        [self.navigationController pushViewController:webViewController animated:YES];
        return NO;
    }
    
    return YES;
}

- (void)gotDetails:(NSString *)details
{
    //details = [details stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
    NSError *error;
    NSString *css = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"restaurantDescription" ofType:@"css"] encoding:NSUTF8StringEncoding error:&error];
    NSString *html = [NSString stringWithFormat:@"<html><head><style type='text/css'>%@</style></head><body>%@</body></html>", css, details];
    //NSLog(@"html: %@", html);
    if (!error) {
        [self.webview loadHTMLString:html baseURL:nil];
    } else {
        NSLog(@"error with loading HTML: %@", error);
    }
}

@end
