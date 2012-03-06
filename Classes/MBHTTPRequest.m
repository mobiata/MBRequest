//
//  MBHTTPRequest.m
//  MBRequest
//
//  Created by Sebastian Celis on 3/6/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBHTTPRequest.h"

#import "MBHTTPConnectionOperation.h"

@implementation MBHTTPRequest

@dynamic connectionOperation;

#pragma mark - Accessors

- (MBHTTPConnectionOperation *)connectionOperation
{
    if (_connectionOperation == nil)
    {
        _connectionOperation = [[MBHTTPConnectionOperation alloc] init];
        [_connectionOperation setDelegate:self];
    }

    return (MBHTTPConnectionOperation *)_connectionOperation;
}

@end
