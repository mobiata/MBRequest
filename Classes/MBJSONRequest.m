//
//  MBJSONRequest.m
//  MBRequest
//
//  Created by Sebastian Celis on 3/4/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBJSONRequest.h"

#import "MBBaseRequestSubclass.h"
#import "MBJSON.h"

@interface MBJSONRequest ()
@property (atomic, retain, readwrite) NSError *error;
@property (atomic, retain, readwrite) id responseJSON;
@end


@implementation MBJSONRequest

@dynamic error;
@synthesize responseJSON = _responseJSON;

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [_responseJSON release];
    [super dealloc];
}

#pragma mark - Response

- (void)connectionOperationDidFinish
{
    [super connectionOperationDidFinish];

    if ([self error] == nil && ![self isCancelled])
    {
        NSError *error = nil;
        id obj = MBJSONObjectFromData([[self connectionOperation] responseData], &error);
        if (error != nil)
        {
            [self setError:error];
        }
        else
        {
            [self setResponseJSON:obj];
        }
    }
}

@end
