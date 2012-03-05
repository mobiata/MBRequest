//
//  MBBaseRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 2/29/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBURLConnectionOperation.h"

typedef void (^MBRequestDownloadProgressCallback)(NSInteger bytes, NSInteger totalBytes, NSInteger totalBytesExpected);
typedef void (^MBRequestUploadProgressCallback)(NSInteger bytes, NSInteger totalBytes, NSInteger totalBytesExpected);

@interface MBBaseRequest : NSObject <MBURLConnectionOperationDelegate>

// Returns true if the request is currently active. This will be true as soon as the URL connection
// operation has been added to the queue and will remain true until the request is cancelled or
// completes.
@property (atomic, assign, readonly, getter=isRunning) BOOL running;

// Cancels the request. Once cancelled, you should not receive any callbacks (success or
// error) that relates to this request.
- (void)cancel;
- (BOOL)isCancelled;

// The operation associated with the URL connection.
@property (atomic, retain, readonly) MBURLConnectionOperation *connectionOperation;

// An error associated with this request.
@property (atomic, retain, readonly) NSError *error;

// Callbacks for upload and download progress.
@property (atomic, copy) MBRequestDownloadProgressCallback downloadProgressCallback;
@property (atomic, copy) MBRequestUploadProgressCallback uploadProgressCallback;

// Whether or not this request affects the global network activity indicator. Defaults to YES.
@property (atomic, assign) BOOL affectsNetworkActivityIndicator;

@end
