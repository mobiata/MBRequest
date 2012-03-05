//
//  MBHTTPConnectionOperation.m
//  MBRequest
//
//  Created by Sebastian Celis on 2/28/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBHTTPConnectionOperation.h"

#import "MBRequestError.h"
#import "MBRequestLocalization.h"
#import "MBURLConnectionOperationSubclass.h"

@interface MBHTTPConnectionOperation ()
@property (atomic, retain, readwrite) NSError *error;
@end


@implementation MBHTTPConnectionOperation

@dynamic error;
@synthesize delegate = _delegate;
@synthesize successfulStatusCodes = _successfulStatusCodes;

#pragma mark - Object Lifecycle

- (id)init
{
    if ((self = [super init]))
    {
        _successfulStatusCodes = [[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)] retain];
    }
    
    return self;
}

- (void)dealloc
{
    [_successfulStatusCodes release];
    [super dealloc];
}

#pragma mark - Accessors

- (NSHTTPURLResponse *)response
{
    return (NSHTTPURLResponse *)[super response];
}

#pragma mark - Subclassing

- (void)handleResponse
{
    @synchronized (self)
    {
        [super handleResponse];
        
        if ([self error] == nil)
        {
            NSHTTPURLResponse *response = [self response];
            NSInteger statusCode = [response statusCode];
            if (![[self successfulStatusCodes] containsIndex:statusCode])
            {
                NSString *format = MBRequestLocalizedString(@"request_unsuccessful_bad_status_code", @"Request failed (status code %d)");
                NSString *msg = [NSString stringWithFormat:format, statusCode];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:MBRequestErrorDomain
                                                     code:MBRequestErrorCodeUnsuccessfulServerResponse
                                                 userInfo:userInfo];
                [self setError:error];
            }
        }
    }
}

@end
