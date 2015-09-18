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
    [[CategoryManager sharedManager] update];
    
    [self configureAudioSession];
    
    //Configure AFNetworking
    [self configureAFNetworking];
    
    _appData = [AppData sharedAppData];
    
    //ConfigureIAP
    [self configureIAP];
    
    //configure shareSDK
    [self configureShareSDK];
    
    //Add observer to receive system time change event
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSystemTimeChanged:) name:UIApplicationSignificantTimeChangeNotification object:nil];
    
    //Customize system default color
    [self configureSystemColorTheme];
    
     //Check if system autoPlay is on
     if (_appData.isAutoPlay)
     {
         [self autoPlay];
     }
    
    //Notification with XG
    [self configureXGPush:launchOptions];
    
    //begin received remote events
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //if ios version > 7.0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (version >= 7.0){
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:60 * 60 * 6];
    }
    
    return YES;
}

#pragma mark initial setup for didFinishLaunchingWithOptions

-(void)configureAudioSession
{
    NSError* error;
    
    //Configure Audio Session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    [audioSession setActive:YES error:&error];
    [audioSession setPreferredIOBufferDuration:0.1 error:&error];
    
    //Add observer to receive audio interrupt notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    
    if (error) {
        NSLog(@"Configure Audio Session Error: %@", error);
    }
    
    _sharedAudioPlayerHelper = [STKAudioPlayerHelper sharedInstance];
}

-(void)configureAFNetworking
{
    [[AFDownloadHelper sharedOperationManager].operationQueue setMaxConcurrentOperationCount:1];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}

-(void)configureShareSDK
{
    _appUrlinAws = @"http://t.cn/RPtnXCE";
    [ShareSDK registerApp:@"16bbd8d2753a"];
    
    //[ShareSDK connectSinaWeiboWithAppKey:@"3201194191"
    //                           appSecret:@"0334252914651e8f76bad63337b3b78f"
    //                         redirectUri:@"http://appgo.cn"];
    
    [ShareSDK connectWeChatTimelineWithAppId:@"wx134b0f70f3612fe8" wechatCls:[WXApi class]];
    
}

-(void)configureSystemColorTheme
{
    self.defaultColor_dark = [UIColor colorWithRed:0.125 green:0.64 blue:0.34 alpha:1.0];
    self.defaultColor_light = [UIColor colorWithRed:0.39 green:0.785 blue:0.097 alpha:1.0];
    self.defaultBackgroundColor = [UIColor colorWithRed:0.9378 green:0.9141 blue:0.8554 alpha:1.0];
    
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
}

-(void)configureXGPush:(NSDictionary *)launchOptions
{
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
}

-(void)configureIAP
{
    //enable IAP
    [[CoinIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            
            _coin_products = [[NSMutableArray alloc]init];
            _subscription_products = [[NSMutableArray alloc]init];
            
            for (SKProduct *product in products) {
                
                //拆分金币和订阅类型IAP
                if ([product.productIdentifier rangeOfString:@"coins"].length > 0) {
                    
                    [_coin_products addObject:product];
                    
                }else if ([product.productIdentifier rangeOfString:@"subscription"].length > 0){
                    
                    [_subscription_products addObject:product];
                }
            }
            
        }
    }];
}

#pragma mark handle audio interrupt

-(void)audioInterruptionNotification:(NSNotification *) aNotification
{
    //todo, bug
    
    NSLog(@"Interrupt %@", aNotification);
    NSDictionary *dict = [aNotification userInfo];
    NSUInteger typeKey = [[dict objectForKey:@"AVAudioSessionInterruptionTypeKey"] unsignedIntegerValue];
    
    NSLog(@"%lu", (unsigned long)typeKey);
    if (typeKey == AVAudioSessionInterruptionTypeBegan)
    {
        [_sharedAudioPlayerHelper interruptSong];
    }
    
    if ((typeKey == AVAudioSessionInterruptionTypeEnded) && (!_sharedAudioPlayerHelper.isPausedByUserAction))
    {
        //[_sharedAudioPlayerHelper playSong: _appData.currentSong InAlbum:_appData.currentAlbum];
    }
}

#pragma mark auto replay

- (void)autoPlay
{    
    if ((_appData.currentSong != nil) && (_appData.currentAlbum != nil)) {
        
        [[STKAudioPlayerHelper sharedInstance]playSong:_appData.currentSong InAlbum:_appData.currentAlbum];
    }
}

#pragma mark UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    //return [TencentOAuth HandleOpenURL:url];
    
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([sourceApplication isEqualToString:@"com.tencent.xin"]) {
        UserManagement* _sharedUserManagement = [UserManagement sharedManager];
        
        return [WXApi handleOpenURL:url delegate:_sharedUserManagement];
        //[ShareSDK handleOpenURL:url sourceApplication:sourceApplication annotation:annotation wxDelegate:self];
    }
    
    if ([sourceApplication isEqualToString:@"com.tencent.mqq"]) {
        return false; //[TencentOAuth HandleOpenURL:url];
    }
    
    return false;
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

//Background fetching
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Background Fetching");
    
    [[CategoryManager sharedManager] insertNewObjectForFetchWithCompletionHandler:completionHandler];
}

//Receive Remote Control Event
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                if (_sharedAudioPlayerHelper.playerState == STKAudioPlayerStatePlaying) {
                    
                    //Pause
                    [_sharedAudioPlayerHelper pauseSong];
                
                }else{
                    
                    //Resume
                    [_sharedAudioPlayerHelper playSong:_appData.currentSong InAlbum:_appData.currentAlbum];
                }
                break;
            }
                
            case UIEventSubtypeRemoteControlPause:
            {
                [_sharedAudioPlayerHelper pauseSong];
 
                break;
            }
 
            case UIEventSubtypeRemoteControlPlay:
            {
                
                [_sharedAudioPlayerHelper playSong:_appData.currentSong InAlbum:_appData.currentAlbum];
                break;
            }
                
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                [_sharedAudioPlayerHelper playPreviousSong];
                break;
            }
                
            case UIEventSubtypeRemoteControlNextTrack:
            {
                [_sharedAudioPlayerHelper playNextSong];
                break;
            }
                
            default:
                break;
        }
    }
}

@end
