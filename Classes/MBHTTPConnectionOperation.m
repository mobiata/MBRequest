//
//  MBHTTPConnectionOperation.m
//  MBRequest
//
//  Created by Sebastian Celis on 2/28/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBHTTPConnectionOperation.h"

#import "MBRequestLocalization.h"
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

        NSError *error = [self error];

        // A sketchy connection can cause a very unfriendly error message. Make it nicer.
        if ([self error] != nil)
        {
            if ([[error domain] isEqualToString:NSPOSIXErrorDomain] && [error code] == 22)
            {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[error userInfo]];
                NSString *msg = MBRequestLocalizedString(@"unable_perform_request_check_internet_connection_try_again",
                                                         @"Unable to perform request. Please check your internet connection and try again.");
                [userInfo setObject:msg forKey:NSLocalizedDescriptionKey];
                [self setError:[NSError errorWithDomain:[error domain] code:[error code] userInfo:userInfo]];
            }
        }

        // Check for a bad status code.
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
