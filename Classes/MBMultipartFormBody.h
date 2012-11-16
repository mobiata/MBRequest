//
//  MBMultipartFormBody.h
//  ExpediaBookings
//
//  Created by Ben Cochran on 11/8/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBMultipartFormBody : NSObject

- (NSData *)bodyData;
- (NSString *)boundary;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)appendJPEGImage:(UIImage *)image
                   name:(NSString *)name
               filename:(NSString *)filename;
- (void)appendPNGImage:(UIImage *)image
                  name:(NSString *)name
              filename:(NSString *)filename;
#endif

- (void)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name;

- (void)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                     mimetype:(NSString *)mimetype;

- (void)appendPartWithString:(NSString *)string
                        name:(NSString *)name;

- (void)appendPartWithNumber:(NSNumber *)number
                        name:(NSString *)name;

- (void)appendPartWithHeaders:(NSDictionary *)headers
                         data:(NSData *)data;

@end
