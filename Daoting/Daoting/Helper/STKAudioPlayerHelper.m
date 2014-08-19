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
    self = [super init];
    
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
    
    [self setupTimer];
    _appData = [AppData sharedAppData];
    
    return self;
}

-(void)setupTimer
{
	_timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(tick) userInfo:nil repeats:YES];
	
	[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)tick
{
    if (audioPlayer.progress) {
        
        NSString *key = [NSString stringWithFormat:@"%@_%@", _appData.currentAlbum.shortName, _appData.currentSong.songNumber];
        NSString *progressString = [self formatTimeFromSeconds:audioPlayer.progress];
        [_appData.playingBackProgressQueue setValue:progressString forKey:key];
        
        [_appData save];
    }
}

- (void)audioRouteChangeHandler:(NSNotification*)notification
{
    if ([[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey]integerValue]
        == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        
        [self pauseSong];
    }
}

-(void)playSong:(Song *)song InAlbum:(Album*)album
{
    //Check the file is in local reposistory
    if (![[song.filePath absoluteString] isEqualToString:@""] ) {
        
        NSURL *songURL = [NSURL fileURLWithPath:[song.filePath absoluteString]];
        
        //play from local reposistory for the song
        STKDataSource* fileDataSource = [STKAudioPlayer dataSourceFromURL:songURL];
        [audioPlayer setDataSource:fileDataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:songURL andCount:0]];
    }
    else
    {
        AFNetworkReachabilityStatus currentNetWorkStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
                
        switch (currentNetWorkStatus)
        {
            //no network
            case AFNetworkReachabilityStatusNotReachable:
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"网络异常" message:@"当前网络无法连接" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
                [alert show];
                        
                return;
            }
            break;
                
            //3G
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                //todo
            }
            break;

            //wifi
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                //play from URL in wifi mode
                STKDataSource* URLDataSource = [STKAudioPlayer dataSourceFromURL:song.Url];
                [audioPlayer setDataSource:URLDataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:song.Url andCount:0]];
            }
            break;
                
            //todo: should not do that, it is a tempory solution
            case AFNetworkReachabilityStatusUnknown:
            {
                //play from URL in wifi mode
                STKDataSource* URLDataSource = [STKAudioPlayer dataSourceFromURL:song.Url];
                [audioPlayer setDataSource:URLDataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:song.Url andCount:0]];
                    
                NSLog(@"this is not normal, need to fix in next version");
            }
            
            default:
                break;
        }
    }
    
    //get previous progress
    NSString *key = [NSString stringWithFormat:@"%@_%@", album.shortName, song.songNumber];
    NSString *progressString = [_appData.playingBackProgressQueue objectForKey:key];
    _progress = [self formatProgressFromString:progressString];
    
    [_appData.playingPositionQueue setObject:song.songNumber forKey:album.title];
    
    _appData.currentAlbum = album;
    _appData.currentSong = song;
    
    [_appData save];
}

-(void)pauseSong
{
    [audioPlayer pause];
}

-(void)playNextSong
{
    Album *album = [[AlbumManager sharedManager] searchAlbumByShortName:_appData.currentAlbum.shortName];
    NSMutableArray *songArray = [[SongManager sharedManager] searchSongArrayByAlbumName:album.shortName];
    
    NSInteger currentSongNumber = [_appData.currentSong.songNumber intValue];
    
    if (currentSongNumber < songArray.count) {
        Song *song = [songArray objectAtIndex:currentSongNumber];
        
        [self playSong:song InAlbum:album];
    }
    
    if (self.delegate != nil) {
        
        [self.delegate onPlayerHelperSongChanged];
    }
}

-(void)playPreviousSong
{
    Album *album = [[AlbumManager sharedManager] searchAlbumByShortName:_appData.currentAlbum.shortName];
    NSMutableArray *songArray = [[SongManager sharedManager] searchSongArrayByAlbumName:album.shortName];

    NSInteger currentSongNumber = [_appData.currentSong.songNumber intValue];
    
    if ( currentSongNumber - 1 > 0) {
        
        Song *song = [songArray objectAtIndex:(currentSongNumber -2)];
        
        [self playSong:song InAlbum:album];
    }
    
    [self.delegate onPlayerHelperSongChanged];
}


-(NSString*)formatTimeFromSeconds:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

-(double)formatProgressFromString:(NSString *)progressString
{
    double progress = 0;
    
    NSRange range = NSMakeRange(0, 2);
    NSString *hourString = [progressString substringWithRange:range];
    
    range = NSMakeRange(3, 2);
    NSString *miniteString = [progressString substringWithRange:range];
    
    range = NSMakeRange(6, 2);
    NSString *secondString = [progressString substringWithRange:range];
    
    
    progress = [hourString intValue]*3600 + [miniteString intValue]*60 + [secondString intValue];
    
    return progress;
}



/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)aPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    [audioPlayer seekToTime:_progress];
}

/// Raised when an item has finished buffering (may or may not be the currently playing item)
/// This event may be raised multiple times for the same item if seek is invoked on the player
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    
}

/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    
}

/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    if (stopReason == STKAudioPlayerStopReasonEof) {
        [self playNextSong];
    }
    
}
/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    
}

@end
