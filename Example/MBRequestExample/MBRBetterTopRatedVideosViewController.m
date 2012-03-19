//
//  MBRBetterTopRatedVideosViewController.m
//  MBRequestExample
//
//  Created by Sebastian Celis on 3/19/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBRBetterTopRatedVideosViewController.h"

#import "MBRYouTubeRequest.h"

@interface MBRBetterTopRatedVideosViewController ()
@property (nonatomic, strong) MBRYouTubeRequest *youTubeRequest;
@end


@implementation MBRBetterTopRatedVideosViewController

@synthesize youTubeRequest = _youTubeRequest;

#pragma mark - Controller Lifecycle

- (void)dealloc
{
    [_youTubeRequest release];
    [super dealloc];
}

#pragma mark - UIViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    MBRYouTubeRequest *request = [[[MBRYouTubeRequest alloc] init] autorelease];
    [self setYouTubeRequest:request];
    
    __block MBRBetterTopRatedVideosViewController *safeSelf = self;
    [request requestTopRatedVideosFromIndex:1
                                 maxResults:5
                          completionHandler:^(NSArray *videos, NSError *error) {
                              if (error != nil)
                              {
                                  NSLog(@"Error: %@", error);
                              }
                              else
                              {
                                  [safeSelf setVideos:videos];
                                  if ([safeSelf isViewLoaded])
                                  {
                                      [[safeSelf tableView] reloadData];
                                  }
                              }
                              
                              [safeSelf setYouTubeRequest:nil];
                          }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_youTubeRequest cancel];
    [self setYouTubeRequest:nil];
    
    [super viewWillDisappear:animated];
}

@end
