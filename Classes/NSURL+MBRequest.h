//
//  NSURL+MBRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/1/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (MBRequest)

+ (NSURL *)mb_URLWithBaseString:(NSString *)baseString parameters:(NSDictionary *)params;

@end
