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



@interface AFDownloadHelper : NSObject
{
    
}



+ (AFHTTPRequestOperationManager *)sharedOperationManager;
+ (AFDownloadHelper *)sharedAFDownloadHelper;


- (void)downloadSong:(Song*) song inAlbum:(Album*) album;

-(AFHTTPRequestOperation *)searchOperationbyKey:(NSString *)key;

@end
