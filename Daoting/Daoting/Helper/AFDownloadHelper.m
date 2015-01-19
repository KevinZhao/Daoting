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
    
    //1. Create Request and operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:[[NSURLRequest alloc]initWithURL:song.Url]];
    
    //2. Configure Download Status
    DownloadingStatus *status = [[DownloadingStatus alloc]init];
    status.downloadingStatus = fileDownloadStatusWaiting;
    
    //todo: next version revisit, too much information here
    operation.userInfo = [[NSMutableDictionary alloc]init];
    [operation.userInfo setValue:[NSString stringWithFormat:@"%@_%@", album.shortName, song.songNumber] forKey:@"key"];
    [operation.userInfo setValue:album forKeyPath:@"album"];
    [operation.userInfo setValue:song forKeyPath:@"song"];
    [operation.userInfo setValue:status forKeyPath:@"status"];
    
    //2.1 check album directory had been created
    [self checkDirectoryforOperation:operation];
    //2.2 Create ralative path for file destination URL and save to userInfo
    NSURL *relativeDesitinationFileUrl = [self createDestinationFileURL:operation];
    [operation.userInfo setValue:relativeDesitinationFileUrl forKey:@"filePath"];
    
    //3. Create destination File URL for output stream
    NSURL *destinationFileURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:[relativeDesitinationFileUrl absoluteString]];
    operation.outputStream = [NSOutputStream outputStreamWithURL:destinationFileURL append:NO];
    
    //4. Add to operation queue
    [[AFDownloadHelper sharedOperationManager].operationQueue addOperation:operation];
    
    //5. Copy operation as reference
    AFHTTPRequestOperation __weak *operation_ = operation;
    
    //6. Notify delegate if any
    if (self.delegate) {
        [self.delegate onDownloadStartedForOperation:operation_];
    }
    
    //Download Progress block
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        //1. Modify download status
        DownloadingStatus *status = [operation_.userInfo objectForKey:@"status"];
        status.downloadingStatus = fileDownloadStatusDownloading;
        status.totalBytesRead = totalBytesRead;
        status.totalBytesExpectedToRead = totalBytesExpectedToRead;
        
        //2. Notify delegate if any
        if (self.delegate) {
            [self.delegate onDownloadProgressedForOperation:operation_];
        }
    }];
    
    //Download complete block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //1. Save file path to songlist
         song.filePath = [operation.userInfo objectForKey:@"filePath"];
         [[CategoryManager sharedManager] writeBacktoSongListinAlbum:album];
         
         //2. Modify download status
         DownloadingStatus *status = [operation.userInfo objectForKey:@"status"];
         status.downloadingStatus = fileDownloadStatusCompleted;
         
         //3. Notify delegate if any
         if (self.delegate) {
             [self.delegate onDownloadProgressedForOperation:operation_];
         }
     }
     
     //Download failed block
    failure:
     ^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //1. Modify download status
         DownloadingStatus *status = [operation.userInfo valueForKey:@"status"];
         status.downloadingStatus = fileDownloadStatusError;
         
         //2. Notify delegate if any
         if (self.delegate) {
             [self.delegate onDownloadFailedForOperation:operation_];
         }
     }];
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationLibraryDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

-(BOOL) checkDirectoryforOperation:(AFHTTPRequestOperation*) operation
{
    BOOL isDir = NO;
    BOOL isExisted = NO;
    NSError *err;
    BOOL result = NO;

    //1. Get information from operation
    Album* album = [operation.userInfo valueForKey:@"album"];
    
    //2. Check if album directory exist, if not create one
    NSURL *libraryDirectory = [self applicationLibraryDirectory];
    NSURL *albumDirectory = [libraryDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"Daoting/%@", album.shortName]];
    isExisted = [[NSFileManager defaultManager] fileExistsAtPath:[albumDirectory absoluteString] isDirectory:&isDir];
    
    if (!isExisted) {
        if (!isDir) {
            result = [[NSFileManager defaultManager] createDirectoryAtURL:albumDirectory withIntermediateDirectories:YES attributes:nil error:&err];
            
            return result;
        }
    }
    
    return result;
}

-(NSURL*) createDestinationFileURL:(AFHTTPRequestOperation*) operation
{
    //1. Get information from operation
    Song* song = [operation.userInfo valueForKey:@"song"];
    Album* album = [operation.userInfo valueForKey:@"album"];
    
    //2. Build destinationFileURL
    NSURL *destinationUrl = [NSURL URLWithString:[NSString stringWithFormat:@"Daoting/%@", album.shortName]];
    destinationUrl = [destinationUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@", album.shortName, song.songNumber]];
    destinationUrl = [destinationUrl URLByAppendingPathExtension:@"mp3"];
    
    return destinationUrl;
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
