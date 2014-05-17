//
//  RestaurantDayViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 15.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "InfoViewController.h"

#import "Bulletin.h"
#import "HTTPClient.h"
#import "Info.h"

#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>

@interface InfoViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation InfoViewController

@synthesize dateTitleLabel;
@synthesize dateLabel;
@synthesize textBackgroundBox;
@synthesize newsDateLabel;
@synthesize newsContentLabel;
@synthesize activityIndicator;
@synthesize splashImageView;
@synthesize modalPresentation;

- (id)init
{
    self = [super initWithNibName:@"InfoViewController" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Restaurant Day";
    
    dateTitleLabel.text = NSLocalizedString(@"Info.NextRestaurantDayIs", @"");
    dateLabel.text = @"";
    newsDateLabel.text = @"";
    newsContentLabel.text = @"";
    textBackgroundBox.hidden = YES;
    dateLabel.width = 0;
    
    self.navigationController.navigationBarHidden = YES;
    dateLabel.layer.cornerRadius = 4;
    textBackgroundBox.layer.cornerRadius = 4;
    
    [self.feedbackButton setTitle:NSLocalizedString(@"Feedback", @"") forState:UIControlStateNormal];
    self.feedbackButton.layer.cornerRadius = 6;
    self.feedbackButton.enabled = [MFMailComposeViewController canSendMail];
    
    if (self.modalPresentation) {
        
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        self.splashImageView.alpha = 0;
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(removeFromSuperview)];
        [self.view addGestureRecognizer:recognizer];
    }
    
    [self refreshInfo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refreshInfo];
}

- (void)refreshInfo
{
    [[HTTPClient sharedInstance] getInfo:^(Info *info) {
        [self gotInfo:info];
    } failure:^(NSError *error) {
        [self failedToGetInfo];
    }];
}

- (void)gotInfo:(Info *)info
{
    [activityIndicator stopAnimating];
    
    NSDateFormatter *formatter = [NSDateFormatter dateFormatterWithFormat:@"d.M.YYYY"];
    dateLabel.text = [formatter stringFromDate:info.nextDate];
    CGSize dateSize = [dateLabel.text sizeWithFont:dateLabel.font];
    dateLabel.width = ceil(dateSize.width + 20.0f);
    if (dateLabel.width % 2 == 1) dateLabel.width += 1;
    dateLabel.x = 160 - dateLabel.width/2;
    
    if (info.bulletins.count > 0) {
        Bulletin *bulletin = [info.bulletins objectAtIndex:0];
        newsDateLabel.text = [formatter stringFromDate:bulletin.date];
        newsContentLabel.text = bulletin.text;
        
        CGSize neededSize = [bulletin.text sizeWithFont:newsContentLabel.font constrainedToSize:CGSizeMake(newsContentLabel.width, 80.0f) lineBreakMode:NSLineBreakByWordWrapping];
        textBackgroundBox.height = neededSize.height + 42.0f;
        newsContentLabel.height = neededSize.height;
        
        textBackgroundBox.hidden = NO;
    }
}

- (void)failedToGetInfo
{
    [activityIndicator stopAnimating];
    NSLog(@"Failed to get info :(");
}

- (IBAction)presentFeedbackComposer
{
	MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
	composer.mailComposeDelegate = self;
    composer.subject = NSLocalizedString(@"Feedback.Subject", @"");
	[composer setToRecipients:@[NSLocalizedString(@"Feedback.EmailAddress", @"")]];
    [composer setMessageBody:@"<strong>Pahkasika</strong> ei ole sika" isHTML:YES];
	[self presentViewController:composer animated:YES completion:nil];
}

#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error
{
    UIAlertView *alert;
	switch (result) {
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Feedback.MessageSent", @"")
											   message:NSLocalizedString(@"Feedback.ThankYou", @"")
											  delegate:self
									 cancelButtonTitle:NSLocalizedString(@"Feedback.Button.OKAfterSuccess", @"")
									 otherButtonTitles:nil];
            [alert show];
			break;
		case MFMailComposeResultFailed:
			alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Feedback.Error", @"")
											   message:NSLocalizedString(@"Feedback.SendingFailed", @"")
											  delegate:self
									 cancelButtonTitle:NSLocalizedString(@"Feedback.Button.OKAfterFailure", @"")
									 otherButtonTitles:nil];
			break;
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
