//
//  NSString+MBRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/1/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This category adds request-related methods to NSString.
 */
@interface NSString (MBRequest)

/**
 This method returns a URL-encoded version of this string. All appropriate characters will be
 URL-encoded (including & and ?).
 */
- (NSString *)mb_URLEncodedString;

@end
