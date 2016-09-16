//
//  CategoryTableViewController.h
//  Daoting
//
//  Created by Kevin on 14/9/5.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioCategory.h"
#import "CategoryCell.h"
#import "UIImageView+AFNetworking.h"
#import "CategoryManager.h"
#import "AlbumTableViewController.h"

@interface CategoryTableViewController : UITableViewController <ICategoryManagerDelegate>
{
    NSMutableArray      *_categoryArray;
    AppDelegate         *_appdelegate;
}

@end
