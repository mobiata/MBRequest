//
//  MBBaseRequestSubclass.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/1/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

// The extensions in this header are to be used only by subclasses of MBBaseRequest.

#import <Foundation/Foundation.h>

@interface MBBaseRequest (ForSubclassEyesOnly)

// The shared request queue for all MBBaseRequest objects. You may override this method to return
// a different queue if you would like to separate some requests from other requests. For example,
// you might want a special queue to handle certain requests which are fast and return very little
// data. This queue could have 20 max concurrent operations while another, slower queue might only
// 2 or 3.
- (NSOperationQueue *)sharedRequestQueue;

// Schedules the operation on the sharedRequestQueue returned by the current class.
- (void)scheduleOperation;

// Schedules the operation on a particular NSOperationQueue.
- (void)scheduleOperationOnQueue:(NSOperationQueue *)queue;

// Override this method in your subclass to properly handle the response. It should parse
// the response into understandable objects for the caller and then notify the caller in
// some way, whether that be through delegate callbacks or blocks. To make things simpler for
// the callers, consider executing any callback code on the main thread.
- (void)connectionOperationDidFinish;

@end
