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
#import "UserCell.h"
#import "ClearCacheViewController.h"
#import "PurchasedAlbumViewController.h"
#import "AppData.h"
#import "AppDelegate.h"
#import "UserManagement.h"
#import "AppData.h"
#import "UIImage+RoundRect.h"

@interface SettingViewController : UITableViewController<IUserManagementDelegate>
{
    AppData         *_appData;
    AppDelegate     *_appdelegate;
    
    UserManagement    *_sharedUserManagement;
}

@end
