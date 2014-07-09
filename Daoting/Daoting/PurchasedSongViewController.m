//
//  PurchasedSongViewController.m
//  Daoting
//
//  Created by Kevin on 14/7/9.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "PurchasedSongViewController.h"

@interface PurchasedSongViewController ()

@end

@implementation PurchasedSongViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _songsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PurchasedSongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PurchasedSongCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.lbl_SongTitle.text = [NSString stringWithFormat:@"%@ %@", _albumTitle, _songsArray.allKeys[indexPath.row]];
    
    return cell;
}

@end
