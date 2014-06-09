//
//  AppDelegate.m
//  Daoting
//
//  Created by 赵 克鸣 on 14-3-12.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate()
{

}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSError* error;
    //Configure Audio Session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
	[audioSession setActive:YES error:&error];
    [audioSession setPreferredIOBufferDuration:0.1 error:&error];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //Configure AFNetworking
    [[AFNetWorkingOperationManagerHelper sharedInstance].operationQueue setMaxConcurrentOperationCount:2];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
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
    
    _audioPlayer = [STKAudioPlayerHelper sharedAudioPlayer];
    _audioPlayer.delegate = [STKAudioPlayerHelper sharedInstance];
    
    return YES;
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

#pragma mark - STKAudioPlayerDelegate

/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    //NSLog(@"started");
    
}

/// Raised when an item has finished buffering (may or may not be the currently playing item)
/// This event may be raised multiple times for the same item if seek is invoked on the player
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    
}

/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    // this is test code
    /* if (state == STKAudioPlayerStatePlaying) {
     Song *song = _currentSong;
     
     NSString *bundleDocumentDirectoryPath =
     [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
     
     NSString *plistPath =
     [bundleDocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_SongList.plist", _album.shortName]];
     NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
     
     NSMutableDictionary *songArray = [dictionary objectForKey:[NSString stringWithFormat:@"%@", song.songNumber]];
     [songArray setObject:[self formatTimeFromSeconds:_audioPlayer.duration] forKey:@"Duration"];
     
     if ([dictionary writeToFile:plistPath atomically:NO]) {
     NSLog(@"song %d, success with duration of %@", [song.songNumber integerValue], [self formatTimeFromSeconds:_audioPlayer.duration] );
     }
     
     if ([song.songNumber integerValue] < _songs.count) {
     
     [_audioPlayer stop];
     }
     
     }*/
}

/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    if (stopReason == STKAudioPlayerStopReasonEof) {
        //play next song
       // NSInteger i = [[AppData sharedAppData].currentPlayingSong.songNumber integerValue];
        
        //if ( i < (_songs.count)) {
        //    Song *song = [_songs objectAtIndex:(i)];
            
        //    NSLog(@"play next song %@",song.songNumber);
        //    [self playSong:song];
        //}
    }
    
}
/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    
}

@end
