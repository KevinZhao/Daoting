//
//  PurchasedSongViewController.h
//  Daoting
//
//  Created by Kevin on 14/7/4.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppData.h"
#import "PurchasedAlbumCell.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "PurchasedSongViewController.h"
#import "AlbumManager.h"
#import "CategoryManager.h"


@interface PurchasedAlbumViewController : UITableViewController
{
    AppData *_appData;
}

@end
