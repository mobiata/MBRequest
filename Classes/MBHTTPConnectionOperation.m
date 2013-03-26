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
@property (atomic, strong, readwrite) NSError *error;
@end


@implementation MBHTTPConnectionOperation

@dynamic error;
@synthesize successfulStatusCodes = _successfulStatusCodes;
@synthesize validContentTypes = _validContentTypes;

#pragma mark - Object Lifecycle

- (id)init
{
    if ((self = [super init]))
    {
        _successfulStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    }
    
    return self;
}


#pragma mark - Accessors

- (NSHTTPURLResponse *)response
{
    return (NSHTTPURLResponse *)[super response];
}

#pragma mark - Subclassing

- (void)handleResponse
{
    [super handleResponse];

    NSError *error = [self error];

    if ([self error] != nil)
    {
        if ([[error domain] isEqualToString:NSPOSIXErrorDomain])
        {
            if ([error code] == 22)
            {
                // A sketchy connection can cause a very unfriendly error message. Make it nicer.
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[error userInfo]];
                NSString *msg = MBRequestLocalizedString(@"unable_perform_request_check_internet_connection_try_again",
                                                         @"Unable to perform request. Please check your internet connection and try again.");
                [userInfo setObject:msg forKey:NSLocalizedDescriptionKey];
                [self setError:[NSError errorWithDomain:[error domain] code:[error code] userInfo:userInfo]];
            }
            else if ([error code] == 54)
            {
                // The operation couldn't be completed. Connection reset by peer.
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[error userInfo]];
                NSString *msg = MBRequestLocalizedString(@"connection_unexpectedly_lost_try_again",
                                                         @"The connection was unexpectedly lost. Please try again.");
                [userInfo setObject:msg forKey:NSLocalizedDescriptionKey];
                [self setError:[NSError errorWithDomain:[error domain] code:[error code] userInfo:userInfo]];
            }
        }
    }

    // Check for a bad status code.
    if ([self error] == nil)
    {
        NSHTTPURLResponse *response = [self response];
        NSInteger statusCode = [response statusCode];
        if (![[self successfulStatusCodes] containsIndex:statusCode])
        {
            NSString *format = MBRequestLocalizedString(@"request_unsuccessful_bad_status_code", @"Unable to perform request. An HTTP error occurred (%d).");
            NSString *msg = [NSString stringWithFormat:format, statusCode];
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
            [userInfo setObject:@(statusCode) forKey:@"statusCode"];
            NSError *innerError = [NSError errorWithDomain:MBRequestErrorDomain
                                                      code:MBRequestErrorCodeUnsuccessfulServerResponse
                                                  userInfo:userInfo];
            [self setError:innerError];
        }
    }

    // Check for captive portals or other invalid content types.
    if ([self error] == nil && [[self validContentTypes] count] > 0 && [[self responseData] length] > 0)
    {
        NSString *currentType = [[self response] MIMEType];
        if ([currentType length] && ![[self validContentTypes] containsObject:currentType])
        {
            NSString *msg;
            NSLog(@"Received content type '%@' when we expected %@.", currentType, [self validContentTypes]);
            if ([currentType isEqualToString:@"text/html"])
            {
                NSLog(@"Unexpected content type 'text/html' is often (but not always) due to a captive portal capturing all network requests and then trying to show a login form to the user.");
                msg = MBRequestLocalizedString(@"unable_perform_request_check_internet_connection_try_again",
                                               @"Unable to perform request. Please check your internet connection and try again.");
            }
            else
            {
                NSString *format = MBRequestLocalizedString(@"unexpected_content_type_received",
                                                            @"Unable to perform request. Unexpected content type received (%@).");
                msg = [NSString stringWithFormat:format, currentType];
            }

            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
            [self setError:[NSError errorWithDomain:MBRequestErrorDomain code:MBRequestErrorCodeUnsuccessfulServerResponse userInfo:userInfo]];
        }
    }
}

@end
