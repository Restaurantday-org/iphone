//
//  InfoDataProvider.h
//  Restaurant Day
//
//  Created by Kimmo Kärkkäinen on 16.1.2012.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASINetworkQueue.h"
#import "Info.h"

@protocol InfoDataProviderDelegate <NSObject>
- (void)gotInfo:(Info *)info;
- (void)failedToGetInfo;
@end

@interface InfoDataProvider : NSObject {
    ASINetworkQueue *queue;
}

@property (nonatomic, unsafe_unretained) id<InfoDataProviderDelegate> delegate;

- (void)startLoadingInfo;

@end
