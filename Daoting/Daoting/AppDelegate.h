//
//  AppDelegate.h
//  Daoting
//
//  Created by 赵 克鸣 on 14-3-12.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoinIAPHelper.h"
#import "STKAudioPlayer.h"
#import "AppData.h"
#import "AFDownloadHelper.h"
#import "STKAudioPlayerHelper.h"
#import "WXApi.h"
#import "CategoryManager.h"
#import "AppData.h"
#import "StoreKit/StoreKit.h"
#import "CoinIAPHelper.h"
#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import "AFNetworkActivityIndicatorManager.h"
#import "XGPush.h"
#import "STKAudioPlayerHelper.h"
#import "UserManagement.h"
//#import <TencentOpenAPI/TencentOAuth.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    AppData *_appData;
    STKAudioPlayerHelper *_sharedAudioPlayerHelper;
}

@property (strong, nonatomic) UIWindow          *window;
@property (nonatomic, retain) NSMutableArray    *coin_products;
@property (nonatomic, retain) NSMutableArray    *subscription_products;
@property (nonatomic, retain) NSString          *appUrlinAws;

@property (strong, nonatomic) UIColor   *defaultColor_dark;
@property (strong, nonatomic) UIColor   *defaultColor_light;
@property (strong, nonatomic) UIColor   *defaultBackgroundColor;

@end
