//
//  PurchasedSongViewController.h
//  Daoting
//
//  Created by Kevin on 14/7/4.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppData.h"

@interface PurchasedAlbumCell : UITableViewCell
{
    
}

@property (nonatomic, strong) IBOutlet UILabel      *lbl_albumTitle;

@end


@interface PurchasedSongViewController : UITableViewController
{
    AppData *_appData;
}

@end
