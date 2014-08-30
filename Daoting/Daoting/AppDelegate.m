//
//  AppDelegate.m
//  Daoting
//
//  Created by 赵 克鸣 on 14-3-12.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "XGPush.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSError* error;
    [AlbumManager sharedManager];
    
    //Configure Audio Session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
	[audioSession setActive:YES error:&error];
    [audioSession setPreferredIOBufferDuration:0.1 error:&error];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //Configure AFNetworking
    [[AFDownloadHelper sharedOperationManager].operationQueue setMaxConcurrentOperationCount:2];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    //Initialize the coins for first time running the app
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[AppData filePath]])
    {
        _appData = [AppData sharedAppData];
        
        _appData.coins = 300;
        [_appData save];
    }
    
    _appData = [AppData sharedAppData];
    
    //enable IAP
    [[CoinIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
        }
    }];
    
    [STKAudioPlayerHelper sharedInstance];
    
    //configure shareSDK
    _appUrlinAws = @"http://t.cn/RPtnXCE";
    [ShareSDK registerApp:@"16bbd8d2753a"];
    
    //[ShareSDK connectSinaWeiboWithAppKey:@"3201194191"
    //                           appSecret:@"0334252914651e8f76bad63337b3b78f"
    //                         redirectUri:@"http://appgo.cn"];
    
    [ShareSDK connectWeChatTimelineWithAppId:@"wx134b0f70f3612fe8" wechatCls:[WXApi class]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSystemTimeChanged:) name:UIApplicationSignificantTimeChangeNotification object:nil];
    
    
    //Customize system default color
    self.defaultColor_dark = [UIColor colorWithRed:0.125 green:0.64 blue:0.34 alpha:1.0];
    self.defaultColor_light = [UIColor colorWithRed:0.39 green:0.785 blue:0.097 alpha:1.0];
    self.defaultBackgroundColor = [UIColor colorWithRed:0.9378 green:0.9141 blue:0.8554 alpha:0.95];
    
    [[UITabBar appearance] setSelectedImageTintColor:_defaultColor_dark];
    [[UIBarButtonItem appearance]setTintColor:_defaultColor_dark];
    [[UINavigationBar appearance]setTintColor:_defaultColor_dark];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
      _defaultColor_dark, NSForegroundColorAttributeName, 
      nil]];
    
    [[UITableView appearance]setBackgroundColor:_defaultBackgroundColor];
    [[UITableViewCell appearance]setBackgroundColor:_defaultBackgroundColor];
    
    [[UIButton appearance]setTitleColor:_defaultColor_dark forState:UIControlStateNormal];
    [[UIButton appearance]setTitleColor:_defaultColor_light forState:UIControlStateSelected];
    
     //add auto play logic to appdelegate
     if (_appData.isAutoPlay)
     {
         [self autoPlay];
     }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    
    //Notification with XG
    //let device know we want to recive MSG-WL
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (version >= 8.0)
    {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else
    {
        //Deprecated in ios 8.0
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    }

    
    //init push informatoin
    [XGPush startApp:2200044229 appKey:@"IUZN34V429XQ"];
    //Handle click notification.
    [XGPush handleLaunching:launchOptions];
    //End
    
    return YES;
}

-(void)audioInterruptionNotification:(NSNotification *) aNotification
{
    _appData = [AppData sharedAppData];
    
    NSLog(@"Interrupt %@", aNotification);
    NSDictionary *dict = [aNotification userInfo];
    NSUInteger typeKey = [[dict objectForKey:@"AVAudioSessionInterruptionTypeKey"] unsignedIntegerValue];
    NSLog(@"%d", typeKey == AVAudioSessionInterruptionTypeBegan);
    if (typeKey == AVAudioSessionInterruptionTypeBegan)
    {
        [[STKAudioPlayerHelper sharedInstance] pauseSong];
    }
    else {
        [[STKAudioPlayerHelper sharedInstance] playSong: _appData.currentSong InAlbum:_appData.currentAlbum];
    }
}

- (void)autoPlay
{    
    if ((_appData.currentSong != nil) && (_appData.currentAlbum != nil)) {
        
        [[STKAudioPlayerHelper sharedInstance]playSong:_appData.currentSong InAlbum:_appData.currentAlbum];
    }
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url sourceApplication:sourceApplication annotation:annotation wxDelegate:self];
}

- (void) handleSystemTimeChanged:(NSNotification *) notification
{
    //Revisit in next Version
    //Cheating avoidance, will implement next version
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //Notification with XG
    NSString *deviceTokenStr = [XGPush registerDevice: deviceToken];
    
    NSLog(@"My token is: %@", deviceTokenStr);
    //End
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token, error:%@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //Notification with XG
    [XGPush handleReceiveNotification:userInfo];
    //End
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

@end
