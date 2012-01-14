//
//  ListViewController.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 14.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UITableViewController {
    
    NSArray *restaurants;
}

@property (strong) NSArray *restaurants;

@end
