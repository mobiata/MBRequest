//
//  MBRYouTubeVideo.m
//  MBRequestExample
//
//  Created by Sebastian Celis on 3/19/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBRVideo.h"

@implementation MBRVideo

@synthesize author = _author;
@synthesize title = _title;

- (void)dealloc
{
    [_author release];
    [_title release];
    [super dealloc];
}

@end
