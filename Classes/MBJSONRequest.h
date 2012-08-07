//
//  MBJSONRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/4/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBHTTPRequest.h"

// A basic callback for a JSON request that passes back the parsed data and any error that
// may have occurred.
typedef void (^MBJSONRequestCompletionHandler)(id responseJSON, NSError *error);

@interface MBJSONRequest : MBHTTPRequest

// Performs a basic request and notifies the caller with any data downloaded.
- (void)performJSONRequest:(NSURLRequest *)request completionHandler:(MBJSONRequestCompletionHandler)completionHandler;

// The response data, parsed into a JSON object.
@property (atomic, retain, readonly) id responseJSON;

@end
