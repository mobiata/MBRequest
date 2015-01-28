//
//  MBNetworkActivityIndicatorManager.m
//  MBRequest
//
//  Created by Sebastian Celis on 3/5/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBNetworkActivityIndicatorManager.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>
#endif


@interface MBNetworkActivityIndicatorManager ()
@property (nonatomic, assign) NSInteger networkActivityCounter;
@end


@implementation MBNetworkActivityIndicatorManager

#pragma mark - Object Lifecycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _enabled = YES;
    }
    
    return self;
}

+ (MBNetworkActivityIndicatorManager *)sharedManager
{
    static dispatch_once_t pred;
    static MBNetworkActivityIndicatorManager *singleton = nil;
    dispatch_once(&pred, ^{ singleton = [[self alloc] init]; });
    return singleton;
}

#pragma mark - Public Methods

- (void)networkActivityStarted
{
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && !defined(APPLICATION_EXTENSION_API_ONLY)
    if ([self isEnabled])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.networkActivityCounter == 0)
            {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            }
            self.networkActivityCounter = self.networkActivityCounter + 1;
        });
    }
#endif
}

- (void)networkActivityStopped
{
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && !defined(APPLICATION_EXTENSION_API_ONLY)
    if ([self isEnabled])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.networkActivityCounter == 1)
            {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
            self.networkActivityCounter = self.networkActivityCounter - 1;
        });
    }
#endif
}

@end
