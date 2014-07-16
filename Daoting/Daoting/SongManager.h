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

@interface SongManager : NSObject
{
    NSMutableDictionary *_songArrayDictionaryByAlbumName;
}

+ (SongManager *)sharedManager;

- (NSMutableArray *)searchSongArrayByAlbumName:(NSString*) albumName;

@end
