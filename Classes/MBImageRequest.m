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
#if __IPHONE_OS_VERSION_MIN_REQUIRED
@property (atomic, strong, readwrite) UIImage *responseImage;
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
@property (atomic, strong, readwrite) NSImage *responseImage;
#endif
@property (nonatomic, copy, readwrite) MBImageRequestCompletionHandler imageCompletionHandler;
@end


@implementation MBImageRequest

#pragma mark - Request

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (id)init
{
    self = [super init];
    if (self)
    {
        _scale = 1.0f;
    }
    
    return self;
}
#endif

- (void)performImageRequest:(NSURLRequest *)request completionHandler:(MBImageRequestCompletionHandler)completionHandler
{
    [[self connectionOperation] setRequest:request];
    [self setImageCompletionHandler:completionHandler];
    [self scheduleOperation];
}

#pragma mark - Response

- (void)parseResults
{
    [super parseResults];

    if ([self error] == nil)
    {
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        UIImage *image = [[UIImage alloc] initWithData:[[self connectionOperation] responseData] scale:[self scale]];
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
        NSImage *image = [[NSImage alloc] initWithData:[[self connectionOperation] responseData]];
#endif
        [self setResponseImage:image];
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
        [self imageCompletionHandler]([self responseImage], [self error]);
    }
}

@end
