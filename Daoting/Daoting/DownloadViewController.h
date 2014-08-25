//
//  DownloadTableViewController.h
//  Daoting
//
//  Created by Kevin on 14/6/5.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFDownloadHelper.h"
#import "DownloadCell.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"

@interface DownloadViewController : UITableViewController
{
    NSTimer                             *_timer;
    NSOperationQueue                    *_downloadQueue;
    AppDelegate                         *_appDelegate;
    UILabel                             *_lbl_noDownloadQueue;
}

@property (nonatomic, strong) IBOutlet UIBarButtonItem  *barbtn_cancelAll;
@property (nonatomic, strong) IBOutlet UIImageView      *img_background;

- (IBAction) cancelAll:(id)sender;

@end
