//
//  Song.h
//  Daoting
//
//  Created by Kevin on 14-5-16.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Song : NSObject <NSCoding>

enum
{
    DownloadStatusNotDownload   = 0,
    DownloadStatusWaiting       = 1,
    DownloadStatusDownloading   = 2,
    DownloadStatusCompleted     = 3,
    DownloadStatusError         = 4
};
typedef NSInteger DownloadStatus;

@property (nonatomic, strong) NSString  *songNumber;
@property (nonatomic, strong) NSString  *title;
@property (nonatomic, strong) NSString  *duration;
@property (nonatomic, strong) NSURL     *Url;
@property (nonatomic, strong) NSURL     *filePath;
@property (nonatomic, strong) NSString  *price;
@property (nonatomic, assign) double    progress;
@property (nonatomic, strong) NSString  *updatedSong;
@property (nonatomic, strong) NSString  *description;
@property (nonatomic, assign) DownloadStatus downloadingStatus;

@end
