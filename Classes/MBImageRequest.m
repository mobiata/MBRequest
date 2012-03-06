//
//  MBImageRequest.m
//  MBRequest
//
//  Created by Sebastian Celis on 3/6/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBImageRequest.h"

#import "MBBaseRequestSubclass.h"
#import "MBRequestError.h"
#import "MBRequestLocalization.h"

@interface MBImageRequest ()
@property (atomic, retain, readwrite) NSError *error;
#if __IPHONE_OS_VERSION_MIN_REQUIRED
@property (nonatomic, retain) UIImage *responseImage;
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
@property (nonatomic, retain) NSImage *responseImage;
#endif
@end


@implementation MBImageRequest

@dynamic error;
@synthesize imageCompletionHandler = _imageCompletionHandler;
@synthesize responseImage = _responseImage;

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [_imageCompletionHandler release];
    [super dealloc];
}

#pragma mark - Response

- (void)parseResults
{
    [super parseResults];

    if ([self error] == nil)
    {
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        UIImage *image = [[UIImage alloc] initWithData:[[self connectionOperation] responseData]];
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
        NSImage *image = [[NSImage alloc] initWithData:[[self connectionOperation] responseData]];
#endif
        [self setResponseImage:image];
        [image release];
    }

    if ([self error] == nil && [self responseImage] == nil)
    {
        // There was an error parsing this image, or none was returned by the server.
        NSString *msg = MBRequestLocalizedString(@"request_unsuccessful_could_not_download_image", @"Request failed. Unable to download image.");
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:MBRequestErrorDomain
                                             code:MBRequestErrorCodeUnsuccessfulServerResponse
                                         userInfo:userInfo];
        [self setError:error];
    }
}

- (void)notifyCaller
{
    [super notifyCaller];

    if ([self imageCompletionHandler] != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![self isCancelled])
            {
                [self imageCompletionHandler]([self responseImage], [self error]);
            }
        });
    }
}

@end
