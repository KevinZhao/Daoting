//
//  STKAudioPlayerDelegate.h
//  Daoting
//
//  Created by Kevin on 14-5-29.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKAudioPlayer.h"
#import "AppData.h"
#import "SampleQueueId.h"
#import "AFNetWorking.h"
#import <AVFoundation/AVFoundation.h>
#import "AlbumManager.h"
#import "SongManager.h"
#import "TSMessage.h"
#import "CategoryManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIImageView+AFNetworking.h"
#import "PurchaseRecordsHelper.h"


@class STKAudioPlayerHelper;

@protocol STKAudioPlayerHelperDelegate <NSObject>

/// Raised when an item has started playing
-(void) onPlayerHelperSongChanged;
-(void) onProgressUpdated;
-(void) onPlayerPaused;

@end


@interface STKAudioPlayerHelper : NSObject <STKAudioPlayerDelegate>
{
    STKAudioPlayer*                 _audioPlayer;
    NSTimer*                        _timer;
    double                          _progress;
    AppData*                        _appData;
    double                          _duration;
    PurchaseRecordsHelper*          _sharedPurchaseRecordsHelper;
}

+ (STKAudioPlayerHelper *)sharedInstance;

@property (nonatomic, assign) STKAudioPlayerState playerState;
@property (nonatomic, assign) BOOL isPausedByUserAction;
@property (nonatomic, assign) double duration;
@property (nonatomic, assign) double progress;
@property (readwrite, unsafe_unretained) id<STKAudioPlayerHelperDelegate> delegate;

-(void)playSong:(Song *)song InAlbum:(Album*)album; 
-(void)pauseSong;
-(void)interruptSong;

-(void)playNextSong;
-(void)playPreviousSong;

-(void)seekToProgress:(float)progress;

@end

