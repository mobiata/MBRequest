//
//  MBNetworkActivityIndicatorManager.h
//  MBRequest
//
//  Created by Sebastian Celis on 3/5/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>
#endif

/**
 A class for managing the global network activity indicator on iOS. This class will do nothing on
 OS X. This class is thread-safe and uses GCD to ensure that the network activity indicator is only
 accessed from the main thread.
 */
@interface MBNetworkActivityIndicatorManager : NSObject

/**
 A property for enabling or disabling the network activity indicator manager. Defaults to YES. When
 set to NO, networkActivityStarted and networkActivityStopped will do nothing. If you are going to
 globally disable this class in your application, it is recommended that you set enabled to NO
 before any classes call networkActivityStarted or networkActivityStopped.
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;


/**
 A property for containing the UIApplication whose network activity indicator will be activated
 when networkActivityStarted and networkActivityStopped are called. Use this property when MBRequest
 is contained in a framework shared between a containing app and an app extension. Setting this
 property in your appDelegate will ensure that the network activity indicator is managed properly.
 */
#if __IPHONE_OS_VERSION_MIN_REQUIRED
@property (nonatomic, assign) UIApplication *sharedApplication;
#endif

/**
 Call this whenever network activity is started. Every call to this method must be balanced by a
 call to networkActivityStopped.
 @see -[MBNetworkActivityIndicatorManager networkActivityStopped]
 */
- (void)networkActivityStarted;

/**
 Call this whenever network activity stops. Every call to this method must be balanced by a call to
 networkActivityStarted.
 @see -[MBNetworkActivityIndicatorManager networkActivityStarted]
 */
- (void)networkActivityStopped;

/**
 Returns the shared instance of this class. As there is only one network activity indicator on an
 iOS device, you should really only use this instance of the class. Using multiple instances will
 almost certainly result in undesired behavior.
 */
+ (MBNetworkActivityIndicatorManager *)sharedManager;

@end
