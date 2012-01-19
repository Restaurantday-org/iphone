//
//  CompanyViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "RestaurantViewController.h"
#import "RestaurantMapViewController.h"
#import "UIView+Extras.h"
#import "MyWebViewController.h"

@implementation RestaurantViewController

@synthesize restaurant;

@synthesize mapView;

@synthesize restaurantAddressLabel;
@synthesize restaurantSubtitle;
@synthesize restaurantNameLabel;
@synthesize restaurantShortDescLabel;
@synthesize scrollView;

@synthesize mapBoxShadowView;
@synthesize webview;

- (void)viewDidLoad
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [super viewDidLoad];
    
    UIView *titleView = [[UIView alloc] init];
    titleView.width = 160;
    titleView.height = 44;
    titleView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    UILabel *titleNameLabel = [[UILabel alloc] init];
    titleNameLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    titleNameLabel.x = 0;
    titleNameLabel.y = 0;
    titleNameLabel.width = 160;
    titleNameLabel.height = 44;
    titleNameLabel.text = restaurant.name;
    titleNameLabel.textColor = [UIColor whiteColor];
    titleNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0f];
    titleNameLabel.minimumFontSize = 13.0f;
    titleNameLabel.adjustsFontSizeToFitWidth = YES;
    titleNameLabel.textAlignment = UITextAlignmentCenter;
    titleNameLabel.numberOfLines = 2;
    [titleView addSubview:titleNameLabel];
    self.navigationItem.titleView = titleView;
    //self.title = restaurant.name;
    
    dataProvider = [[RestaurantDataProvider alloc] init];
    detailDataProvider = [[RestaurantDetailDataProvider alloc] init];
    detailDataProvider.delegate = self;
    
    [mapView setCenterCoordinate:restaurant.coordinate];
    [mapView setRegion:MKCoordinateRegionMake(restaurant.coordinate, MKCoordinateSpanMake(0.002f, 0.002f))];
    [mapView addAnnotation:restaurant];
    mapView.userInteractionEnabled = NO;
    scrollView.alwaysBounceVertical = YES;
    
    restaurantNameLabel.text = restaurant.name;
    restaurantShortDescLabel.text = restaurant.shortDesc;
    restaurantAddressLabel.text = restaurant.fullAddress;
    restaurantSubtitle.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Restaurant.HoursTitle", nil), restaurant.subtitle];
    
    mapBoxShadowView.image = [[UIImage imageNamed:@"box-shadow"] stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    
    webview.delegate = self;
    /*NSURL *webviewurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://golf-174.srv.hosting.fi:8080/mobileapi/restaurant/%d", restaurant.restaurantId]];
    
    [webview loadRequest:[NSURLRequest requestWithURL:webviewurl]];*/
    [detailDataProvider startGettingDetailsForRestaurantId:restaurant.restaurantId];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(favoriteButtonPressed)];
    if (restaurant.favorite) {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon-star-full"];
    } else {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon-star-empty"];

    }
}

- (void)viewDidUnload {
    
    [self setMapView:nil];
    [self setRestaurantNameLabel:nil];
    [self setRestaurantShortDescLabel:nil];
    [self setScrollView:nil];
    [self setRestaurantAddressLabel:nil];
    [self setRestaurantSubtitle:nil];
    [self setWebview:nil];
    [super viewDidUnload];
}

- (void)favoriteButtonPressed
{
    if (restaurant.favorite) {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon-star-empty"];
        [dataProvider unfavoriteRestaurant:[NSNumber numberWithInt:restaurant.restaurantId]];
        restaurant.favorite = NO;
    } else {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon-star-full"];
        [dataProvider favoriteRestaurant:[NSNumber numberWithInt:restaurant.restaurantId]];
        restaurant.favorite = YES;
    }
}

- (IBAction)mapButtonPressed:(id)sender {
    RestaurantMapViewController *viewController = [[RestaurantMapViewController alloc] init];
    viewController.restaurant = restaurant;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGSize size = [webview sizeThatFits:CGSizeMake(300, 10000)];
    webview.height = size.height;
    
    [self.scrollView setContentSize:CGSizeMake(320, size.height+270)];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        MyWebViewController *webViewController = [[MyWebViewController alloc] init];
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
    NSLog(@"html: %@", html);
    if (!error) {
        [self.webview loadHTMLString:html baseURL:nil];
    } else {
        NSLog(@"error with loading HTML: %@", error);
    }
}

@end
