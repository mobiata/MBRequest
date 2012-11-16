//
//  MBBaseRequest.m
//  MBRequest
//
//  Created by Sebastian Celis on 2/29/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBBaseRequest.h"

#import "MBBaseRequestSubclass.h"
#import "MBNetworkActivityIndicatorManager.h"

@interface MBBaseRequest ()
@property (atomic, retain, readwrite) NSError *error;
@property (atomic, assign, readwrite, getter=isCancelled) BOOL cancelled;
@property (atomic, assign, readwrite, getter=isRunning) BOOL running;
@property (nonatomic, copy, readwrite) MBBaseRequestCompletionHandler baseCompletionHandler;
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

@synthesize affectsNetworkActivityIndicator = _affectsNetworkActivityIndicator;
@synthesize baseCompletionHandler = _baseCompletionHandler;
@synthesize cancelled = _cancelled;
@synthesize connectionOperation = _connectionOperation;
@synthesize downloadProgressCallback = _downloadProgressCallback;
@synthesize error = _error;
@synthesize running = _running;
@synthesize uploadProgressCallback = _uploadProgressCallback;

#pragma mark - Object Lifecycle

- (id)init
{
    if ((self = [super init]))
    {
        _affectsNetworkActivityIndicator = YES;
    }

    return self;
}

- (void)dealloc
{
    [_baseCompletionHandler release];
    [_connectionOperation release];
    [_downloadProgressCallback release];
    [_error release];
    [_uploadProgressCallback release];
    [super dealloc];
}

#pragma mark - Accessors

- (MBURLConnectionOperation *)connectionOperation
{
    if (_connectionOperation == nil)
    {
        _connectionOperation = [[self createConnectionOperation] retain];
        [_connectionOperation setDelegate:self];
    }

    return _connectionOperation;
}

- (MBURLConnectionOperation *)createConnectionOperation
{
    MBURLConnectionOperation *op = [[MBURLConnectionOperation alloc] init];
    return [op autorelease];
}

#pragma mark - Public Methods

- (void)performBasicRequest:(NSURLRequest *)request completionHandler:(MBBaseRequestCompletionHandler)completionHandler
{
    [[self connectionOperation] setRequest:request];
    [self setBaseCompletionHandler:completionHandler];
    [self scheduleOperation];
}

- (void)cancel
{
    @synchronized (self)
    {
        if ([self isRunning] && ![self isCancelled])
        {
            [self setCancelled:YES];
            [[self connectionOperation] cancel];
            [self finish];
        }
    }
}

#pragma mark - Cleanup

- (void)finish
{
    @synchronized (self)
    {
        if ([self isRunning])
        {
            [self setRunning:NO];

            if ([self affectsNetworkActivityIndicator])
            {
                [[MBNetworkActivityIndicatorManager sharedManager] networkActivityStopped];
            }

            if (![self isCancelled])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![self isCancelled])
                    {
                        [self notifyCaller];
                    }

                    _MBRemoveRequest(self);
                });
            }
            else
            {
                _MBRemoveRequest(self);
            }
        }
    }
}

#pragma mark - Response

- (void)parseResults
{
    // Nothing to do.
}

- (void)notifyCaller
{
    if ([self baseCompletionHandler] != nil)
    {
        [self baseCompletionHandler]([[self connectionOperation] responseData], [self error]);
    }
}

#pragma mark - Request Queues

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
    [self setRunning:YES];

    if ([self affectsNetworkActivityIndicator])
    {
        [[MBNetworkActivityIndicatorManager sharedManager] networkActivityStarted];
    }

    if ([[self connectionOperation] responseData] != nil)
    {
        NSBlockOperation *myOperation = [NSBlockOperation blockOperationWithBlock: ^{
            [self connectionOperationDidFinish:[self connectionOperation]];
        }];
        [queue addOperation:myOperation];
    }
    else
    {
        _MBAddRequest(self);
        [queue addOperation:[self connectionOperation]];
    }
}

#pragma mark - MBURLConnectionOperationDelegate

- (void)connectionOperationDidFinish:(MBURLConnectionOperation *)operation
{
    if (![self isCancelled])
    {
        [self setError:[operation error]];
        if ([self error] == nil)
        {
            [self parseResults];
        }

        [self finish];
        [self setUploadProgress:1.0];
        [self setDownloadProgress:1.0];
    }
    else
    {
        [self setUploadProgress:-1.0];
        [self setDownloadProgress:-1.0];
    }
}

- (void)connectionOperation:(MBURLConnectionOperation *)operation
         didReceiveBodyData:(NSUInteger)bytesRead
             totalBytesRead:(NSUInteger)totalBytesReceived
   totalBytesExpectedToRead:(long long)totalBytesExpectedToRead
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
    
    if (![self isCancelled] && totalBytesExpectedToRead > 0.0)
    {
        [self setDownloadProgress:totalBytesReceived / (double)totalBytesExpectedToRead];
    }
    else
    {
        [self setDownloadProgress:-1.0];
    }
}

- (void)connectionOperation:(MBURLConnectionOperation *)operation
            didSendBodyData:(NSUInteger)bytesWritten
          totalBytesWritten:(NSUInteger)totalBytesWritten
  totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
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
    
    if (![self isCancelled] && totalBytesExpectedToWrite > 0.0)
    {
        [self setUploadProgress:totalBytesWritten / (double)totalBytesExpectedToWrite];
    }
    else
    {
        [self setUploadProgress:-1.0];
    }
}

@end
