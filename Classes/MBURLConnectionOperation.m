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

@interface MBURLConnectionOperation ()
@property (atomic, retain, readwrite) NSURLConnection *connection;
@property (atomic, retain, readwrite) NSMutableData *incrementalResponseData;
@property (atomic, retain, readwrite) NSURLResponse *response;
@property (atomic, retain, readwrite) NSData *responseData;
@property (atomic, retain, readwrite) NSError *error;
@property (atomic, assign) CFRunLoopRef runLoop;
@property (atomic, assign) BOOL runLoopIsRunning;
@property (atomic, assign) BOOL shouldCancel;
- (void)finish;
@end


@implementation MBURLConnectionOperation

@synthesize allowsUntrustedServerCertificates = _allowsUntrustedServerCertificates;
@synthesize connection = _connection;
@synthesize delegate = _delegate;
@synthesize error = _error;
@synthesize incrementalResponseData = _incrementalResponseData;
@synthesize request = _request;
@synthesize response = _response;
@synthesize responseData = _responseData;
@synthesize runLoop = _runLoop;
@synthesize runLoopIsRunning = _runLoopIsRunning;
@synthesize shouldCancel = _shouldCancel;

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [_connection release];
    [_delegate release];
    [_error release];
    [_incrementalResponseData release];
    [_request release];
    [_response release];
    [_responseData release];
    [super dealloc];
}

#pragma mark - Accessors

- (void)setResponseDataOverride:(NSData *)data
{
    [self setResponseData:data];
}

#pragma mark - Main Functionality

- (void)main
{
    if ([self request] == nil)
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
        MBRequestLog(@"Sending %@ Request: %@", [[self request] HTTPMethod], [[self request] URL]);
        MBRequestLog(@"Headers: %@", [[self request] allHTTPHeaderFields]);

        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:[self request]
                                                                      delegate:self
                                                              startImmediately:NO];
        [self setConnection:connection];
        [connection release];

        if ([self connection] == nil)
        {
            NSLog(@"NSURLConnection's initWithRequest returned nil for %@. How is this possible?", [self request]);
            NSString *message = MBRequestLocalizedString(@"unknown_error_occurred", @"An unknown error has occurred.");
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:MBRequestErrorDomain
                                                 code:MBRequestErrorCodeUnknown
                                             userInfo:userInfo];
            [self setError:error];
            [self finish];
        }
        else
        {
            [[self connection] start];
            [self setRunLoop:CFRunLoopGetCurrent()];
            [self setRunLoopIsRunning:YES];
            CFRunLoopRun();
        }
    }
}

- (void)cancel
{
    if (![self isCancelled] && ![self isFinished])
    {
        // Defer the actual cancellation to a later iteration of the operation runloop.
        [self setShouldCancel:YES];
    }
}

- (void)cancelFromRunLoop
{
    [self setShouldCancel:NO];
    [[self connection] cancel];
    [self setConnection:nil];
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
        [[self delegate] connectionOperationDidFinish:self];
    }

    // Break the retain cycle. We no longer need to retain our delegate since we never need to
    // reference it again. This must be done on the runloop (if it is running) since the runloop's
    // thread may be *just* about to send a message to the delegate.
    [self setDelegate:nil];

    if ([self isExecuting] && [self runLoopIsRunning])
    {
        CFRunLoopStop([self runLoop]);
        [self setRunLoop:NULL];
        [self setRunLoopIsRunning:NO];
    }
}

- (void)handleResponse
{
}

#pragma mark - Helper Methods

- (NSString *)responseDataAsUTF8String
{
    NSString *responseString = [[NSString alloc] initWithData:[self responseData] encoding:NSUTF8StringEncoding];
    return [responseString autorelease];
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (![self isCancelled] && ![self isFinished])
    {
        if ([self shouldCancel])
        {
            [self cancelFromRunLoop];
        }
        else
        {
            [self setResponse:response];

            long long capacity = [response expectedContentLength];
            capacity = (capacity == NSURLResponseUnknownLength) ? 1024 : capacity;
            capacity = MIN(capacity, 1024 * 1000);
            [self setIncrementalResponseData:[NSMutableData dataWithCapacity:capacity]];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (![self isCancelled] && ![self isFinished])
    {
        if ([self shouldCancel])
        {
            [self cancelFromRunLoop];
        }
        else
        {
            [[self incrementalResponseData] appendData:data];

            if ([_delegate respondsToSelector:@selector(connectionOperation:didReceiveBodyData:totalBytesRead:totalBytesExpectedToRead:)])
            {
                [_delegate connectionOperation:self
                            didReceiveBodyData:[data length]
                                totalBytesRead:[[self incrementalResponseData] length]
                      totalBytesExpectedToRead:[[self response] expectedContentLength]];
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (![self isCancelled] && ![self isFinished])
    {
        if ([self shouldCancel])
        {
            [self cancelFromRunLoop];
        }
        else
        {
            [self setError:error];
            MBRequestLog(@"Request Error: %@", [self error]);
            [self handleResponse];
            [self finish];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (![self isCancelled] && ![self isFinished])
    {
        if ([self shouldCancel])
        {
            [self cancelFromRunLoop];
        }
        else
        {
            [self setResponseData:[NSData dataWithData:[self incrementalResponseData]]];
            [self setIncrementalResponseData:nil];
            MBRequestLog(@"Received Response:\n%@", [self responseDataAsUTF8String]);
            [self handleResponse];
            [self finish];
        }
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return ([self isCancelled] || [self shouldCancel]) ? nil : cachedResponse;
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (![self isCancelled] && ![self isFinished])
    {
        if ([self shouldCancel])
        {
            [self cancelFromRunLoop];
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(connectionOperation:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)])
            {
                [_delegate connectionOperation:self
                               didSendBodyData:bytesWritten
                             totalBytesWritten:totalBytesWritten
                     totalBytesExpectedToWrite:totalBytesExpectedToWrite];
            }
        }
    }
}

#pragma mark Authentication Challenges

// iOS 5+ only.
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [self handleAuthenticationChallenge:challenge forConnection:connection];
}

// This method has been deprecated for connection:willSendRequestForAuthenticationChallenge in iOS 5.
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    BOOL canAuth = NO;
    if ([self allowsUntrustedServerCertificates] &&
        [[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        canAuth = YES;
    }

    return canAuth;
}

// This method has been deprecated for connection:willSendRequestForAuthenticationChallenge in iOS 5.
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [self handleAuthenticationChallenge:challenge forConnection:connection];
}

- (void)handleAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge forConnection:(NSURLConnection *)connection
{
    BOOL handledAuth = NO;
    if ([self allowsUntrustedServerCertificates] &&
        [[[challenge protectionSpace] authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust] &&
        [challenge previousFailureCount] == 0 &&
        [challenge proposedCredential] == nil)
    {
        [[challenge sender] useCredential:[NSURLCredential credentialForTrust:[[challenge protectionSpace] serverTrust]]
               forAuthenticationChallenge:challenge];
        handledAuth = YES;
    }

    if (!handledAuth)
    {
        if ([[challenge sender] respondsToSelector:@selector(performDefaultHandlingForAuthenticationChallenge:)])
        {
            [[challenge sender] performDefaultHandlingForAuthenticationChallenge:challenge];
        }
        else
        {
            [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    }
}

@end
