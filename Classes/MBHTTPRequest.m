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
@property (nonatomic, copy, readwrite) MBHTTPRequestCompletionHandler HTTPCompletionHandler;
@end

@implementation MBHTTPRequest

@dynamic connectionOperation;

#pragma mark - Accessors

- (MBURLConnectionOperation *)createConnectionOperation
{
    return [[MBHTTPConnectionOperation alloc] init];
}

#pragma mark - Request

- (void)performHTTPRequest:(NSURLRequest *)request
         completionHandler:(MBHTTPRequestCompletionHandler)completionHandler
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
