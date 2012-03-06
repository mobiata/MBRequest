//
//  MBRequestError.h
//  MBRequest
//
//  Created by Sebastian Celis on 2/28/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MBRequestErrorCodeUnknown = -1,
    MBRequestErrorCodeUnsuccessfulServerResponse = 1
} MBRequestErrorCode;

extern NSString * const MBRequestErrorDomain;
