//
//  MBURLConnectionOperation.h
//  MBRequest
//
//  Created by Sebastian Celis on 2/27/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MBURLConnectionOperation;


//__________________________________________________________________________________________________
// This protocol is used for notifying another object about significant events that occur to the
// MBURLConnectionOperation.

@protocol MBURLConnectionOperationDelegate <NSObject>

// This method gets called after the connection operation finishes (either successfully
// or with an error. It does not get called if the operation was cancelled.
- (void)connectionOperationDidFinish:(MBURLConnectionOperation *)operation;

@optional

// This method is called to notify the delegate when data has been downloaded from
// the connection.
- (void)connectionOperation:(MBURLConnectionOperation *)operation
         didReceiveBodyData:(NSUInteger)bytesRead
             totalBytesRead:(NSUInteger)totalBytesReceived
   totalBytesExpectedToRead:(long long)totalBytesExpectedToRead;

// This method is called to notify the delegate when data has been uploaded to
// the connection.
- (void)connectionOperation:(MBURLConnectionOperation *)operation
            didSendBodyData:(NSUInteger)bytesWritten
          totalBytesWritten:(NSUInteger)totalBytesWritten
  totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite;

@end


//__________________________________________________________________________________________________
// MBURLConnectionOperation is a simple NSOperation that wraps an NSURLConnection.

@interface MBURLConnectionOperation : NSOperation

@property (atomic, retain) NSURLRequest *request;
@property (atomic, retain, readonly) NSURLConnection *connection;
@property (atomic, retain, readonly) NSError *error;
@property (atomic, retain, readonly) NSURLResponse *response;
@property (atomic, retain, readonly) NSData *responseData;

// The delegate of the MBURLConnectionOperation. Note that this is a strong reference. This is
// important since the MBBaseRequest could be deallocated on the main thread when the background
// thread is *just* about to send a message to it. We can either create lots of horrible
// synchronization blocks, or we can create a retain cycle (which we are careful to eventually
// break). A retain cycle makes the code much cleaner than @synchronized blocks.
@property (atomic, retain) id <MBURLConnectionOperationDelegate> delegate;

// By default, NSURLConnection will not connect using SSL to servers with untrusted certificates.
// This includes all self-signed certificates. Setting allowsUntrustedServerCertificates to YES
// will allow these types of connections to occur. Defaults to NO.
@property (atomic, assign) BOOL allowsUntrustedServerCertificates;

// Returns the response data as a UTF-8 string.
- (NSString *)responseDataAsUTF8String;

// NSData to use instead of the standard response. Useful for bypassing the actual request when
// running automated tests. You should probably never call this method unless you are running a
// unit test.
- (void)setResponseDataOverride:(NSData *)data;

@end
