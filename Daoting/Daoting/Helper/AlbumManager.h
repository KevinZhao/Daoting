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

@protocol AlbumManagerDelegate <NSObject>

- (void)onAlbumUpdated;

@end

@interface AlbumManager : NSObject
{
    NSMutableArray      *_albums;
    
}

@property (nonatomic, retain)  NSMutableArray      *albums;
@property (readwrite, unsafe_unretained) id<AlbumManagerDelegate> delegate;


+ (AlbumManager *)sharedManager;

- (Album *)searchAlbumByShortName:(NSString*) shortName;
- (void)writeBacktoPlist;

@end
