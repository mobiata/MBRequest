//
//  MBNetworkActivityIndicatorManager.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/5/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBNetworkActivityIndicatorManager : NSObject

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

- (void)networkActivityStarted;
- (void)networkActivityStopped;

+ (MBNetworkActivityIndicatorManager *)sharedManager;

@end
