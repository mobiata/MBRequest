//
//  MBMultipartFormData.h
//  MBRequest
//
//  Created by Ben Cochran on 11/8/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBMultipartFormData : NSObject

@property (nonatomic, strong, readonly) NSString *boundary;

- (NSData *)dataRepresentation;

- (void)appendPartWithString:(NSString *)string
                        name:(NSString *)name;
- (void)appendPartWithNumber:(NSNumber *)number
                        name:(NSString *)name;

- (void)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name;
- (void)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                     mimeType:(NSString *)mimeType;

- (void)appendJPEGImageData:(NSData *)data
                   withName:(NSString *)name
                   fileName:(NSString *)fileName;
- (void)appendPNGImageData:(NSData *)data
                  withName:(NSString *)name
                  fileName:(NSString *)fileName;

- (void)appendPartWithHeaders:(NSDictionary *)headers
                         data:(NSData *)data;

@end
