//
//  MBMultipartFormData.m
//  MBRequest
//
//  Created by Ben Cochran on 11/8/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBMultipartFormData.h"

@interface MBMultipartFormData ()
@property (nonatomic, strong, readwrite) NSString *boundary;
@property (nonatomic, strong, readonly) NSMutableArray *parts;
@end


@implementation MBMultipartFormData

#pragma mark - Object Lifecycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _parts = [[NSMutableArray alloc] init];

        // Generate a random boundary string.
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        _boundary = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
        CFRelease(uuidObj);
    }

    return self;
}

#pragma mark - Accessors

- (NSData *)dataRepresentation
{
    NSMutableData *bodyData = [NSMutableData data];
    [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", [self boundary]] dataUsingEncoding:NSUTF8StringEncoding]];
    NSInteger count = [[self parts] count];
    for (NSInteger i = 0 ; i < count; i++)
    {
        NSData *part = [[self parts] objectAtIndex:i];
        [bodyData appendData:part];
        if (i + 1 < count)
        {
            [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", [self boundary]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", [self boundary]] dataUsingEncoding:NSUTF8StringEncoding]];
    return bodyData;
}

#pragma mark - Appending parts

- (void)appendPartWithString:(NSString *)string name:(NSString *)name
{
    NSString *contentDisposition = [NSString stringWithFormat:@"form-data; name=\"%@\"", name];
    NSDictionary *headers = @{@"Content-Disposition": contentDisposition};
    [self appendPartWithHeaders:headers data:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)appendPartWithNumber:(NSNumber *)number name:(NSString *)name
{
    [self appendPartWithString:[number stringValue] name:name];
}

- (void)appendPartWithFileURL:(NSURL *)fileURL name:(NSString *)name
{
    [self appendPartWithFileURL:fileURL name:name mimeType:nil];
}

- (void)appendPartWithFileURL:(NSURL *)fileURL name:(NSString *)name mimeType:(NSString *)mimeType
{
    if (![fileURL isFileReferenceURL])
    {
        NSLog(@"Unable to append multipart file. File not found: %@", fileURL);
        return;
    }

    NSError *error = nil;
    if (![fileURL checkResourceIsReachableAndReturnError:&error])
    {
        NSLog(@"Unable to append multipart file. File is not reachable: %@", fileURL);
        return;
    }

#ifdef __UTTYPE__
    if (mimeType == nil)
    {
        NSString *extension = [[fileURL lastPathComponent] pathExtension];
        CFStringRef UTITypeString = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
        mimetype = (NSString *)CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTITypeString, kUTTagClassMIMEType));
        CFRelease(UTITypeString);
    }
#endif
    if (mimeType == nil)
    {
        mimeType = @"application/octet-stream";
    }

    NSString *contentDisposition = [NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"", name, [fileURL lastPathComponent]];
    NSDictionary *headers = @{@"Content-Disposition": contentDisposition,
                              @"Content-Type": mimeType};
    NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
    [self appendPartWithHeaders:headers data:fileData];
}

- (void)appendJPEGImageData:(NSData *)data withName:(NSString *)name fileName:(NSString *)fileName
{
    NSString *contentDisposition = [NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"", name, fileName];
    NSDictionary *headers = @{@"Content-Disposition": contentDisposition,
                              @"Content-Type": @"image/jpeg"};
    [self appendPartWithHeaders:headers data:data];
}

- (void)appendPNGImageData:(NSData *)data withName:(NSString *)name fileName:(NSString *)fileName
{
    NSString *contentDisposition = [NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"", name, fileName];
    NSDictionary *headers = @{@"Content-Disposition": contentDisposition,
                              @"Content-Type": @"image/png"};
    [self appendPartWithHeaders:headers data:data];
}

- (void)appendPartWithHeaders:(NSDictionary *)headers data:(NSData *)data
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
    [[self parts] addObject:part];
}

@end
