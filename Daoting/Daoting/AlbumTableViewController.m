//
//  AlbumTableViewController.m
//  Daoting
//
//  Created by Kevin on 14-5-12.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "AlbumTableViewController.h"
#import "CoinIAPHelper.h"
#import "Album.h"
#import "AlbumCell.h"
#import "UIImageView+AFNetworking.h"
#import "SongTableViewController.h"

@interface AlbumTableViewController ()

@end

@implementation AlbumTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    _appdelegate = [[UIApplication sharedApplication]delegate];
    
    self.view.backgroundColor = _appdelegate.defaultBackgroundColor;
    
    _albums = [AlbumManager sharedManager].albums;
    
    Album *album = [[AlbumManager sharedManager] searchAlbumByShortName:[AppData sharedAppData].currentAlbum.shortName];
    
    for (int i = 0; i < _albums.count; i ++) {
        
        Album *subAlbum = _albums[i];
        
        if (album.shortName == subAlbum.shortName) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Album *album = [_albums objectAtIndex:indexPath.row];
    AlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell" forIndexPath:indexPath];
    
    //Configure Cell
    cell.lbl_albumTitle.text = album.title;
    cell.lbl_albumDescription.text = album.description;
    
    //Updating Cell Image
    NSURLRequest *request = [NSURLRequest requestWithURL:album.imageUrl];
    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
    
    __weak AlbumCell *weakCell = cell;
    
    [cell.img_albumImage setImageWithURLRequest:request
                               placeholderImage:placeholderImage
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
    {
        [weakCell.img_albumImage setImage:image];
        [weakCell setNeedsLayout];
                                       
    } failure:nil];
    
    cell.backgroundColor = [UIColor clearColor];
    
    //selection
    UIImageView *imageView_playing = [[UIImageView alloc] initWithFrame:CGRectMake(0, 16, 5, 48)];
    imageView_playing.image = [UIImage imageNamed:@"playingsong.png"];
    
    [cell.selectedBackgroundView addSubview:imageView_playing];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSongList"]) {
        
        NSIndexPath *indexpath = [self.tableView indexPathForSelectedRow];

        SongTableViewController *destinationViewController = [segue destinationViewController];
        
        destinationViewController.hidesBottomBarWhenPushed = YES;
        [destinationViewController setDetailItem: [_albums objectAtIndex:indexpath.row]];
    }
}

@end
