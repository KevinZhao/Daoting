//
//  AlbumTableViewController.h
//  Daoting
//
//  Created by Kevin on 14-5-12.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppData.h"
#import "AlbumManager.h"
#import "AppDelegate.h"

@interface AlbumTableViewController : UITableViewController
{
    NSMutableArray      *_albums;
    AppDelegate         *_appdelegate;
}

@property (nonatomic, retain) NSMutableArray *albums;

@end
