//
//  AppData.h
//  Daoting
//
//  Created by Kevin on 14-5-26.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeychainWrapper.h"
#import "Song.h"
#import "Album.h"

@interface AppData : NSObject <NSCoding>
{
    NSUbiquitousKeyValueStore   *iCloudStore;
}

@property (assign, nonatomic) NSInteger             coins;

@property (retain, nonatomic) Album                 *currentAlbum;
@property (retain, nonatomic) Song                  *currentSong;

@property (strong, nonatomic) NSMutableDictionary   *playingBackProgressQueue;
@property (strong, nonatomic) NSMutableDictionary   *playingPositionQueue;

@property (strong, nonatomic) NSMutableDictionary   *purchasedQueue;

@property (strong, nonatomic) NSMutableDictionary   *dailyCheckinQueue;

@property (nonatomic, assign) NSInteger purchaseTimes;
@property (nonatomic, assign) BOOL isAutoPurchase;
@property (nonatomic, assign) BOOL isAutoPlay;

+(instancetype)sharedAppData;
//+(NSString*)filePath;

-(void)save;
-(void)updateToiCloud;
-(void)updateFromiCloud;

-(BOOL)songNumber:(NSString *)songNumber ispurchasedwithAlbum:(NSString*)albumShortname;
-(BOOL)addtoPurchasedQueue:(Song *)songNumber withAlbumShortname:(NSString *)albumShortname;

-(void) cleariCloudData;
@end
