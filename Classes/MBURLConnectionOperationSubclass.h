//
//  MBURLConnectionOperationSubclass.h
//  MBRequest
//
//  Created by Sebastian Celis on 2/28/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

// The extensions in this header are to be used only by subclasses of MBURLConnectionOperation.

#import <Foundation/Foundation.h>

@interface MBURLConnectionOperation (ForSubclassEyesOnly)

// A method that handles the end of the NSOperation.
- (void)finish;

// This method is called after the NSURLConnection has finished loading (either successfully or
// with an error). Subclasses should use this method to check for any errors they want to handle
// as well as parse whatever response the server sent to the client.
- (void)handleResponse;

@end
