//
//  MBRExamplesTableViewController.m
//  MBRequestExample
//
//  Created by Sebastian Celis on 3/19/12.
//  Copyright (c) 2012 Mobiata, LLC. All rights reserved.
//

#import "MBRExamplesTableViewController.h"

#import "MBRBasicTopRatedVideosViewController.h"
#import "MBRBetterTopRatedVideosViewController.h"

@implementation MBRExamplesTableViewController

#pragma mark - Controller Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        self.title = @"Examples";
    }
    
    return self;
}

#pragma mark - UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ExampleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    switch ([indexPath row])
    {
        case 0:
            cell.textLabel.text = @"Basic JSON Example";
            break;
        case 1:
            cell.textLabel.text = @"Better Subclass Example";
            break;
        default:
            break;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *vc = nil;
    
    switch ([indexPath row])
    {
        case 0:
            vc = [[[MBRBasicTopRatedVideosViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
            break;
        case 1:
            vc = [[[MBRBetterTopRatedVideosViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
            break;
        default:
            break;
    }
    
    if (vc != nil)
    {
        [[self navigationController] pushViewController:vc animated:YES];
    }
}

@end
