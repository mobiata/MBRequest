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
@synthesize HTTPCompletionHandler = _httpCompletionHandler;

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [_httpCompletionHandler release];
    [super dealloc];
}

#pragma mark - Accessors

- (MBURLConnectionOperation *)createConnectionOperation
{
    MBHTTPConnectionOperation *op = [[MBHTTPConnectionOperation alloc] init];
    return [op autorelease];
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
