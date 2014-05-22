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

@interface SongTableViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray      *_songs;
    UITableView         *_tableview;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;


    //-(IBAction)clickPageControl:(id)sender;

    - (void)setDetailItem:(Album *)Album;
@end
