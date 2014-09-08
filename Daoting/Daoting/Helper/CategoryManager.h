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

@interface CategoryManager : NSObject
{
    NSMutableArray      *_categoryArray;
}

@property (nonatomic, retain) NSMutableArray        *categoryArray;


+ (CategoryManager *)sharedManager;

- (Album*)searchAlbumByShortName:(NSString*) albumShortName;
- (NSMutableArray*) searchAlbumByCategory:(AudioCategory *) category;
- (NSMutableArray* ) searchSongByAlbum:(Album *) album;

@end
