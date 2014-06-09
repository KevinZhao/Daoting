//
//  AFNetWorkingOperationManagerHelper.m
//  Daoting
//
//  Created by Kevin on 14-5-27.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "AFNetWorkingOperationManagerHelper.h"

@implementation AFNetWorkingOperationManagerHelper

+ (AFHTTPRequestOperationManager *)sharedInstance {
    static dispatch_once_t once;
    static AFHTTPRequestOperationManager * sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [AFHTTPRequestOperationManager manager];
        
    });
    return sharedInstance;
}

+ (AFNetWorkingOperationManagerHelper *)sharedManagerHelper
{
    static dispatch_once_t once;
    static AFNetWorkingOperationManagerHelper * sharedManagerHelper;
    dispatch_once(&once, ^{
        
        sharedManagerHelper = [[AFNetWorkingOperationManagerHelper alloc]init];
        
    });
    return sharedManagerHelper;
    
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _downloadQueue = [[NSMutableArray alloc]init];
        _downloadKeyQueue = [[NSMutableDictionary alloc]init];
        _downloadStatusQueue = [[NSMutableArray alloc]init];
        
    }
    return self;
}

- (void)downloadSong:(Song*) song inAlbum:(Album*) album
{
    //1. Set download path to temporary directory with album shortname and songnumber combination
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.mp3", album.shortName, song.songNumber];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:fileName];
    
    //2. Create Request and operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:[[NSURLRequest alloc]initWithURL:song.Url]];
    
    //2.1 Configure operation
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [[AFNetWorkingOperationManagerHelper sharedInstance].operationQueue addOperation:operation];
    
    operation.userInfo = [[NSMutableDictionary alloc]init];
    [operation.userInfo setValue:[NSString stringWithFormat:@"%@_%@", album.shortName, song.songNumber] forKey:@"key"];
    
    //2.2 add operation to downloadQueue and downloadKeyQueu for easy search
    [_downloadQueue addObject:operation];
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", album.shortName, song.songNumber];
    
    [_downloadKeyQueue setObject:[NSString stringWithFormat:@"%d", _downloadKeyQueue.count] forKey: key];
    
    DownloadingStatus *status = [[DownloadingStatus alloc]init];
    [_downloadStatusQueue addObject:status];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        //todo, add ui for progressing
        [NSString stringWithFormat:@"%lld / %lld", totalBytesRead, totalBytesExpectedToRead];
        
        NSString *key = [operation.userInfo objectForKey:@"key"];
        NSString *number = [_downloadKeyQueue objectForKey:key];
        
        DownloadingStatus *status = [_downloadStatusQueue objectAtIndex:[number intValue]];
        status.downloadingStatus = fileDownloadStatusDownloading;
        status.totalBytesRead = totalBytesRead;
        status.totalBytesExpectedToRead = totalBytesExpectedToRead;
        
    }];
    
    //Download complete block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         BOOL success;
         NSError *error;
         
         NSString *fileName = [NSString stringWithFormat:@"%@_%@.mp3", album.shortName, song.songNumber];
         NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:fileName];
         
         NSString *desfileName = [NSString stringWithFormat:@"/%@_%@.mp3", album.shortName, song.songNumber];
         NSString *desfilePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:desfileName];
         
         NSFileManager *fileManager = [NSFileManager defaultManager];
         success = [fileManager copyItemAtPath:filePath toPath:desfilePath error:&error];
         if (!success) {
             
             NSLog(@"failed copy %@ to %@ error = %@", fileName, desfilePath, error);
             return;

         }
         
         success = [fileManager removeItemAtPath:filePath error:nil];
         
         if (!success) {
             NSLog(@"failed to remove file at %@", filePath);
         }
         
         //Todo: Update UI
         song.filePath = [[NSURL alloc]initWithString:desfilePath];
         
         //Write back to PlayList.plist
         NSString *bundleDocumentDirectoryPath =
         [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
         
         NSString *plistPath =
         [bundleDocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_SongList.plist", album.shortName]];
         NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
         NSMutableDictionary *songArray = [dictionary objectForKey:song.songNumber];
         
         [songArray setObject:[song.filePath absoluteString] forKey:@"FilePath"];
         success = [dictionary writeToFile:plistPath atomically:NO];
         
         if (success) {
             NSLog(@"download completed");
         }
         
         NSString *key = [operation.userInfo objectForKey:@"key"];
         NSString *number = [_downloadKeyQueue objectForKey:key];
         
         DownloadingStatus *status = [_downloadStatusQueue objectAtIndex:[number intValue]];
         status.downloadingStatus = fileDownloadStatusCompleted;
     }
     //Failed
                                     failure:
     ^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString *key = [operation.userInfo objectForKey:@"key"];
         NSString *number = [_downloadKeyQueue objectForKey:key];
         
         DownloadingStatus *status = [_downloadStatusQueue objectAtIndex:[number intValue]];
         status.downloadingStatus = fileDownloadStatusError;
         
         
         /*SongCell *cell = (SongCell*)[tableView cellForRowAtIndexPath:indexPath];
          
          if (cell) {
          if (downloadPausedCount > 0) {
          cell.lbl_songStatus.text = @"下载取消";
          }
          else
          {
          cell.lbl_songStatus.text = @"下载失败";
          }
          
          cell.cirProgView_downloadProgress.hidden = YES;
          cell.bt_downloadOrPause.hidden = NO;
          
          [cell.bt_downloadOrPause setBackgroundImage:[UIImage imageNamed:@"downloadButton.png"] forState:UIControlStateNormal];
          [cell.bt_downloadOrPause removeTarget:self action:@selector(onPauseDownloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
          [cell.bt_downloadOrPause addTarget:self action:@selector(onDownloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
          }
          
          
          song.songStatus = SongStatusWaitforDownload;
          
          NSFileManager *fileManager = [NSFileManager defaultManager];
          
          NSString *path = NSTemporaryDirectory();
          NSString *fileName = [NSString stringWithFormat:@"%d.mp3", (indexPath.row + 1)];
          NSString *filePath = [path stringByAppendingString:fileName];
          
          [fileManager removeItemAtPath:filePath error:nil];
          
          [downloadQueue removeObjectForKey:[NSString stringWithFormat:@"%d", indexPath.row]];*/
         
     }];
}

@end
