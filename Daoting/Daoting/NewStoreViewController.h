//
//  NewStoreViewController.h
//  Daoting
//
//  Created by Kevin on 14/8/21.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAPHelper.h"
#import "AppData.h"
#import "AppDelegate.h"
#import "CurrentCoinCell.h"
#import "ShareCell.h"
#import "PurchaseCoinCell.h"
#import "TSMessage.h"
#import "FBShimmering.h"
#import "FBshimmeringView.h"
#import "PurchaseRecordsHelper.h"


@interface NewStoreViewController : UITableViewController<IAPHelperDelegate>
{
    AppData                     *_appData;
    AppDelegate                 *_appDelegate;
    UIActivityIndicatorView     *_spinner;
    NSArray                     *_coinProducts;
    NSArray                     *_subscriptionProducts;
    
    //NSTimer                     *_timer;
}

@end
