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
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
}

@property (strong, nonatomic) UIWindow  *window;
@property (assign, nonatomic) long      *coins;
@property (nonatomic, retain) NSArray   *products;

@end
