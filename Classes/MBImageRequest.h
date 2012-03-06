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
typedef void (^MBRequestImageCompletionHandler)(UIImage *image, NSError *error);
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
typedef void (^MBRequestImageCompletionHandler)(NSImage *image, NSError *error);
#endif

@interface MBImageRequest : MBHTTPRequest

@property (nonatomic, copy, readonly) MBRequestImageCompletionHandler imageCompletionHandler;

@end
