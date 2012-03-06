//
//  MBHTTPRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/6/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBBaseRequest.h"
#import "MBHTTPConnectionOperation.h"

@interface MBHTTPRequest : MBBaseRequest

// The operation associated with the URL connection.
@property (nonatomic, retain, readonly) MBHTTPConnectionOperation *connectionOperation;

@end
