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
#import "CategoryManager.h"

@protocol AFDownloadHelperDelegate <NSObject>

-(void) onFileDownloadProgressed;
-(void) onFileDownloadCompleted;
-(void) onFileDownloadFailed;

@end


@interface AFDownloadHelper : NSObject
{
    
}

@property (readwrite, unsafe_unretained) id<AFDownloadHelperDelegate> delegate;

+ (AFHTTPRequestOperationManager *)sharedOperationManager;
+ (AFDownloadHelper *)sharedAFDownloadHelper;

- (void)downloadSong:(Song*)song inAlbum:(Album*)album;
-(AFHTTPRequestOperation *)searchOperationbyKey:(NSString *)key;

@end
