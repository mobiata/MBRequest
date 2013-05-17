//
//  NSString+MBRequest.m
//  MBRequest
//
//  Created by Sebastian Celis on 3/1/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "NSString+MBRequest.h"

@implementation NSString (MBRequest)

- (NSString *)mb_URLEncodedString
{
    NSString *s = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                        (CFStringRef)self,
                                                                                        NULL,
                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                        kCFStringEncodingUTF8));
    return s;
}

@end
