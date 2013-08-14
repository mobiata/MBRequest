//
//  MBBaseRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 2/29/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBURLConnectionOperation.h"

/**
 A final completion handler for the network request.
 @param data The data that was downloaded from the request.
 @param error Any error that occurred when making the request.
 @see -[MBBaseRequest performBasicRequest:completionHandler:]
 */
typedef void (^MBBaseRequestCompletionHandler)(NSData *data, NSError *error);

/**
 A callback block that gets called intermittendly while bytes are received during an MBRequest URL
 connection. This can be used to show a progress indicator during a large download.
 @param bytes The number of bytes that were just read.
 @param totalBytes The total number of bytes that have been read.
 @param totalBytesExpected The total number of bytes expected from this particular connection. Will
 only be set to greater than 0 if the server supplied the necessary information.
 @see -[MBBaseRequest downloadProgressCallback]
 */
typedef void (^MBRequestDownloadProgressCallback)(NSUInteger bytes, NSUInteger totalBytes, long long totalBytesExpected);

/**
 A callback block that gets called intermittendly while bytes are sent during an MBRequest URL
 connection. This can be used to show a progress indicator during a large upload.
 @param bytes The number of bytes that were just written.
 @param totalBytes The total number of bytes that have been written.
 @param totalBytesExpected The total number of bytes the connection is expected to write.
 @see -[MBBaseRequest uploadProgressCallback]
 */
typedef void (^MBRequestUploadProgressCallback)(NSUInteger bytes, NSUInteger totalBytes, long long totalBytesExpected);


/**
 MBBaseRequest is a basic class for fully handling a network request. It performs the request (by
 using an MBURLConnectionOperation), parses the results, and is then responsible for notifying the
 original caller.

 You are encouraged to subclass this class (or MBHTTPRequest, MBJSONRequest, or MBXMLRequest) for
 any specific requests that you want to support in your application.
 */
@interface MBBaseRequest : NSObject <MBURLConnectionOperationDelegate>

/**
 Returns YES if the request is currently active. This will be true as soon as the URL connection
 operation has been added to the queue and will remain true until the request is cancelled or
 completes.
 */
@property (atomic, assign, readonly, getter=isRunning) BOOL running;

/**
 Cancels the request. Once cancelled, you should not receive any callbacks (success or error) that
 relates to this request. Calling cancel on an operation that is not running will do nothing.
 */
- (void)cancel;

/**
 Returns YES if the request has been cancelled.
 */
@property (atomic, assign, readonly, getter=isCancelled) BOOL cancelled;

/**
 Performs a basic request and notifies the caller.
 @param request The NSURLRequest to perform.
 @param completionHandler A block to execute after the request finishes. This block will always run
 on the main thread.
 */
- (void)performBasicRequest:(NSURLRequest *)request completionHandler:(MBBaseRequestCompletionHandler)completionHandler;

/**
 The NSOperation associated with the URL connection.
 */
@property (nonatomic, strong, readonly) MBURLConnectionOperation *connectionOperation;

/**
 An error associated with this request.
 */
@property (atomic, strong, readonly) NSError *error;

/**
 A callback block to be called as the request downloads data. This block will always run on the main
 thread.
 */
@property (nonatomic, copy) MBRequestDownloadProgressCallback downloadProgressCallback;

/**
 A callback block to be called as the request uploads data. This block will always run on the main
 thread.
 */
@property (nonatomic, copy) MBRequestUploadProgressCallback uploadProgressCallback;

/**
 A property that determines whether or not this request affects the global network activity
 indicator. Defaults to YES.
 */
@property (nonatomic, assign) BOOL affectsNetworkActivityIndicator;

/**
 The percent complete for download progress. The value will be between 0.0 and 1.0 while the request
 is in progress and after it completes. The value will be -1.0 before the request is started or
 after the request is canceled.
 */
@property (atomic, assign) double downloadProgress;

/**
 The percent complete for upload progress. The value will be between 0.0 and 1.0 while the request
 is in progress and after it completes. The value will be -1.0 before the request is started or
 after the request is canceled.
 */
@property (atomic, assign) double uploadProgress;

/**
 The NSOperationQueue used for this request. Defaults to nil. If nil, the sharedOperationQueue is used.
 @see +[MBBaseRequest sharedOperationQueue]
 */
@property (nonatomic, strong) NSOperationQueue *operationQueue;

/**
 The shared NSOperationQueue used by default for all MBRequests. Your MBBaseRequest subclass can
 override this method to change the default queue used by all instances of that subclass.
 */
+ (NSOperationQueue *)sharedOperationQueue;

@end
