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
#import "StreamKitHelper.h"
#import "AppData.h"
#import "AFNetWorkingOperationManagerHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{

}

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) long *coins;

@end
