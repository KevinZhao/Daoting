//
//  PurchasedSongViewController.h
//  Daoting
//
//  Created by Kevin on 14/7/9.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PurchasedSongCell.h"
#import "Song.h"
#import "Album.h"
#import "STKAudioPlayerHelper.h"

@interface PurchasedSongViewController : UITableViewController

@property (nonatomic, retain) NSMutableDictionary   *songsArray;
//@property (nonatomic, retain) NSString              *albumShortname;
@property (nonatomic, retain) NSMutableArray        *purchasedSongDic;
@property (nonatomic, retain) Album                 *album;

@end
