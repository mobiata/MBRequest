//
//  MBHTTPRequest.m
//  MBRequest
//
//  Created by Sebastian Celis on 3/6/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBHTTPRequest.h"
#import "MBBaseRequestSubclass.h"

#import "MBHTTPConnectionOperation.h"

@interface MBHTTPRequest ()
@property (nonatomic, copy, readwrite) MBRequestHTTPCompletionHandler HTTPCompletionHandler;
@end

@implementation MBHTTPRequest

@dynamic connectionOperation;
@synthesize HTTPCompletionHandler = _HTTPCompletionHandler;

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [_HTTPCompletionHandler release];
    [super dealloc];
}

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

#pragma mark - Request

- (void)performHTTPRequest:(NSURLRequest *)request
         completionHandler:(MBRequestHTTPCompletionHandler)completionHandler
{
    [[self connectionOperation] setRequest:request];
    [self setHTTPCompletionHandler:completionHandler];
    [self scheduleOperation];
}

- (void)notifyCaller
{
    [super notifyCaller];
    
    if ([self HTTPCompletionHandler] != nil)
    {
        [self HTTPCompletionHandler]([[self connectionOperation] responseData], [self error]);
    }
}

@end
