//
//  MBRBasicYouTubeViewController.m
//  MBRequestExample
//
//  Created by Sebastian Celis on 3/19/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBRBasicTopRatedVideosViewController.h"

#import "MBJSONRequest.h"
#import "MBRVideo.h"

@interface MBRBasicTopRatedVideosViewController ()
@property (nonatomic, strong) MBJSONRequest *jsonRequest;
@end


@implementation MBRBasicTopRatedVideosViewController

#pragma mark - UIViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSURL *url = [NSURL URLWithString:@"https://gdata.youtube.com/feeds/api/standardfeeds/top_rated?alt=json&time=this_week"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    MBJSONRequest *jsonRequest = [[MBJSONRequest alloc] init];
    [self setJsonRequest:jsonRequest];
    
    MBRBasicTopRatedVideosViewController * __weak weakSelf = self;
    [jsonRequest performJSONRequest:urlRequest completionHandler:^(id responseJSON, NSError *error) {
        MBRBasicTopRatedVideosViewController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (error != nil)
            {
                NSLog(@"Error requesting top-rated videos: %@", error);
            }
            else
            {
                NSMutableArray *videos = [[NSMutableArray alloc] init];
                
                NSArray *videoInfos = [[responseJSON objectForKey:@"feed"] objectForKey:@"entry"];
                for (NSDictionary *videoInfo in videoInfos)
                {
                    MBRVideo *video = [[MBRVideo alloc] init];
                    NSString *title = [[videoInfo objectForKey:@"title"] objectForKey:@"$t"];
                    NSString *author = [[[[videoInfo objectForKey:@"author"] objectAtIndex:0] objectForKey:@"name"] objectForKey:@"$t"];
                    [video setTitle:title];
                    [video setAuthor:author];
                    [videos addObject:video];
                }
                
                [strongSelf setVideos:[NSArray arrayWithArray:videos]];
                if ([strongSelf isViewLoaded])
                {
                    [[strongSelf tableView] reloadData];
                }
            }
            
            [strongSelf setJsonRequest:nil];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[self jsonRequest] cancel];
    [self setJsonRequest:nil];
    
    [super viewWillDisappear:animated];
}

@end
