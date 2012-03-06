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
         didReceiveBodyData:(NSInteger)bytesRead
             totalBytesRead:(NSInteger)totalBytesReceived
   totalBytesExpectedToRead:(NSInteger)totalBytesExpectedToRead;

// This method is called to notify the delegate when data has been uploaded to
// the connection.
- (void)connectionOperation:(MBURLConnectionOperation *)operation
            didSendBodyData:(NSInteger)bytesWritten
          totalBytesWritten:(NSInteger)totalBytesWritten
  totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;

@end


//__________________________________________________________________________________________________
// MBURLConnectionOperation is a simple NSOperation that wraps an NSURLConnection.

@interface MBURLConnectionOperation : NSOperation

@property (atomic, retain) NSURLRequest *request;
@property (atomic, retain, readonly) NSURLConnection *connection;
@property (atomic, retain, readonly) NSError *error;
@property (atomic, retain, readonly) NSURLResponse *response;
@property (atomic, retain, readonly) NSData *responseData;
@property (atomic, assign) id <MBURLConnectionOperationDelegate> delegate;

// Returns the response data as a UTF-8 string.
- (NSString *)responseDataAsUTF8String;

@end
