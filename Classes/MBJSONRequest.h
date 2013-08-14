//
//  MBJSONRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/4/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBHTTPRequest.h"

/**
 A basic callback for a JSON request that passes back the JSON data and any error that may have
 occurred.
 @param responseJSON The JSON data downloaded from the request. Will be an instance of NSArray or
 NSDictionary.
 @param error Any error that occurred during the request.
 */
typedef void (^MBJSONRequestCompletionHandler)(id responseJSON, NSError *error);

@interface MBJSONRequest : MBHTTPRequest

/**
 Performs a basic request and notifies the caller when the request finishes.
 @param request The NSURLRequest to perform.
 @param completionHandler A block to execute after the request finishes. This block will always run
 on the main thread.
 */
- (void)performJSONRequest:(NSURLRequest *)request completionHandler:(MBJSONRequestCompletionHandler)completionHandler;

/**
 The response data, parsed into a JSON object.
 */
@property (atomic, strong, readonly) id responseJSON;

/**
 The reading options to use when parsing the responseJSON. Defaults to 0.
 */
@property (atomic, assign) NSJSONReadingOptions JSONReadingOptions;

@end
