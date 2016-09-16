//
//  DownloadStatus.h
//  Daoting
//
//  Created by Kevin on 14/6/9.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    fileDownloadStatusWaiting       = 1,
	fileDownloadStatusDownloading   = 2,
    fileDownloadStatusCompleted     = 3,
    fileDownloadStatusError         = 4
};
typedef NSInteger FileDownloadStatus;

@interface DownloadingStatus : NSObject
{
    
}

@property (nonatomic, assign) FileDownloadStatus downloadingStatus;
@property (nonatomic, assign) long long totalBytesRead;
@property (nonatomic, assign) long long totalBytesExpectedToRead;

@end