//
//  STKAudioPlayerDelegate.m
//  Daoting
//
//  Created by Kevin on 14-5-29.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "STKAudioPlayerHelper.h"

@implementation STKAudioPlayerHelper

+ (STKAudioPlayerHelper *)sharedInstance {
    static dispatch_once_t once;
    static STKAudioPlayerHelper * sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [[STKAudioPlayerHelper alloc]init];
        
    });
    return sharedInstance;
}

+ (STKAudioPlayer *)sharedAudioPlayer{
    static dispatch_once_t once;
    static STKAudioPlayer * sharedAudioPlayer;
    dispatch_once(&once, ^{
        
        sharedAudioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
        sharedAudioPlayer.meteringEnabled = YES;
        sharedAudioPlayer.volume = 1;
        
    });
    return sharedAudioPlayer;
}

-(void)playSong:(Song *)song InAlbum:(Album*)album AtProgress: (double)progress
{
    //Check the file is in local reposistory
    if (![[song.filePath absoluteString] isEqualToString:@""] ) {
                
        //4.play from local reposistory for the song
        STKDataSource* fileDataSource = [STKAudioPlayer dataSourceFromURL:song.filePath];
        [[STKAudioPlayerHelper sharedAudioPlayer] setDataSource:fileDataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:song.Url andCount:0]];
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
                        [[STKAudioPlayerHelper sharedAudioPlayer] setDataSource:URLDataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:song.Url andCount:0]];
                    }
                        break;
                        
                    default:
                        break;
                    }
    }
    
    [AppData sharedAppData].currentAlbum = album;
    [AppData sharedAppData].currentSong = song;
    [AppData sharedAppData].currentProgress = progress;
    
}

/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    NSLog(@"started");
    
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
