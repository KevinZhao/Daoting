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
        AppData *_appData = [AppData sharedAppData];
        
        _appData.coins = 500;
        [_appData save];
    }
    
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
    
    [[UIApplication sharedApplication]registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge) | (UIRemoteNotificationTypeSound) | (UIRemoteNotificationTypeAlert)];
    
    //Customize system default color
    self.defaultColor = [UIColor colorWithRed:0.2 green:.995 blue:0.3 alpha:1.0];
    
    [[UITabBar appearance] setSelectedImageTintColor:_defaultColor];
    [[UIBarButtonItem appearance]setTintColor:_defaultColor];
    [[UINavigationBar appearance]setTintColor:_defaultColor];
    
     //add auto play logic to appdelegate
     if ([AppData sharedAppData].isAutoPlay)
     {
         [self autoPlay];
     }
    
    return YES;
}

- (void)autoPlay
{
    if (([AppData sharedAppData].currentSong != nil) && ([AppData sharedAppData].currentAlbum != nil)) {
        
        [[STKAudioPlayerHelper sharedInstance]playSong:[AppData sharedAppData].currentSong InAlbum:[AppData sharedAppData].currentAlbum];
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
    //todo, Cheating avoidance, will implement next version
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token, error:%@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

@end
