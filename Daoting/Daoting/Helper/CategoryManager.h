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
#import "AFNetWorking.h"
//#import "UIApplication.h"

enum
{
    Initializing  = 0,
    InitializingCompleted = 1,
    Upgrating     = 2,
    UpgratingCompleted = 3
};
typedef NSInteger UpdatingStatus;


@protocol ICategoryManagerDelegate <NSObject>

@optional
-(void) onCategoryUpdated;
-(void) onAlbumUpdated;
-(void) onSongUpdated;

@end

@interface CategoryManager : NSObject
{
    NSInteger updateTaskCount;
    void (^updateCompletionHandler)(UIBackgroundFetchResult);
    
    //(void (^)(UIBackgroundFetchResult))completionHandler;
}

@property (nonatomic, assign) UpdatingStatus        categoryUpdatingStatus;
@property (nonatomic, assign) UpdatingStatus        albumUpdatingStatus;
@property (nonatomic, assign) UpdatingStatus        songUpdatingStatus;

@property (nonatomic, retain) NSMutableArray        *categoryArray;

@property (readwrite, unsafe_unretained) id<ICategoryManagerDelegate> delegate;

- (void)update;

+ (CategoryManager *)sharedManager;

- (AudioCategory*)searchCategoryByShortName:(NSString*) shortName;
- (Album*)searchAlbumByShortName:(NSString*) albumShortName inCategory:(AudioCategory*) category;

- (Album*)searchAlbumByShortName:(NSString*) albumShortName;

- (NSMutableArray*) searchAlbumArrayByCategory:(AudioCategory *) category;
- (NSMutableArray* ) searchSongArrayByAlbum:(Album *) album;

- (void)initializeSongByAlbum:(Album *)album;

- (void) writeBacktoCategoryList;
- (void) writeBacktoAlbumListinCategory:(AudioCategory*) category;
- (void) writeBacktoSongListinAlbum:(Album *)album;

//background fetching
- (void)insertNewObjectForFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler; 

@end
