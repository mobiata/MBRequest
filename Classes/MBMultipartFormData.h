//
//  MBMultipartFormData.h
//  MBRequest
//
//  Created by Ben Cochran on 11/8/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 MBMultipartFormData is a helper class that can be used for constructing multipart form data to send
 to servers.

 http://tools.ietf.org/html/rfc2388
 */
@interface MBMultipartFormData : NSObject

/**
 The boundary string to use in the multipart form data. Defaults to a random GUID.
 */
@property (nonatomic, strong, readonly) NSString *boundary;

/**
 Returns the NSData representation of the multipart form data.
 */
- (NSData *)dataRepresentation;

/**
 Appends a string to the multipart form data.
 @param string The string to append.
 @param name The name of the string to append.
 */
- (void)appendPartWithString:(NSString *)string name:(NSString *)name;

/**
 Appends a number to the multipart form data.
 @param number The number to append.
 @param name The name of the number to append.
 */
- (void)appendPartWithNumber:(NSNumber *)number name:(NSString *)name;

/**
 Appends a file to the multipart form data. Calls appendPartWithFileURL:name:mimeType: with a nil
 mimeType.
 @param fileURL A URL to a file on the local filesystem to append.
 @param name The name of the file to append.
 */
- (void)appendPartWithFileURL:(NSURL *)fileURL name:(NSString *)name;

/**
 Appends a file to the multipart form data.
 @param fileURL A URL to a file on the local filesystem to append.
 @param name The name of the file to append.
 @param mimeType The mimeType for this file. If set to nil, the system will attempt to determine
 the best mimeType to use. If one cannot be determined, "application/octet-stream" will be used.
 */
- (void)appendPartWithFileURL:(NSURL *)fileURL name:(NSString *)name mimeType:(NSString *)mimeType;

/**
 Appends JPEG image data to the multipart form data.
 @param data The data to append. Can be generated with UIImageJPEGRepresentation on iOS.
 @param name The name of the data to append.
 @param fileName A filename to use for the data.
 */
- (void)appendJPEGImageData:(NSData *)data withName:(NSString *)name fileName:(NSString *)fileName;

/**
 Appends PND image data to the multipart form data.
 @param data The data to append. Can be generated with UIImagePNGRepresentation on iOS.
 @param name The name of the data to append.
 @param fileName A filename to use for the data.
 */
- (void)appendPNGImageData:(NSData *)data withName:(NSString *)name fileName:(NSString *)fileName;

/**
 Appends generic data to the multipart form data.
 @param headers The headers for this particular chunk of data.
 @param data The data to append.
 */
- (void)appendPartWithHeaders:(NSDictionary *)headers data:(NSData *)data;

@end
