//
//  CategoryManager.h
//  Daoting
//
//  Created by Kevin on 14/9/1.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioCategory.h"
#import "Album.h"
#import "Song.h"


enum
{
    Initializing  = 0,
    InitializingCompleted = 1,
    Upgrating     = 2,
    UpgratingCompleted = 3
};
typedef NSInteger UpdatingStatus;

@interface CategoryManager : NSObject
{
    NSMutableArray      *_categoryArray;
}

@property (nonatomic, assign) UpdatingStatus        categoryUpdatingStatus;
@property (nonatomic, assign) UpdatingStatus        albumUpdatingStatus;
@property (nonatomic, assign) UpdatingStatus        songUpdatingStatus;

@property (nonatomic, retain) NSMutableArray        *categoryArray;


+ (CategoryManager *)sharedManager;

- (Album*)searchAlbumByShortName:(NSString*) albumShortName;
- (NSMutableArray*) searchAlbumByCategory:(AudioCategory *) category;
- (NSMutableArray* ) searchSongByAlbum:(Album *) album;

@end
