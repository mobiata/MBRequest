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

// Subclasses should override this method to parse the results of the connection. Subclasses must
// call the super implementation of this method before executing their own code. If any errors
// occur while parsing, be sure to call setError:. This method will not be called if an error has
// already occurred.
- (void)parseResults;

// Subclasses should override this method and notify their caller that the request has completed
// (either successfully or unsuccessfully). Subclasses should call the super implementation if they
// want the basic superclass request methods to work (like performJSONRequest:completionHandler:
// and performBasicRequest:completionHandler:. This method will be called on the main thread.
- (void)notifyCaller;

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

@end
