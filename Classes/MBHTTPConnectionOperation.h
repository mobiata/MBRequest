//
//  MBHTTPConnectionOperation.h
//  MBRequest
//
//  Created by Sebastian Celis on 2/28/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBURLConnectionOperation.h"

@interface MBHTTPConnectionOperation : MBURLConnectionOperation

// A set of successful status codes. Defaults to 200-299.
@property (atomic, strong) NSIndexSet *successfulStatusCodes;

// Valid content types. If this is set, and if the response comes back with a different content
// type, the request will fail with error. Defaults to nil, which means to not validate the content
// type.
//
// This property is especially useful as it is very possible to get HTML back when behind a captive
// portal. Thus, just because your JSON request returns HTML doesn't mean that the APIs are broken.
// It could just mean that you user needs to login to their hotel WIFI.
@property (atomic, strong) NSSet *validContentTypes;

// The NSHTTPURLResponse associated with this operation. Overrides the parent's response
// property.
@property (atomic, strong, readonly) NSHTTPURLResponse *response;

@end
