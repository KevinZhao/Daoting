//
//  SettingViewController.h
//  Daoting
//
//  Created by Kevin on 14/6/27.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingCellDisclosure.h"
#import "SettingCellSwitch.h"
#import "ClearCacheViewController.h"
#import "PurchasedAlbumViewController.h"
#import "AppData.h"

@interface SettingViewController : UITableViewController
{
    AppData *_appData;
}

@end
