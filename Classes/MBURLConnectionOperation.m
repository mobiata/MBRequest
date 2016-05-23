//
//  MBURLConnectionOperation.m
//  MBRequest
//
//  Created by Sebastian Celis on 2/27/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBURLConnectionOperation.h"

#import "MBRequestError.h"
#import "MBRequestLocalization.h"
#import "MBRequestLog.h"
#import "MBURLConnectionOperationSubclass.h"

@interface MBURLConnectionOperation () <NSURLSessionDataDelegate, NSURLSessionTaskDelegate, NSURLSessionDelegate>
@property (atomic, strong, readwrite) NSURLSession *session;
@property (atomic, strong, readwrite) NSURLSessionDataTask *dataTask;
@property (atomic, strong, readwrite) NSMutableData *incrementalResponseData;
@property (atomic, strong, readwrite) NSURLResponse *response;
@property (atomic, strong, readwrite) NSData *responseData;
@property (atomic, strong, readwrite) NSError *error;
@property (atomic, assign) CFRunLoopRef runLoop;
@property (atomic, assign) BOOL runLoopIsRunning;
@property (atomic, assign) BOOL shouldCancel;
@end


@implementation MBURLConnectionOperation

@synthesize finished = _finished;
@synthesize executing = _executing;

#pragma mark - Accessors

- (void)setResponseDataOverride:(NSData *)data
{
    self.responseData = data;
}

- (void)main
{
    if (self.request == nil)
    {
        [NSException raise:NSInternalInconsistencyException format:@"%@: Unable to send request. No NSURLRequest object set!", self];
    }

    if ([self shouldCancel])
    {
        [self cancelOperation];
        [self finish];
    }
    else
    {
#ifdef MB_DEBUG_REQUESTS
        MBRequestLog(@"Sending %@ Request: %@", [[self request] HTTPMethod], [[self request] URL]);
        MBRequestLog(@"Headers: %@", [[self request] allHTTPHeaderFields]);
        NSString *bodyString = [[NSString alloc] initWithData:[[self request] HTTPBody] encoding:NSUTF8StringEncoding];
        if ([bodyString length] > 0)
        {
            MBRequestLog(@"Body: %@", [[NSString alloc] initWithData:[[self request] HTTPBody] encoding:NSUTF8StringEncoding]);
        }
#endif
        
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                     delegate:self
                                                delegateQueue:nil];
        
        self.dataTask = [self.session dataTaskWithRequest:self.request];
                                          
        if (self.dataTask == nil)
        {
            NSLog(@"NSURLSession returned nil for %@. How is this possible?", self.request);
            NSString *message = MBRequestLocalizedString(@"unknown_error_occurred", @"An unknown error has occurred.");
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:MBRequestErrorDomain
                                                 code:MBRequestErrorCodeUnknown
                                             userInfo:userInfo];
            self.error = error;
            [self finish];
        }
        else
        {
            [self.dataTask resume];
            self.runLoop = CFRunLoopGetCurrent();
            self.runLoopIsRunning = YES;
            CFRunLoopRun();
        }
    }
}

- (void)cancel
{
    if (![self isCancelled] && ![self isFinished])
    {
        // Defer the actual cancellation to a later iteration of the operation runloop.
        self.shouldCancel = YES;
    }
}

- (void)cancelFromRunLoop
{
    self.shouldCancel = NO;
    [self.dataTask cancel];
    self.dataTask = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        // We run this on the main thread to ensure safe cleanup of the operation and
        // the run loop. Without this block, it would be possible for [self cancelOperation]
        // to remove the NSOperartion from the NSOperationQueue and thus immediately deallocate
        // the operation before [self finish] can complete successfully.
        [self cancelOperation];
        [self finish];
    });
}

- (void)cancelOperation
{
    [super cancel];
}

- (void)finish
{
    if (![self isCancelled] && ![self isFinished])
    {
        [self.delegate connectionOperationDidFinish:self];
    }

    // Break the retain cycle. We no longer need to retain our delegate since we never need to
    // reference it again. This must be done on the runloop (if it is running) since the runloop's
    // thread may be *just* about to send a message to the delegate.
    self.delegate = nil;
    self.session = nil;
    self.dataTask = nil;
    
    if ([self isExecuting] && [self runLoopIsRunning])
    {
        CFRunLoopStop(self.runLoop);
        self.runLoop = nil;
        self.runLoopIsRunning = NO;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)handleResponse
{
#ifdef MB_DEBUG_REQUESTS
    if ([self.responseData length] > 0)
    {
        NSString *responseString = [self responseDataAsUTF8String];
        if ([responseString length] > 0)
        {
            MBRequestLog(@"Response String: %@", [self responseDataAsUTF8String]);
        }
    }
#endif
}

#pragma mark - Helper Methods

- (NSString *)responseDataAsUTF8String
{
    return [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    if (!self.cancelled && !self.finished)
    {
        if (self.shouldCancel)
        {
            completionHandler(NSURLSessionResponseCancel);
            [self cancelFromRunLoop];
        }
        else
        {
            self.response = response;
            
            long long capacity = response.expectedContentLength;
            capacity = (capacity == NSURLResponseUnknownLength) ? 1024 : capacity;
            capacity = MIN(capacity, 1024 * 1000);
            self.incrementalResponseData = [NSMutableData dataWithCapacity:(NSUInteger)capacity];
            completionHandler(NSURLSessionResponseAllow);
        }
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if (!self.cancelled && !self.finished)
    {
        if (self.shouldCancel)
        {
            [self cancelFromRunLoop];
        }
        else
        {
            [self.incrementalResponseData appendData:data];
            
            if ([self.delegate respondsToSelector:@selector(connectionOperation:didReceiveBodyData:totalBytesRead:totalBytesExpectedToRead:)])
            {
                [self.delegate connectionOperation:self
                                didReceiveBodyData:data.length
                                    totalBytesRead:self.incrementalResponseData.length
                          totalBytesExpectedToRead:self.response.expectedContentLength];
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    NSCachedURLResponse *cachedURLResponse = (self.cancelled || self.shouldCancel) ? nil : proposedResponse;
    completionHandler(cachedURLResponse);
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    if (!self.cancelled && !self.finished)
    {
        if (self.shouldCancel)
        {
            [self cancelFromRunLoop];
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(connectionOperation:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)])
            {
                [self.delegate connectionOperation:self
                               didSendBodyData:(NSUInteger)bytesSent
                             totalBytesWritten:(NSUInteger)totalBytesSent
                     totalBytesExpectedToWrite:totalBytesExpectedToSend];
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    if (!self.cancelled && !self.finished)
    {
        if (self.shouldCancel)
        {
            [self cancelFromRunLoop];
        }
        else
        {
            if (error == nil)  // If no error, finished sucesfully
            {
                self.responseData = [NSData dataWithData:self.incrementalResponseData];
                self.incrementalResponseData = nil;
            }
            else
            {
                self.error = error;
                MBRequestLog(@"Request Error: %@", [self error]);
            }
            [self handleResponse];
            [self finish];
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    BOOL handledAuth = NO;
    if (self.allowsUntrustedServerCertificates &&
        [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] &&
        challenge.previousFailureCount == 0 &&
        challenge.proposedCredential == nil)
    {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        handledAuth = YES;
    }
    
    if (!handledAuth)
    {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

@end
