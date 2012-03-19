//
//  MBRYouTubeRequest.m
//  MBRequestExample
//
//  Created by Sebastian Celis on 3/19/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBRYouTubeRequest.h"

#import "MBBaseRequestSubclass.h"
#import "MBRVideo.h"
#import "NSURL+MBCommon.h"

@interface MBRYouTubeRequest ()
@property (nonatomic, copy) MBRYouTubeCompletionHandler youTubeCompletionHandler;
@property (nonatomic, strong) NSArray *youTubeVideos;
@end

@implementation MBRYouTubeRequest

@synthesize youTubeCompletionHandler = _youTubeCompletionHandler;
@synthesize youTubeVideos = _youTubeVideos;

#pragma mark - Request Lifecycle

- (void)dealloc
{
    [_youTubeCompletionHandler release];
    [_youTubeVideos release];
    [super dealloc];
}

#pragma mark - Public Methods

- (void)requestTopRatedVideosFromIndex:(NSInteger)startIndex
                            maxResults:(NSInteger)maxResults
                     completionHandler:(MBRYouTubeCompletionHandler)completionHandler
{
    // Prepare the request.
    NSMutableDictionary *urlParams = [NSMutableDictionary dictionary];
    [urlParams setObject:@"json" forKey:@"alt"];
    [urlParams setObject:@"this_week" forKey:@"time"];
    [urlParams setObject:[NSString stringWithFormat:@"%d", startIndex] forKey:@"start-index"];
    [urlParams setObject:[NSString stringWithFormat:@"%d", maxResults] forKey:@"max-results"];
    NSURL *url = [NSURL mb_URLWithBaseString:@"https://gdata.youtube.com/feeds/api/standardfeeds/top_rated" parameters:urlParams];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [[self connectionOperation] setRequest:urlRequest];
    
    // Schedule the NSOperation.
    [self setYouTubeCompletionHandler:completionHandler];
    [self scheduleOperation];
}

#pragma mark - MBBaseRequest Subclass Methods

- (void)parseResults
{
    [super parseResults];
    
    if ([self error] == nil)
    {
        NSMutableArray *videos = [[NSMutableArray alloc] init];

        NSArray *videoDatas = [[[self responseJSON] objectForKey:@"feed"] objectForKey:@"entry"];
        for (NSDictionary *videoInfo in videoDatas)
        {
            MBRVideo *video = [[MBRVideo alloc] init];
            NSString *title = [[videoInfo objectForKey:@"title"] objectForKey:@"$t"];
            NSString *author = [[[[videoInfo objectForKey:@"author"] objectAtIndex:0] objectForKey:@"name"] objectForKey:@"$t"];
            [video setTitle:title];
            [video setAuthor:author];
            [videos addObject:video];
            [video release];
        }
        
        [self setYouTubeVideos:[NSArray arrayWithArray:videos]];
        [videos release];
    }
}

- (void)notifyCaller
{
    [super notifyCaller];
    
    if ([self youTubeCompletionHandler])
    {
        [self youTubeCompletionHandler]([self youTubeVideos], [self error]);
    }
}

@end
