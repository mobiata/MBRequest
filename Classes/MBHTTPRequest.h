//
//  MBHTTPRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/6/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBBaseRequest.h"
#import "MBHTTPConnectionOperation.h"

// A basic callback for an HTTP request that passes back the raw data and any error that
// may have occurred.
typedef void (^MBHTTPRequestCompletionHandler)(NSData *responseData, NSError *error);

@interface MBHTTPRequest : MBBaseRequest

// The operation associated with the URL connection.
@property (nonatomic, retain, readonly) MBHTTPConnectionOperation *connectionOperation;

// Performs a basic request and notifies the caller with any data downloaded.
- (void)performHTTPRequest:(NSURLRequest *)request completionHandler:(MBHTTPRequestCompletionHandler)completionHandler;

@end
