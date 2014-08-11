//
//  PurchasedSongViewController.m
//  Daoting
//
//  Created by Kevin on 14/7/9.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "PurchasedSongViewController.h"

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
}

- (void)viewWillAppear:(BOOL)animated
{
    _purchasedSongDic = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < _songsArray.count; i++) {
        Song *song = [_songsArray objectForKey:_songsArray.allKeys[i]];
        [_purchasedSongDic addObject:song];
    }

    NSComparator cmptr = ^(Song* obj1, Song* obj2){
        if ([obj1.songNumber integerValue] > [obj2.songNumber integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1.songNumber integerValue] < [obj2.songNumber integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    _purchasedSongDic = (NSMutableArray *)[_purchasedSongDic sortedArrayUsingComparator:cmptr];
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
    
    Song *song = _purchasedSongDic[indexPath.row];
    
    cell.lbl_SongTitle.text = [NSString stringWithFormat:@"%@ %@", song.title, song.songNumber];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = _purchasedSongDic[indexPath.row];
    
    [[STKAudioPlayerHelper sharedInstance]playSong:song InAlbum:_album];
}


@end
