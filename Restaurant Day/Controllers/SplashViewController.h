//
//  SplashViewController.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 15.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController {
}
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonview;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageview;
- (IBAction)closeButtonPressed:(id)sender;
@end
