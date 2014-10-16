//
//  AFNetWorkingOperationManagerHelper.m
//  Daoting
//
//  Created by Kevin on 14-5-27.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "AFDownloadHelper.h"
#import "AppData.h"

@implementation AFDownloadHelper

+ (AFHTTPRequestOperationManager *)sharedOperationManager {
    static dispatch_once_t once;
    static AFHTTPRequestOperationManager * sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [AFHTTPRequestOperationManager manager];
        
    });
    return sharedInstance;
}

+ (AFDownloadHelper *)sharedAFDownloadHelper
{
    static dispatch_once_t once;
    static AFDownloadHelper * sharedAFDownloadHelper;
    dispatch_once(&once, ^{
        sharedAFDownloadHelper = [[AFDownloadHelper alloc]init];
        
    });
    return sharedAFDownloadHelper;
}

- (void)downloadSong:(Song*) song inAlbum:(Album*) album
{    
    //0. check if the song is already in download queue
    NSString *key = [NSString stringWithFormat:@"%@_%@", album.shortName, song.songNumber];
    if ([self searchOperationbyKey:key] != nil) {
        return;
    }
    
    //1. Set download path to temporary directory with album shortname and songnumber combination
    NSString *fileName = [NSString stringWithFormat:@"%@.mp3", key];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:fileName];
    
    //2. Create Request and operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:[[NSURLRequest alloc]initWithURL:song.Url]];
    
    //2.1 Configure operation
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [[AFDownloadHelper sharedOperationManager].operationQueue addOperation:operation];
    
    DownloadingStatus *status = [[DownloadingStatus alloc]init];
    status.downloadingStatus = fileDownloadStatusWaiting;
    
    //next version revisit, too much information here
    operation.userInfo = [[NSMutableDictionary alloc]init];
    [operation.userInfo setValue:[NSString stringWithFormat:@"%@_%@", album.shortName, song.songNumber] forKey:@"key"];
    [operation.userInfo setValue:album forKeyPath:@"album"];
    [operation.userInfo setValue:song forKeyPath:@"song"];
    [operation.userInfo setValue:status forKeyPath:@"status"];
    
    //Revisit in Next Version
    //better not use this
    AFHTTPRequestOperation __weak *operation_ = operation;
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
    
        DownloadingStatus *status = [operation_.userInfo objectForKey:@"status"];
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
         NSString *albumFolder = [NSString stringWithFormat:@"/Daoting/%@", album.shortName];
         [self checkDirectory:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:albumFolder]];
         NSString *desfilePath = [[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:albumFolder]stringByAppendingString:desfileName];
         
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
         
         song.filePath = [[NSURL alloc]initWithString:desfilePath];
         
         [[CategoryManager sharedManager] writeBacktoSongListinAlbum:album];
         if (success) {
             NSLog(@"download completed");
         }
         
         DownloadingStatus *status = [operation.userInfo objectForKey:@"status"];
         status.downloadingStatus = fileDownloadStatusCompleted;
     }
     //Failed
    failure:
     ^(AFHTTPRequestOperation *operation, NSError *error)
     {
         DownloadingStatus *status = [operation.userInfo valueForKey:@"status"];
         status.downloadingStatus = fileDownloadStatusError;
     }];
}

-(void) checkDirectory:(NSString*) directoryPath
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

-(AFHTTPRequestOperation *)searchOperationbyKey:(NSString *)key
{
    AFHTTPRequestOperation *operation = nil;
    
    for (AFHTTPRequestOperation *op in [AFDownloadHelper sharedOperationManager].operationQueue.operations) {
        
        if ([key isEqual:[op.userInfo valueForKey:@"key"]]) {
            
            operation = op;
            break;
        }
        
    }
    return operation;
}
@end
