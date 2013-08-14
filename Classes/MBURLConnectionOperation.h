//
//  MBURLConnectionOperation.h
//  MBRequest
//
//  Created by Sebastian Celis on 2/27/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MBURLConnectionOperation;


/**
 The MBURLConnectionOperationDelegate protocol is used for notifying another object about
 significant events that occur to the MBURLConnectionOperation. In MBRequest, MBBaseRequest is the
 delegate for its MBURLConnectionOperation.
 */
@protocol MBURLConnectionOperationDelegate <NSObject>

/**
 This method gets called after the connection operation finishes (either successfully
 or with an error. It does not get called if the operation was cancelled.
 @param operation The operation that finished.
 */
- (void)connectionOperationDidFinish:(MBURLConnectionOperation *)operation;

@optional

/**
 This method is called to notify the delegate when data has been read from the connection.
 @param operation The operation that received data.
 @param bytesRead The number of bytes that were just read.
 @param totalBytesReceived The total number of bytes that have been read.
 @param totalBytesExpectedToRead The total number of bytes expected from this particular connection.
 Will only be set to greater than 0 if the server supplied the necessary information.
 */
- (void)connectionOperation:(MBURLConnectionOperation *)operation
         didReceiveBodyData:(NSUInteger)bytesRead
             totalBytesRead:(NSUInteger)totalBytesReceived
   totalBytesExpectedToRead:(long long)totalBytesExpectedToRead;

/**
 This method is called to notify the delegate when data has been sent to the connection.
 @param operation The operation that sent data.
 @param bytesWritten The number of bytes that were just written.
 @param totalBytesWritten The total number of bytes that have been written.
 @param totalBytesExpectedToWrite The total number of bytes the connection is expected to write.
 */- (void)connectionOperation:(MBURLConnectionOperation *)operation
            didSendBodyData:(NSUInteger)bytesWritten
          totalBytesWritten:(NSUInteger)totalBytesWritten
  totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite;

@end


/**
 MBURLConnectionOperation is a simple NSOperation that wraps an NSURLConnection.
 */
@interface MBURLConnectionOperation : NSOperation

/**
 The NSURLRequest associated with this connection. This must be set before the operation can start.
 */
@property (atomic, strong) NSURLRequest *request;

/**
 The NSURLConnection associated with this operation. It is created with `request`.
 @see -[MBURLConnectionOperation request]
 */
@property (atomic, strong, readonly) NSURLConnection *connection;

/**
 Any error that occurs when processing the NSURLConnection.
 */
@property (atomic, strong, readonly) NSError *error;

/**
 The NSURLResponse for this connection.
 */
@property (atomic, strong, readonly) NSURLResponse *response;

/**
 The data read from this connection. This property will not be set until all of the data has been
 read and the connection has been closed.
 */
@property (atomic, strong, readonly) NSData *responseData;

/**
 The delegate of the MBURLConnectionOperation. Note that this is a strong reference. This is
 important since the MBBaseRequest could be deallocated on the main thread when the background
 thread is *just* about to send a message to it. We can either create lots of horrible
 synchronization blocks, or we can create a retain cycle (which we are careful to eventually
 break). A retain cycle makes the code much cleaner than @synchronized blocks.
 */
@property (atomic, strong) id <MBURLConnectionOperationDelegate> delegate;

/**
 By default, NSURLConnection will not connect using SSL to servers with untrusted certificates.
 This includes all self-signed certificates. Setting allowsUntrustedServerCertificates to YES
 will allow these types of connections to occur. Defaults to NO.
 @warning Setting this to YES can make your application less secure. You should probably only set
 this during the development cycle if you need to connect to a test server with an untrusted
 certificate.
 */
@property (atomic, assign) BOOL allowsUntrustedServerCertificates;

/**
 A helper method that returns the response data as a UTF-8 string.
 */
- (NSString *)responseDataAsUTF8String;

/**
 This method can be used to set the NSData that would normally come back from the NSURLConnection.
 This bypasses the connection entirely and will cause the MBRequest to jump immpediately to its
 parseResults method. This is useful for bypassing the actual request when running automated tests.
 You should probably never call this method unless you are running a unit test.
 @param data The data to use for overriding the responseData of the MBURLConnectionOperation.
 @see -[MBBaseRequest parseResults]
 @see -[MBURLConnectionOperation responseData]
 */
- (void)setResponseDataOverride:(NSData *)data;

@end
