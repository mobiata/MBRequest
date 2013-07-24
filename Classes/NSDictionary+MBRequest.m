//
//  NSDictionary+MBRequest.m
//  MBRequest
//
//  Created by Sebastian Celis on 3/1/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "NSDictionary+MBRequest.h"

#import "NSString+MBRequest.h"

@implementation NSDictionary (MBRequest)

- (NSString *)mb_URLParameterString
{
    if ([self count] == 0)
    {
        return @"";
    }

    NSMutableString *urlString = [[NSMutableString alloc] init];

    BOOL appendAmp = NO;    
    for (NSString *key in self)
    {
        if ([[self objectForKey:key] isKindOfClass:[NSArray class]]) 
        {
            NSArray *array = [self objectForKey:key];
            for (NSString *value in array)
            {
                if (appendAmp)
                {
                    [urlString appendString:@"&"];
                }
                else
                {
                    appendAmp = YES;
                }

                [urlString appendString:[key mb_URLEncodedString]];
                [urlString appendString:@"="];
                [urlString appendString:[value mb_URLEncodedString]];
            }
        }
        else 
        {
            if (appendAmp)
            {
                [urlString appendString:@"&"];
            }
            else
            {
                appendAmp = YES;
            }

            [urlString appendString:[key mb_URLEncodedString]];
            [urlString appendString:@"="];
            [urlString appendString:[[self objectForKey:key] mb_URLEncodedString]];;
        }
    }

    return urlString;
}

@end
