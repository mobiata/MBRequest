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

/**
 Subclasses should override this method to parse the results of the connection. Subclasses must
 call the super implementation of this method before executing their own code. If any errors
 occur while parsing, be sure to call setError:. This method will not be called if an error has
 already occurred.
 */
- (void)parseResults;

/**
 Subclasses should override this method to handle an error that occurred during the connection.
 Either this method or parseResults will get called, but not both.
 */
- (void)handleError;

/**
 Subclasses should override this method and notify their caller that the request has completed
 (either successfully or unsuccessfully). Subclasses should call the super implementation if they
 want the basic superclass request methods to work (like performJSONRequest:completionHandler:
 and performBasicRequest:completionHandler:. This method will be called on the main thread.
 */
- (void)notifyCaller;

/**
 This method is used to create the URL connection operation. Override this method if you need
 to create a subclass of MBURLConnectionOperation or customize just how that operation is
 created.
 */
- (MBURLConnectionOperation *)createConnectionOperation;

/**
 Schedules the operation on the appropriate queue.
 */
- (void)scheduleOperation;

/**
 Any error which might occur in the request. We allow subclasses to easily set this error by
 making the property readwrite.
 */
@property (atomic, strong, readwrite) NSError *error;

@end
