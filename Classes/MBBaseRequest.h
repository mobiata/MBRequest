//
//  MBBaseRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 2/29/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBURLConnectionOperation.h"

// A basic callback for a request that passes back the data (if downloaded) and any error that
// may have occurred.
typedef void (^MBRequestDataCompletionHandler)(NSData *data, NSError *error);

// Callbacks for getting progress on upload or download operations.
typedef void (^MBRequestDownloadProgressCallback)(NSInteger bytes, NSInteger totalBytes, NSInteger totalBytesExpected);
typedef void (^MBRequestUploadProgressCallback)(NSInteger bytes, NSInteger totalBytes, NSInteger totalBytesExpected);


//__________________________________________________________________________________________________
// MBBaseRequest is a basic class for fully handling a network request. It performs the request (by
// using an MBURLConnectionOperation), parses the results, and is then responsible for notifying the
// original caller.
//
// You are encouraged to subclass this class (or MBJSONRequest or MBXMLRequest) for any specific
// requests that you want to support.

@interface MBBaseRequest : NSObject <MBURLConnectionOperationDelegate>
{
    MBURLConnectionOperation *_connectionOperation;
}

// Returns true if the request is currently active. This will be true as soon as the URL connection
// operation has been added to the queue and will remain true until the request is cancelled or
// completes.
@property (atomic, assign, readonly, getter=isRunning) BOOL running;

// Cancels the request. Once cancelled, you should not receive any callbacks (success or
// error) that relates to this request.
- (void)cancel;
@property (atomic, assign, readonly, getter=isCancelled) BOOL cancelled;

// Performs a basic request and notifies the caller with any data downloaded.
- (void)performBasicRequest:(NSURLRequest *)request completionHandler:(MBRequestDataCompletionHandler)completionHandler;

// The operation associated with the URL connection.
@property (nonatomic, retain, readonly) MBURLConnectionOperation *connectionOperation;

// An error associated with this request.
@property (atomic, retain, readonly) NSError *error;

// Basic callback that just handles basic NSData downloads.
@property (nonatomic, copy, readonly) MBRequestDataCompletionHandler dataCompletionHandler;

// Callbacks for upload and download progress.
@property (nonatomic, copy) MBRequestDownloadProgressCallback downloadProgressCallback;
@property (nonatomic, copy) MBRequestUploadProgressCallback uploadProgressCallback;

// Whether or not this request affects the global network activity indicator. Defaults to YES.
@property (nonatomic, assign) BOOL affectsNetworkActivityIndicator;

@end
