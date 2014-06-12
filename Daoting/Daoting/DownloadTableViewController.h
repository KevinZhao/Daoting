//
//  DownloadTableViewController.h
//  Daoting
//
//  Created by Kevin on 14/6/5.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetWorkingOperationManagerHelper.h"
#import "DownloadCell.h"
#import "AFNetworking.h"

@interface DownloadTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView                         *_tableview;
    NSTimer                             *_timer;
}

@property (nonatomic, strong) IBOutlet UITableView *tableview;


@end
