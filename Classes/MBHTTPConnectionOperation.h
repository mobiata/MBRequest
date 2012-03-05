//
//  MBHTTPConnectionOperation.h
//  MBRequest
//
//  Created by Sebastian Celis on 2/28/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBURLConnectionOperation.h"

@interface MBHTTPConnectionOperation : MBURLConnectionOperation

@property (atomic, retain) NSIndexSet *successfulStatusCodes;
@property (atomic, retain, readonly) NSHTTPURLResponse *response;

@end
