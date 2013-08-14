//
//  MBHTTPRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/6/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBBaseRequest.h"
#import "MBHTTPConnectionOperation.h"

/**
 A basic callback for an HTTP request that passes back the raw data and any error that may have
 occurred.
 @param responseData The data downloaded during the request.
 @param error Any error that occurred during the request.
 */
typedef void (^MBHTTPRequestCompletionHandler)(NSData *responseData, NSError *error);

/**
 An MBBaseRequest subclass designed for working with HTTP requests.
 */
@interface MBHTTPRequest : MBBaseRequest

/**
 The NSOperation associated with the URL connection.
 */
@property (nonatomic, strong, readonly) MBHTTPConnectionOperation *connectionOperation;

/**
 Performs a basic request and notifies the caller when the request finishes.
 @param request The NSURLRequest to perform.
 @param completionHandler A block to execute after the request finishes. This block will always run
 on the main thread.
 */
- (void)performHTTPRequest:(NSURLRequest *)request completionHandler:(MBHTTPRequestCompletionHandler)completionHandler;

@end
