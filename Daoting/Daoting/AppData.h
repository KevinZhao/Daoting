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

@interface AppData : NSObject <NSCoding>
{
    
}

@property (assign, nonatomic) double coins;
@property (retain, nonatomic) NSMutableArray *purchasedSongs;
@property (retain, nonatomic) Song *currentPlayingSong;
@property (assign, nonatomic) double currentPlayingProgress;

+(instancetype)sharedAppData;
+(NSString*)filePath;

-(void)save;

@end
