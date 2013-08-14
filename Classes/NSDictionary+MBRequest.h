//
//  NSDictionary+MBRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/1/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This category adds request-related methods to NSDictionary.
 */
@interface NSDictionary (MBRequest)

/**
 Given a dictionary of key-value pairs, this method will return a URL query string, with URL-encoded
 keys and values. The returned string will start with a key (and not an & or a ?). The keys in this
 dictionary must be instances of NSString. The values in this dictionary must be instances of
 NSString or an NSArray of NSStrings. If this method is called on an empty dictionary, an empty
 string will be returned.
 */
- (NSString *)mb_URLParameterString;

@end
