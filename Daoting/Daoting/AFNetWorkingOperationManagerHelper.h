//
//  AFNetWorkingOperationManagerHelper.h
//  Daoting
//
//  Created by Kevin on 14-5-27.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetWorking.h"
#import "Song.h"
#import "Album.h"
#import "DownloadStatus.h"


@interface AFNetWorkingOperationManagerHelper : NSObject
{
    
}

@property (nonatomic, retain) NSMutableArray         *downloadQueue;
@property (nonatomic, retain) NSMutableDictionary    *downloadKeyQueue;
@property (nonatomic, retain) NSMutableArray         *downloadStatusQueue;


+ (AFHTTPRequestOperationManager *)sharedInstance;
+ (AFNetWorkingOperationManagerHelper *)sharedManagerHelper;


- (void)downloadSong:(Song*) song inAlbum:(Album*) album;
- (AFHTTPRequestOperation*)searchOperationByKey:(NSString*) key;
- (DownloadingStatus*)searchStatusByKey:(NSString*) key;

@end
