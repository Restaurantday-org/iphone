//
//  InfoDataParser.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 16.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Info.h"

@interface InfoDataParser : NSObject

- (Info *)parseInfoDataFromJson:(NSString *)json;

@end
