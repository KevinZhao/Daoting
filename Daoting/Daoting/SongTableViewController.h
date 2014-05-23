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
#import "SongCell.h"
#import "AFNetworking.h"

@interface SongTableViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray      *_songs;
    UITableView         *_tableview;
    Album               *_album;
    AFHTTPRequestOperationManager *_operationManager;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;


- (void)setDetailItem:(Album *)album;

@end
