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
typedef void (^MBImageRequestCompletionHandler)(UIImage *image, NSError *error);
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
typedef void (^MBImageRequestCompletionHandler)(NSImage *image, NSError *error);
#endif

@interface MBImageRequest : MBHTTPRequest

// Performs a basic request and notifies the caller with any data downloaded.
- (void)performImageRequest:(NSURLRequest *)request completionHandler:(MBImageRequestCompletionHandler)completionHandler;

// The image returned in the response.
#if __IPHONE_OS_VERSION_MIN_REQUIRED
@property (atomic, strong, readonly) UIImage *responseImage;
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
@property (atomic, retain, readonly) NSImage *responseImage;
#endif

@end
