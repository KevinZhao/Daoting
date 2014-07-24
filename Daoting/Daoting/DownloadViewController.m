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
    if ([AFDownloadHelper sharedOperationManager].operationQueue.operations.count > 0) {
        _tableview.hidden = NO;
        [_tableview reloadData];
        [self setupTimer];
    }
    else
    {
        _tableview.hidden = YES;
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
    // Dispose of any resources that can be recreated.
}

-(void)setupTimer
{
    _timer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
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
    DownloadCell *cell = (DownloadCell*)[_tableview cellForRowAtIndexPath:indexPath];
    
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
        
        //[self.tableview reloadData];
    
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
