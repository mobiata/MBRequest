//
//  MBRAppDelegate.m
//  MBRequestExample-OSX
//
//  Created by Sebastian Celis on 5/17/13.
//  Copyright (c) 2013 Mobiata, LLC. All rights reserved.
//

#import "MBRAppDelegate.h"

#import "MBJSONRequest.h"
#import "MBRVideo.h"

@implementation MBRAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[self label] setStringValue:@"Requesting Top Videos…"];

    NSURL *url = [NSURL URLWithString:@"https://gdata.youtube.com/feeds/api/standardfeeds/top_rated?alt=json&time=this_week"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    MBJSONRequest *jsonRequest = [[MBJSONRequest alloc] init];
    [jsonRequest performJSONRequest:urlRequest completionHandler:^(id responseJSON, NSError *error) {
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

            NSMutableString *titles = [[NSMutableString alloc] init];
            for (MBRVideo *video in videos)
            {
                [titles appendFormat:@"%@\n", [video title]];
            }
            [[self label] setStringValue:titles];
        }
    }];

}

@end
