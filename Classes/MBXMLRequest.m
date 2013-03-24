//
//  MBXMLRequest.m
//  MBRequest
//
//  Created by Sebastian Celis on 3/4/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBXMLRequest.h"

#import "MBBaseRequestSubclass.h"

@implementation MBXMLRequest

#pragma mark - Object Lifecycle

- (id)init
{
    if ((self = [super init]))
    {
        NSSet *types = [NSSet setWithObjects:@"text/xml", nil];
        [[self connectionOperation] setValidContentTypes:types];
    }

    return self;
}

#pragma mark - Response

- (void)parseResults
{
    [super parseResults];

    // Create an autorelease pool for this parser.
    @autoreleasepool
    {
        // Parse the XML response.
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[[self connectionOperation] responseData]];
        [parser setDelegate:self];
        [parser parse];
    }
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if (![self isCancelled])
    {
        [self setError:parseError];
    }
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError
{
    if (![self isCancelled])
    {
        [self setError:validError];
    }
}

@end
