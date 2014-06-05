//
//  SongCell.m
//  Daoting
//
//  Created by Kevin on 14-5-16.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "SongCell.h"

@implementation SongCell

@synthesize song, album;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        

    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onbtn_downloadPressed:(id)sender
{
    [self downloadFile:self.song.Url];
}

- (void)downloadFile:(NSURL* )url
{
    //1. Set download path to temporary directory with album shortname and songnumber combination
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.mp3", self.album.shortName, self.song.songNumber];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:fileName];

    //2. Create Request and operation
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:[[NSURLRequest alloc]initWithURL:url]];
    
    //2.1 Configure operation and add it to operation queue
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [[AFNetWorkingOperationManagerHelper sharedInstance].operationQueue addOperation:operation];
    
    NSMutableDictionary *downloadQueue = [AFNetWorkingOperationManagerHelper sharedManagerHelper].downloadQueue;
    
    [downloadQueue setObject:operation forKey:[NSString stringWithFormat:@"%@_%@", self.album.shortName, self.song.songNumber]];
    
    //Download complete block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {

         BOOL success;
         NSError *error;

         NSString *fileName = [NSString stringWithFormat:@"%@_%@.mp3", self.album.shortName, self.song.songNumber];
         NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:fileName];
         
         NSString *desfileName = [NSString stringWithFormat:@"/%@_%@.mp3", self.album.shortName, self.song.songNumber];
         NSString *desfilePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:desfileName];
         
         NSFileManager *fileManager = [NSFileManager defaultManager];
         success = [fileManager copyItemAtPath:filePath toPath:desfilePath error:&error];
         if (!success) {
             NSLog(@"failed copy %@ to %@ error = %@", fileName, desfilePath, error);
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
         [bundleDocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_SongList.plist", self.album.shortName]];
         NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
         NSMutableDictionary *songArray = [dictionary objectForKey:self.song.songNumber];
         
         [songArray setObject:[self.song.filePath absoluteString] forKey:@"FilePath"];
         success = [dictionary writeToFile:plistPath atomically:NO];
         
         if (success) {
            NSLog(@"download completed");
         }
     }
     //Failed
    failure:
     ^(AFHTTPRequestOperation *operation, NSError *error)
     {
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
    //Progress updating
    
    /*[operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        NSString *percentage = [NSString stringWithFormat:@"%lld/%lld", totalBytesRead, totalBytesExpectedToRead];
        NSLog(@"%@", percentage);
        
    }];*/
    
    
    
}

@end
