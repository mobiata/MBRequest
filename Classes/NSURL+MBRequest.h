//
//  NSURL+MBRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/1/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This category adds request-related methods to NSURL.
 */
@interface NSURL (MBRequest)

/**
 This class method returns a URL generated from a baseString and a dictionary of URL parameters.
 @param baseString The base string of the URL. This string may include some URL parameters which
 have already been properly encoded.
 @param params Additional parameters to be appended to the baseString of the URL.
 */
+ (NSURL *)mb_URLWithBaseString:(NSString *)baseString parameters:(NSDictionary *)params;

@end
