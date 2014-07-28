//
//  DownloadTableViewController.m
//  Daoting
//
//  Created by Kevin on 14/6/5.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "DownloadViewController.h"

@interface DownloadViewController ()

@end

@implementation DownloadViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    _downloadQueue = [AFDownloadHelper sharedOperationManager].operationQueue;
    
    if (_downloadQueue.operations.count > 0) {
        
        _tableview.hidden = NO;
        [_tableview reloadData];
        [self setupTimer];
    }
    else
    {
        _tableview.hidden = YES;
        UILabel *lbl_noDownloadQueue = [[UILabel alloc]initWithFrame:CGRectMake(100, 200, 200, 40)];
        lbl_noDownloadQueue.text = @"当前没有下载任务";
        
        [self.view addSubview: lbl_noDownloadQueue];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_timer) {
        [_timer invalidate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)setupTimer
{
    _timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)tick
{
    NSArray *cells = [_tableview indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in cells) {
    
        [self updateCellAt:indexPath];
    }
}

-(void)updateCellAt:(NSIndexPath*) indexPath
{
    NSLog(@"%d", indexPath.row);
    
    DownloadCell *cell = (DownloadCell*)[_tableview cellForRowAtIndexPath:indexPath];
    
    if ((indexPath.row + 1) <= _downloadQueue.operations.count) {
        AFHTTPRequestOperation *operation = [AFDownloadHelper sharedOperationManager].operationQueue.operations[indexPath.row];
        
        Song *song =[operation.userInfo objectForKey:@"song"];
        Album *album = [operation.userInfo objectForKey:@"album"];
        
        DownloadingStatus *status = (DownloadingStatus *)[operation.userInfo objectForKey:@"status"];
        
        cell.lbl_downloadDescription.text = [NSString stringWithFormat:@"%@ %@", album.title, song.songNumber];
        
        switch (status.downloadingStatus) {
            case fileDownloadStatusWaiting:
            {
                cell.pv_downloadProgress.hidden = YES;
            }
                break;
            case fileDownloadStatusDownloading:
            {
                cell.pv_downloadProgress.progress = (float)status.totalBytesRead / (float)status.totalBytesExpectedToRead;
                cell.pv_downloadProgress.hidden = NO;
            }
                break;
                
            case fileDownloadStatusCompleted:
            {
                cell.btn_cancel.titleLabel.text = @"已完成";
                cell.pv_downloadProgress.hidden = YES;
                
            }
                break;
                
            case fileDownloadStatusError:
            {
                cell.pv_downloadProgress.hidden = YES;
                cell.btn_cancel.titleLabel.text = @"已取消";
            }
                
            default:
                break;
        }
    }
    else
    {
        [_tableview reloadData];
    }
}

- (IBAction)cancelAll:(id)sender
{
    NSLog(@"count = %d", [AFDownloadHelper sharedOperationManager].operationQueue.operations.count);

        @try {
            for (AFHTTPRequestOperation *operation in [AFDownloadHelper sharedOperationManager].operationQueue.operations) {
            [operation cancel];
            }
        }
        @catch (NSException *exception) {
            if ([[exception name] isEqual:NSRangeException])
            {
                NSLog(@"NSRangeException");
            }
        }
        @finally {
            
        }
}

#pragma mark UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AFDownloadHelper sharedOperationManager].operationQueue.operations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadCell *cell = [_tableview dequeueReusableCellWithIdentifier:@"DownloadCell"];

    return cell;
}


@end
