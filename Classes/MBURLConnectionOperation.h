//
//  MBURLConnectionOperation.h
//  MBRequest
//
//  Created by Sebastian Celis on 2/27/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MBURLConnectionOperation;


@protocol MBURLConnectionOperationDelegate <NSObject>
- (void)connectionOperationDidFinish:(MBURLConnectionOperation *)operation;
@optional
- (void)connectionOperation:(MBURLConnectionOperation *)operation
         didReceiveBodyData:(NSInteger)bytesRead
             totalBytesRead:(NSInteger)totalBytesReceived
   totalBytesExpectedToRead:(NSInteger)totalBytesExpectedToRead;
- (void)connectionOperation:(MBURLConnectionOperation *)operation
            didSendBodyData:(NSInteger)bytesWritten
          totalBytesWritten:(NSInteger)totalBytesWritten
  totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
@end


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
