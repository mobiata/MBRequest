//
//  MBBaseRequest.m
//  MBRequest
//
//  Created by Sebastian Celis on 2/29/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBBaseRequest.h"
#import "MBBaseRequestSubclass.h"

@interface MBBaseRequest ()
@property (atomic, retain, readwrite) NSError *error;
@property (atomic, assign, readwrite, getter=isRunning) BOOL running;
@property (atomic, retain, readwrite) MBURLConnectionOperation *connectionOperation;
@end


// This set of active requests serves the sole purpose of ensuring that the request
// objects are not dealloced out from under the request. connectionOperationDidFinish
// runs on a background thread, and without lots of @synchronized calls it would
// be possible for the main thread to cancel and dealloc the request while the background
// thread was executing this method. This NSMutableSet ensures that the request sticks
// around long enough that we don't run into any memory issues.
static NSMutableSet *_activeRequests;

void _MBAddRequest(MBBaseRequest *request)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _activeRequests = [[NSMutableSet alloc] init];
    });

    @synchronized (_activeRequests)
    {
        [_activeRequests addObject:request];
    }
}

void _MBRemoveRequest(MBBaseRequest *request)
{
    @synchronized (_activeRequests)
    {
        [_activeRequests removeObject:request];
    }
}

@implementation MBBaseRequest

@synthesize connectionOperation = _connectionOperation;
@synthesize downloadProgressCallback = _downloadProgressCallback;
@synthesize error = _error;
@synthesize running = _running;
@synthesize uploadProgressCallback = _uploadProgressCallback;

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [_connectionOperation cancel];
    [_connectionOperation release];
    [_downloadProgressCallback release];
    [_error release];
    [_uploadProgressCallback release];
    [super dealloc];
}

#pragma mark - Public Methods

- (void)cancel
{
    @synchronized (self)
    {
        [[self connectionOperation] cancel];
        [self setRunning:NO];
    }

    _MBRemoveRequest(self);
}

- (BOOL)isCancelled
{
    return [[self connectionOperation] isCancelled];
}

#pragma mark - Private Methods

- (NSOperationQueue *)sharedRequestQueue
{
    static NSOperationQueue *sharedQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = [[NSOperationQueue alloc] init];
        [sharedQueue setMaxConcurrentOperationCount:5];
        [sharedQueue setName:@"Shared MBRequest Queue"];
    });

    return sharedQueue;
}

- (void)scheduleOperation
{
    [self scheduleOperationOnQueue:[self sharedRequestQueue]];
}

- (void)scheduleOperationOnQueue:(NSOperationQueue *)queue
{
    _MBAddRequest(self);
    [queue addOperation:[self connectionOperation]];
    [self setRunning:YES];
}

- (void)connectionOperationDidFinish
{
}

#pragma mark - MBURLConnectionOperationDelegate

- (void)connectionOperationDidFinish:(MBURLConnectionOperation *)operation
{
    @synchronized (self)
    {
        [self setError:[operation error]];
        [self connectionOperationDidFinish];
        [self setRunning:NO];
    }

    _MBRemoveRequest(self);
}

- (void)connectionOperation:(MBURLConnectionOperation *)operation
         didReceiveBodyData:(NSInteger)bytesRead
             totalBytesRead:(NSInteger)totalBytesReceived
   totalBytesExpectedToRead:(NSInteger)totalBytesExpectedToRead
{
    if (![self isCancelled] && [self downloadProgressCallback])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![self isCancelled])
            {
                [self downloadProgressCallback](bytesRead, totalBytesReceived, totalBytesExpectedToRead);
            }
        });
    }
}

- (void)connectionOperation:(MBURLConnectionOperation *)operation
            didSendBodyData:(NSInteger)bytesWritten
          totalBytesWritten:(NSInteger)totalBytesWritten
  totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (![self isCancelled] && [self uploadProgressCallback])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![self isCancelled])
            {
                [self uploadProgressCallback](bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
            }
        });
    }
}

@end
