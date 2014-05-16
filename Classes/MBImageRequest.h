//
//  MBImageRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/6/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
#import <Cocoa/Cocoa.h>
#endif

#import "MBHTTPRequest.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED
/**
 A basic callback for an image request that passes back the image data and any error that may have
 occurred.
 @param image The image downloaded from the request.
 @param error Any error that occurred during the request.
 */
typedef void (^MBImageRequestCompletionHandler)(UIImage *image, NSError *error);
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
/**
 A basic callback for an image request that passes back the image data and any error that may have
 occurred. This completion handler is always executed on the main thread.
 @param image The image downloaded from the request.
 @param error Any error that occurred during the request.
 */
typedef void (^MBImageRequestCompletionHandler)(NSImage *image, NSError *error);
#endif

/**
 An MBBaseRequest subclass designed for downloading image data.
 */
@interface MBImageRequest : MBHTTPRequest

/**
 Performs a basic request and notifies the caller when the request finishes.
 @param request The NSURLRequest to perform.
 @param completionHandler A block to execute after the request finishes. This block will always run
 on the main thread.
 */
- (void)performImageRequest:(NSURLRequest *)request completionHandler:(MBImageRequestCompletionHandler)completionHandler;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
/**
 The image returned in the response.
 */
@property (atomic, strong, readonly) UIImage *responseImage;
/**
 The scale of the image returned in the response.
 */
@property (nonatomic, assign) CGFloat scale;
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
/**
 The image returned in the response.
 */
@property (atomic, strong, readonly) NSImage *responseImage;
#endif

@end
