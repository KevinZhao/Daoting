//
//  STKAudioPlayerDelegate.m
//  Daoting
//
//  Created by Kevin on 14-5-29.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "STKAudioPlayerHelper.h"

@implementation STKAudioPlayerHelper

@synthesize audioPlayer;

+ (STKAudioPlayerHelper *)sharedInstance {
    static dispatch_once_t once;
    static STKAudioPlayerHelper * sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [[STKAudioPlayerHelper alloc]init];
        
    });
    return sharedInstance;
}

- (STKAudioPlayerHelper *)init
{
    //configure STKAudioPlayer
    audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
    audioPlayer.meteringEnabled = YES;
    audioPlayer.volume = 1;
    
    audioPlayer.delegate = self;
    
    //Regist notification for audio route change
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(audioRouteChangeHandler:)
                                                 name: AVAudioSessionRouteChangeNotification
                                               object: [AVAudioSession sharedInstance]];
    
    
    return self;
}

- (void)audioRouteChangeHandler:(NSNotification*)notification
{
    if ([[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey]integerValue]
        == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        
        [self pauseSong];
    }
}

-(void)playSong:(Song *)song InAlbum:(Album*)album AtProgress: (double)progress
{
    //Check the file is in local reposistory
    if (![[song.filePath absoluteString] isEqualToString:@""] ) {
        
        NSURL *songURL = [NSURL fileURLWithPath:[song.filePath absoluteString]];
        
        //play from local reposistory for the song
        STKDataSource* fileDataSource = [STKAudioPlayer dataSourceFromURL:songURL];
        [audioPlayer setDataSource:fileDataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:songURL  andCount:0]];
    }
    else
    {
        AFNetworkReachabilityStatus currentNetWorkStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
                
        switch (currentNetWorkStatus) {
                    case AFNetworkReachabilityStatusNotReachable:
                        //Notify user current net work is not reachable
                        
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"网络异常" message:@"当前网络无法连接" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        
                        [alert show];
                    }
                        
                        break;
                    case AFNetworkReachabilityStatusReachableViaWWAN:
                        //Ask user if they want to play from URL
                        
                        break;
                    case AFNetworkReachabilityStatusReachableViaWiFi:
                    {
                        //play from URL in wifi mode
                        STKDataSource* URLDataSource = [STKAudioPlayer dataSourceFromURL:song.Url];
                        [audioPlayer setDataSource:URLDataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:song.Url andCount:0]];
                    }
                        break;
                        
                    default:
                        break;
                    }
    }
    
    [AppData sharedAppData].currentAlbum = album;
    [AppData sharedAppData].currentSong = song;
    [AppData sharedAppData].currentProgress = progress;
    
    [[AppData sharedAppData] save];
    
}

-(void)pauseSong
{
    [AppData sharedAppData].currentProgress = audioPlayer.progress;
    
    [[AppData sharedAppData] save];
    [audioPlayer pause];
}

/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    NSLog(@"started playing");
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
         
     Song *song = [AppData sharedAppData].currentSong;
     
     NSString *bundleDocumentDirectoryPath =
     [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
     
     NSString *plistPath =
     [bundleDocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_SongList.plist",
                                                           [AppData sharedAppData].currentAlbum.shortName]];
     NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
     
     NSMutableDictionary *songArray = [dictionary objectForKey:[NSString stringWithFormat:@"%@", song.songNumber]];
     [songArray setObject:[NSString stringWithFormat:@"%d", 20] forKey:@"Price"];
     
     if ([dictionary writeToFile:plistPath atomically:NO]) {
         NSLog(@"song %d, success with duration of %@", [song.songNumber integerValue], @"25");
     }

    NSMutableArray *songs = [[AppData sharedAppData].playingQueue objectForKey:[AppData sharedAppData].currentAlbum.shortName];
         
     if ([song.songNumber integerValue] < songs.count) {
     
         [[STKAudioPlayerHelper sharedAudioPlayer] stop];
     }
     
     }*/
}

/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    if (stopReason == STKAudioPlayerStopReasonEof) {
        
        //play next song
        NSMutableArray *songs = [[AppData sharedAppData].playingQueue objectForKey:[AppData sharedAppData].currentAlbum.shortName];
        NSInteger previousSongNumber = [[AppData sharedAppData].currentSong.songNumber integerValue];
        
        if ( previousSongNumber < songs.count) {
            
            Song *song = [songs objectAtIndex:(previousSongNumber)];
            [self playSong:song InAlbum:[AppData sharedAppData].currentAlbum AtProgress:0];
        }
    }
    
}
/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    
}

@end
