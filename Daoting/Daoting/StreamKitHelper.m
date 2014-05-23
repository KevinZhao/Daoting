//
//  StreamKitHelper.m
//  Daoting
//
//  Created by Kevin on 14-5-23.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "StreamKitHelper.h"

@implementation StreamKitHelper

+ (STKAudioPlayer *)sharedInstance {
    static dispatch_once_t once;
    static STKAudioPlayer * sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
        sharedInstance.meteringEnabled = YES;
        sharedInstance.volume = 1;
        
    });
    return sharedInstance;
}

@end
