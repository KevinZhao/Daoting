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
    
}

@property (assign, nonatomic) NSInteger              coins;
@property (retain, nonatomic) NSMutableArray        *purchasedSongs;
@property (retain, nonatomic) Album                 *currentAlbum;
@property (retain, nonatomic) Song                  *currentSong;
@property (assign, nonatomic) double                 currentProgress;

@property (strong, nonatomic) NSMutableDictionary   *playingQueue;
@property (strong, nonatomic) NSMutableDictionary   *purchasedQueue;

+(instancetype)sharedAppData;
+(NSString*)filePath;


-(void)save;

@end
