//
//  MBRTopRatedVideosViewController.m
//  MBRequestExample
//
//  Created by Sebastian Celis on 3/19/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBRTopRatedVideosViewController.h"

#import "MBRVideo.h"

@implementation MBRTopRatedVideosViewController

#pragma mark - Controller Lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    if ((self = [super initWithStyle:style]))
    {
        [self setTitle:@"Top Rated Videos"];
    }
    
    return self;
}

#pragma mark - UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self videos] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"YouTubeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    MBRVideo *video = [[self videos] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[video title]];
    [[cell detailTextLabel] setText:[video author]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
