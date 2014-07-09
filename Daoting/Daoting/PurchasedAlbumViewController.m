//
//  PurchasedSongViewController.m
//  Daoting
//
//  Created by Kevin on 14/7/4.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "PurchasedAlbumViewController.h"

@interface PurchasedAlbumViewController ()

@end

@implementation PurchasedAlbumViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    _appData = [AppData sharedAppData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _appData.purchasedQueue.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PurchasedAlbumCell *cell = (PurchasedAlbumCell*)[tableView dequeueReusableCellWithIdentifier:@"PurchasedAlbumCell" forIndexPath:indexPath];
    
    NSString* albumTitle = _appData.purchasedQueue.allKeys[indexPath.row];
    
    cell.lbl_albumTitle.text = albumTitle;
    
    return cell;
}




@end
