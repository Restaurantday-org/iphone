//
//  RestaurantDayViewController.m
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 15.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import "InfoViewController.h"

#import "RestaurantDay.h"

#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>

@interface InfoViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation InfoViewController

- (id)init
{
    self = [super initWithNibName:@"InfoViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Restaurant Day";
    
    self.dateTitleLabel.text = NSLocalizedString(@"Info.NextRestaurantDayIs", @"");
    self.dateLabel.text = @"";
    self.dateLabel.width = 0;
    
    self.navigationController.navigationBarHidden = YES;
    self.dateLabel.layer.cornerRadius = 4;
    
    [self.feedbackButton setTitle:NSLocalizedString(@"Feedback", @"") forState:UIControlStateNormal];
    self.feedbackButton.layer.cornerRadius = 6;
    self.feedbackButton.enabled = [MFMailComposeViewController canSendMail];
    
    if (self.modalPresentation) {
        
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        self.splashImageView.alpha = 0;
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(removeFromSuperview)];
        [self.view addGestureRecognizer:recognizer];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshInfo];
}

- (void)refreshInfo
{
    RestaurantDay *nextDay = [self.dataSource nextRestaurantDay];
    
    NSDateFormatter *formatter = [NSDateFormatter dateFormatterWithFormat:@"d.M.YYYY"];
    self.dateLabel.text = [formatter stringFromDate:nextDay.date];
    
    CGSize dateSize = [self.dateLabel sizeThatFits:CGSizeMake(320, 320)];
    self.dateLabel.width = ceil(dateSize.width + 20);
    self.dateLabel.x = (NSInteger) (160 - self.dateLabel.width / 2);
}

- (IBAction)presentFeedbackComposer
{
	MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
	composer.mailComposeDelegate = self;
    composer.subject = NSLocalizedString(@"Feedback.Subject", @"");
	[composer setToRecipients:@[NSLocalizedString(@"Feedback.EmailAddress", @"")]];
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
