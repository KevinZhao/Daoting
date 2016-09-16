//
//  ClearCacheViewController.h
//  Daoting
//
//  Created by Kevin on 14/7/4.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClearCacheCell.h"
#import "CategoryManager.h"

@interface ClearCacheViewController : UITableViewController <UIAlertViewDelegate>

{
    NSMutableArray  *_albumShortnameArray;
    NSString        *_storagePath;
    NSIndexPath     *_selectedIndexPath;
}

-(IBAction)clearCache:(id)sender;

@end
