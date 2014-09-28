//
//  AlbumTableViewController.h
//  Daoting
//
//  Created by Kevin on 14-5-12.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppData.h"
#import "AppDelegate.h"
#import "AudioCategory.h"

@interface AlbumTableViewController : UITableViewController<ICategoryManagerDelegate>
{
    NSMutableArray      *_albumArray;
    AppDelegate         *_appdelegate;
    AudioCategory       *_category;
}

@property (nonatomic, retain) NSMutableArray *albumArray;

- (void)setDetailItem:(AudioCategory *)category;

@end
