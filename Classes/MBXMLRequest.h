//
//  MBXMLRequest.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/4/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBBaseRequest.h"

// A basic starter class for implementing an XML parser. When you subclass this class,
// implement the NSXMLParserDelegate methods and be sure to check [self isCancelled]
// often, especially when expecting large XML documents that might take a significant
// amount of time to parse. If [self isCancelled] ever comes back true, make sure that
// you abort the NSXMLParser as quickly as possible.

@interface MBXMLRequest : MBBaseRequest <NSXMLParserDelegate>

@end
