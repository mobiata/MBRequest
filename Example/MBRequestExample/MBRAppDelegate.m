//
//  MBRAppDelegate.m
//  MBRequestExample
//
//  Created by Sebastian Celis on 3/19/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBRAppDelegate.h"

#import "MBRExamplesTableViewController.h"

@implementation MBRAppDelegate

@synthesize navigationController = _navigationController;
@synthesize window = _window;

#pragma mark - Application Lifecycle

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    MBRExamplesTableViewController *masterViewController = [[[MBRExamplesTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
