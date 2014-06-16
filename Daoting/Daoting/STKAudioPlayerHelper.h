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


@interface STKAudioPlayerHelper : NSObject <STKAudioPlayerDelegate>
{
    STKAudioPlayer  *_audioPlayer;
    NSTimer         *_timer;
    double          _progress;
}

+ (STKAudioPlayerHelper *)sharedInstance;

@property (nonatomic, retain) STKAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSMutableArray *playbackList;

-(void)playSong:(Song *)song InAlbum:(Album*)album; 
-(void)pauseSong;

@end
