//
//  StoreTableViewController.h
//  Daoting
//
//  Created by Kevin on 14/6/8.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "TSMessage.h"

@interface StoreViewController : UITableViewController<IAPHelperDelegate>
{
    AppData         *_appData;
    AppDelegate     *_appDelegate;
    UIActivityIndicatorView *_spinner;
}

@property (nonatomic, strong) NSArray *products;

@property (nonatomic, strong) IBOutlet UILabel *lbl_currentCoins;

//@property (nonatomic, strong) IBOutlet UILabelStrikeThrough *lbl_120yuan;
//@property (nonatomic, strong) IBOutlet UILabelStrikeThrough *lbl_300yuan;
//@property (nonatomic, strong) IBOutlet UILabelStrikeThrough *lbl_60yuan;
//@property (nonatomic, strong) IBOutlet UILabelStrikeThrough *lbl_30yuan;


-(void)showNotification:(NSString *)notification;

@end
