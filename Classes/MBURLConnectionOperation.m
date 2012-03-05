//
//  MBURLConnectionOperation.m
//  MBRequest
//
//  Created by Sebastian Celis on 2/27/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBURLConnectionOperation.h"
#import "MBURLConnectionOperationSubclass.h"

@interface MBURLConnectionOperation ()
@property (atomic, retain, readwrite) NSURLConnection *connection;
@property (atomic, retain, readwrite) NSMutableData *incrementalResponseData;
@property (atomic, retain, readwrite) NSURLResponse *response;
@property (atomic, retain, readwrite) NSData *responseData;
@property (atomic, retain, readwrite) NSError *error;
@end


@implementation MBURLConnectionOperation

@synthesize connection = _connection;
@synthesize delegate = _delegate;
@synthesize error = _error;
@synthesize incrementalResponseData = _incrementalResponseData;
@synthesize request = _request;
@synthesize response = _response;
@synthesize responseData = _responseData;

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
    @synchronized (self)
    {
        if (![self isCancelled] && ![self isFinished])
        {
            [self setConnection:[NSURLConnection connectionWithRequest:[self request] delegate:self]];
        }
        
        CFRunLoopRun();
    }
}

- (void)cancel
{
    @synchronized (self)
    {
        [super cancel];
        [self finish];
    }
}

- (void)handleResponse
{
}

- (void)finish
{
    @synchronized (self)
    {
        if (![self isCancelled])
        {
            [[self delegate] connectionOperationDidFinish:self];
        }
        
        CFRunLoopStop(CFRunLoopGetCurrent());
    }
}

- (NSString *)responseDataAsUTF8String
{
    NSString *responseString = [[NSString alloc] initWithData:[self responseData] encoding:NSUTF8StringEncoding];
    return [responseString autorelease];
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    @synchronized (self)
    {
        if ([self isCancelled] || [self isFinished])
        {
            [connection cancel];
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
    @synchronized (self)
    {
        if ([self isCancelled] || [self isFinished])
        {
            [connection cancel];
        }
        else
        {
            [[self incrementalResponseData] appendData:data];
        }
        
        if ([_delegate respondsToSelector:@selector(connectionOperation:didReceiveBodyData:totalBytesRead:totalBytesExpectedToRead:)])
        {
            [_delegate connectionOperation:self
                        didReceiveBodyData:[data length]
                            totalBytesRead:[[self incrementalResponseData] length]
                  totalBytesExpectedToRead:[[self response] expectedContentLength]];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    @synchronized (self)
    {
        if (![self isCancelled] && ![self isFinished])
        {
            [self setError:error];
            [self handleResponse];
            [self finish];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    @synchronized (self)
    {
        if (![self isCancelled] && ![self isFinished])
        {
            [self setResponseData:[NSData dataWithData:[self incrementalResponseData]]];
            [self setIncrementalResponseData:nil];
            [self handleResponse];
            [self finish];
        }
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    @synchronized (self)
    {
        return ([self isCancelled]) ? nil : cachedResponse;
    }
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    @synchronized (self)
    {
        if (![self isCancelled] && ![self isFinished])
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
