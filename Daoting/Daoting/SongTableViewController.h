//
//  SongTableViewController.h
//  Daoting
//
//  Created by Kevin on 14-5-12.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "Song.h"
#import "SongTableViewCell.h"
#import "PlayerTableViewCell.h"

@interface SongTableViewController : UIViewController
{
    NSMutableArray      *_songs;
    UITableView         *_tableview;
}
    - (void)setDetailItem:(Album *)Album;
@end
