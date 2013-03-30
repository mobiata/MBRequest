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

#pragma mark - UIViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    MBRYouTubeRequest *request = [[MBRYouTubeRequest alloc] init];
    [self setYouTubeRequest:request];
    
    MBRBetterTopRatedVideosViewController * __weak weakSelf = self;
    [request requestTopRatedVideosFromIndex:1
                                 maxResults:5
                          completionHandler:^(NSArray *videos, NSError *error) {
                              MBRBetterTopRatedVideosViewController *strongSelf = weakSelf;
                              if (strongSelf != nil)
                              {
                                  if (error != nil)
                                  {
                                      NSLog(@"Error: %@", error);
                                  }
                                  else
                                  {
                                      [strongSelf setVideos:videos];
                                      if ([strongSelf isViewLoaded])
                                      {
                                          [[strongSelf tableView] reloadData];
                                      }
                                  }
                                  
                                  [strongSelf setYouTubeRequest:nil];
                              }
                          }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[self youTubeRequest] cancel];
    [self setYouTubeRequest:nil];
    
    [super viewWillDisappear:animated];
}

@end
