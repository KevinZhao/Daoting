//
//  SongManager.h
//  Daoting
//
//  Created by Kevin on 14/7/16.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Song.h"
#import "AFNetworking.h"
#import "AFDownloadHelper.h"
#import "Album.h"
#import "AlbumManager.h"

///////////////////////////////////////////////////////////////////////////
@protocol SongManagerDelegate <NSObject>

- (void)onSongUpdated;

@end
///////////////////////////////////////////////////////////////////////////

@interface SongManager : NSObject
{
    NSMutableDictionary *_songArrayDictionaryByAlbumName;
}

@property (readwrite, unsafe_unretained) id<SongManagerDelegate> delegate;

+ (SongManager *)sharedManager;

- (NSMutableArray *)searchSongArrayByAlbumName:(NSString*) albumName;
- (void)writeBacktoPlist:(NSString*) albumName;

- (void)updateSongs:(NSString *)albumShortName;

@end
