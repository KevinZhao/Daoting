//
//  AlbumManager.h
//  Daoting
//
//  Created by Kevin on 14/7/15.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Album.h"
#import "AFNetworking.h"
#import "SongManager.h"

@protocol AlbumManagerDelegate <NSObject>

- (void)onAlbumUpdated;

@end

@interface AlbumManager : NSObject
{
    NSMutableArray      *_albums;
    BOOL                isUpdating;
}

@property (nonatomic, retain)  NSMutableArray      *albums;
@property (readwrite, unsafe_unretained) id<AlbumManagerDelegate> delegate;


+ (AlbumManager *)sharedManager;

- (Album *)searchAlbumByShortName:(NSString*) shortName;
- (void)writeBacktoPlist;
- (void)foundNewSonginAlbum:(Album*) newAlbum;

@end
