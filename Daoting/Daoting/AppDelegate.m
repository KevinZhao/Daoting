//
//  AppDelegate.m
//  Daoting
//
//  Created by 赵 克鸣 on 14-3-12.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSError* error;
    
    //todo: should change to initialize category manager
    [AlbumManager sharedManager];
    
    //Configure Audio Session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
	[audioSession setActive:YES error:&error];
    [audioSession setPreferredIOBufferDuration:0.1 error:&error];
    
    //begin received remote events
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //Configure AFNetworking
    [[AFDownloadHelper sharedOperationManager].operationQueue setMaxConcurrentOperationCount:2];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    //check iCloud for coins
    //Register observer for iCloud coins
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDidChange) name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification object: [NSUbiquitousKeyValueStore defaultStore]];

    if ([[NSUbiquitousKeyValueStore defaultStore] synchronize]) {
        NSLog(@"iCloud Sync successful");

    };
    
    //Initialize appdata from userdefault
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //local user default is not exist, this is a first time run of the app
    if (![fileManager fileExistsAtPath:[AppData filePath]])
    {
        _appData = [AppData sharedAppData];
        _appData.coins = 300;
        
        [_appData updateiCloud];
    }
    //local user default exist, initialize it
    else
    {
        //register to observe notifications from the store
        _appData = [AppData sharedAppData];
        //todo: necessary?
        _appData.coins = [[NSUbiquitousKeyValueStore defaultStore] doubleForKey:@"coins"];
    }
    
    //enable IAP
    [[CoinIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
        }
    }];
    
    //Initialize STKAudioPlayer
    [STKAudioPlayerHelper sharedInstance];
    
    //configure shareSDK
    _appUrlinAws = @"http://t.cn/RPtnXCE";
    [ShareSDK registerApp:@"16bbd8d2753a"];
    
    //[ShareSDK connectSinaWeiboWithAppKey:@"3201194191"
    //                           appSecret:@"0334252914651e8f76bad63337b3b78f"
    //                         redirectUri:@"http://appgo.cn"];
    
    [ShareSDK connectWeChatTimelineWithAppId:@"wx134b0f70f3612fe8" wechatCls:[WXApi class]];
    
    //Add observer to receive system time change event
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
    
     //Check if system autoPlay is on
     if (_appData.isAutoPlay)
     {
         [self autoPlay];
     }
    
    //Add observer to receive audio interrupt notification
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
    
    //Configure XGPush
    [XGPush startApp:2200044229 appKey:@"IUZN34V429XQ"];
    //Handle notification
    [XGPush handleLaunching:launchOptions];
    
    return YES;
}

-(void)storeDidChange
{
    NSLog(@"Received NSUbiquitousKeyValueStoreDidChangeExternallyNotification" );
    
    NSUbiquitousKeyValueStore *iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
    
    long new_cloudCoins= [iCloudStore doubleForKey:@"coins"];
    
    [AppData sharedAppData].coins = new_cloudCoins;
    
    NSLog(@"new_cloudCoins = %ld", new_cloudCoins);
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
