//
//  MBMultipartFormBody.m
//  ExpediaBookings
//
//  Created by Ben Cochran on 11/8/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBMultipartFormBody.h"

static NSString * const kMOMultipartFormBoundary = @"MOBoundary+M0b14t4+1234";

@interface MBMultipartFormBody ()
@property (nonatomic, readonly) NSMutableArray *parts;
@end

@implementation MBMultipartFormBody

@synthesize parts = _parts;

#pragma mark - Object Lifecycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _parts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_parts release];
    [super dealloc];
}

#pragma mark - Accessors

- (NSString *)boundary
{
    return kMOMultipartFormBoundary;
}

- (NSData *)bodyData
{
    NSMutableData *bodyData = [NSMutableData data];
    [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", kMOMultipartFormBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSInteger count = [[self parts] count];
    for (NSInteger i = 0 ; i < count; i++) {
        NSData *part = [[self parts] objectAtIndex:i];
        [bodyData appendData:part];
        if (i+1 < count) {
            [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", kMOMultipartFormBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kMOMultipartFormBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return bodyData;
}

#pragma mark - Appending parts

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)appendJPEGImage:(UIImage *)image
                   name:(NSString *)name
               filename:(NSString *)filename
{
    NSString *contentDisposition = [NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"",
                                    name,
                                    filename];
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             contentDisposition, @"Content-Disposition",
                             @"image/jpeg", @"Content-Type",
                             nil];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    [self appendPartWithHeaders:headers data:imageData];
}

- (void)appendPNGImage:(UIImage *)image
                  name:(NSString *)name
              filename:(NSString *)filename
{
    NSString *contentDisposition = [NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"",
                                    name,
                                    filename];
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             contentDisposition, @"Content-Disposition",
                             @"image/png", @"Content-Type",
                             nil];
    NSData *imageData = UIImagePNGRepresentation(image);
    [self appendPartWithHeaders:headers data:imageData];
}
#endif //__IPHONE_OS_VERSION_MIN_REQUIRED

- (void)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
{
    NSString *mimetype = nil;
#ifdef __UTTYPE__
    NSString *extension = [[fileURL lastPathComponent] pathExtension];
    CFStringRef UTITypeString = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)extension, NULL);
    mimetype = (NSString *)UTTypeCopyPreferredTagWithClass(UTITypeString, kUTTagClassMIMEType);
    CFRelease(UTITypeString);
#else
    mimetype = @"application/octet-stream";
#endif //__UTTYPE__
    
    [self appendPartWithFileURL:fileURL name:name mimetype:mimetype];
    [mimetype release];
}

- (void)appendPartWithFileURL:(NSURL *)fileURL
                         name:(NSString *)name
                     mimetype:(NSString *)mimetype
{
#if defined(DEBUG) || defined(ALPHA) || defined(BETA)
    NSAssert([fileURL isFileReferenceURL], @"File URL must be a file url.");
    NSAssert([fileURL checkResourceIsReachableAndReturnError:NULL], @"File URL cannot be read.");
#endif
    
    NSString *contentDisposition = [NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"",
                                    name,
                                    [fileURL lastPathComponent]];
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             contentDisposition, @"Content-Disposition",
                             mimetype, @"Content-Type",
                             nil];
    NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
    [self appendPartWithHeaders:headers data:fileData];
}

- (void)appendPartWithString:(NSString *)string
                        name:(NSString *)name
{
    NSString *contentDisposition = [NSString stringWithFormat:@"form-data; name=\"%@\"", name];
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             contentDisposition, @"Content-Disposition",
                             nil];
    [self appendPartWithHeaders:headers data:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)appendPartWithNumber:(NSNumber *)number
                        name:(NSString *)name
{
    [self appendPartWithString:[number stringValue] name:name];
}

- (void)appendPartWithHeaders:(NSDictionary *)headers
                         data:(NSData *)data
{
    NSMutableData *part = [[NSMutableData alloc] init];
    for (NSString *headerName in [headers allKeys])
    {
        NSString *headerValue = [headers objectForKey:headerName];
        NSString *headerChunk = [NSString stringWithFormat:@"%@: %@\r\n", headerName, headerValue];
        [part appendData:[headerChunk dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [part appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [part appendData:data];
    [self.parts addObject:part];
    [part release];
}

@end
