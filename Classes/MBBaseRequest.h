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
typedef void (^MBBaseRequestCompletionHandler)(NSData *data, NSError *error);

// Callbacks for getting progress on upload or download operations.
typedef void (^MBRequestDownloadProgressCallback)(NSUInteger bytes, NSUInteger totalBytes, long long totalBytesExpected);
typedef void (^MBRequestUploadProgressCallback)(NSUInteger bytes, NSUInteger totalBytes, long long totalBytesExpected);


//__________________________________________________________________________________________________
// MBBaseRequest is a basic class for fully handling a network request. It performs the request (by
// using an MBURLConnectionOperation), parses the results, and is then responsible for notifying the
// original caller.
//
// You are encouraged to subclass this class (or MBJSONRequest or MBXMLRequest) for any specific
// requests that you want to support.

@interface MBBaseRequest : NSObject <MBURLConnectionOperationDelegate>

// Returns true if the request is currently active. This will be true as soon as the URL connection
// operation has been added to the queue and will remain true until the request is cancelled or
// completes.
@property (atomic, assign, readonly, getter=isRunning) BOOL running;

// Cancels the request. Once cancelled, you should not receive any callbacks (success or
// error) that relates to this request.
- (void)cancel;
@property (atomic, assign, readonly, getter=isCancelled) BOOL cancelled;

// Performs a basic request and notifies the caller with any data downloaded.
- (void)performBasicRequest:(NSURLRequest *)request completionHandler:(MBBaseRequestCompletionHandler)completionHandler;

// The operation associated with the URL connection.
@property (nonatomic, strong, readonly) MBURLConnectionOperation *connectionOperation;

// An error associated with this request.
@property (atomic, strong, readonly) NSError *error;

// Callbacks for upload and download progress.
@property (nonatomic, copy) MBRequestDownloadProgressCallback downloadProgressCallback;
@property (nonatomic, copy) MBRequestUploadProgressCallback uploadProgressCallback;

// Whether or not this request affects the global network activity indicator. Defaults to YES.
@property (nonatomic, assign) BOOL affectsNetworkActivityIndicator;

// Percent complete for download and upload progress. Values between 0.0 and 1.0 tell completion
// percentages. Values are -1.0 before request is started or after a request is canceled.
@property (atomic, assign) double downloadProgress;
@property (atomic, assign) double uploadProgress;

// Custom operation queue for this request. If not set, the sharedOperationQueue is used. 
@property (nonatomic, strong, readwrite) NSOperationQueue *operationQueue;

// Shared operation queue used by default for all MBBaseRequests.
+ (NSOperationQueue *)sharedOperationQueue;

@end
