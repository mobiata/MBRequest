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
    [_error release];
    [_incrementalResponseData release];
    [_request release];
    [_response release];
    [_responseData release];
    [super dealloc];
}

#pragma mark - Main Functionality

- (void)main
{
    if (![self isCancelled])
    {
        if ([self request] == nil)
        {
            [NSException raise:NSInternalInconsistencyException format:@"%@: Unable to send request. No NSURLRequest object set!", self];
        }
        else
        {
            if ([self shouldCancel])
            {
                [self cancel];
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
                }
                else
                {
                    [[self connection] start];
                    [self setRunLoop:CFRunLoopGetCurrent()];
                    CFRunLoopRun();
                    [self setRunLoopIsRunning:YES];
                }
            }
        }
    }
}

- (void)cancel
{
    if (![self isCancelled] && ![self isFinished])
    {
        if (CFRunLoopGetCurrent() == [self runLoop])
        {
            [super cancel];

            [self setShouldCancel:NO];
            [[self connection] cancel];
            [self setConnection:nil];
            [self finish];
        }
        else
        {
            // Defer the actual cancellation to a later iteration of the operation runloop.
            [self setShouldCancel:YES];
        }
    }
}

- (void)finish
{
    if (![self isCancelled] && ![self isFinished])
    {
        [[self delegate] connectionOperationDidFinish:self];
    }

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
            [self cancel];
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
            [self cancel];
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
            [self cancel];
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
            [self cancel];
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
            [self cancel];
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

@end
