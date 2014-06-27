//
//  StoreTableViewController.h
//  Daoting
//
//  Created by Kevin on 14/6/8.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppData.h"
#import "StoreKit/StoreKit.h"
#import "UILabelStrikeThrough.h"
#import "CoinIAPHelper.h"
#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>

@interface StoreViewController : UIViewController
{
    AppData *_appData;
}

@property (nonatomic, strong) NSArray *products;

@property (nonatomic, strong) IBOutlet UILabel *lbl_coins;

@property (nonatomic, strong) IBOutlet UILabelStrikeThrough *lbl_100yuan;
@property (nonatomic, strong) IBOutlet UILabelStrikeThrough *lbl_250yuan;


@property (nonatomic, strong) IBOutlet UIView* notificationView;

-(void)showNotification:(NSString *)notification;

@end