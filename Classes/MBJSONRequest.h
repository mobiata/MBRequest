//
//  MBJSONRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/4/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBBaseRequest.h"

@interface MBJSONRequest : MBBaseRequest

@property (atomic, retain, readonly) id responseJSON;

@end
