//
//  StoreTableViewController.h
//  Daoting
//
//  Created by Kevin on 14/6/8.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "StoreCell.h"
#import "StoreKit/StoreKit.h"


@interface StoreTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView         *_tableView;
}

@property (nonatomic, strong) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSArray *products;

@end
