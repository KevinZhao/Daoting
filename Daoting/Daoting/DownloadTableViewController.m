//
//  DownloadTableViewController.m
//  Daoting
//
//  Created by Kevin on 14/6/5.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "DownloadTableViewController.h"

@interface DownloadTableViewController ()

@end

@implementation DownloadTableViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [_tableview reloadData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated
{
}


- (void)viewWillAppear:(BOOL)animated
{
    [_tableview reloadData];
    [self setupTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_timer invalidate];
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
    
    NSMutableArray *downloadQueue = [AFNetWorkingOperationManagerHelper sharedManagerHelper].downloadQueue;
    AFHTTPRequestOperation *operation =downloadQueue[indexPath.row];
    
    NSString *key = [operation.userInfo objectForKey:@"key"];
    Song *song =[operation.userInfo objectForKey:@"song"];
    Album *album = [operation.userInfo objectForKey:@"album"];
    
    DownloadingStatus *status = [[AFNetWorkingOperationManagerHelper sharedManagerHelper] searchStatusByKey:key];
    
    switch (status.downloadingStatus) {
        case fileDownloadStatusWaiting:
        {
            cell.lbl_downloadDescription.text = [NSString stringWithFormat:@"%@ %@", album.title, song.songNumber];
            
            cell.pv_downloadProgress.hidden = YES;
        }
            break;
        case fileDownloadStatusDownloading:
        {
            cell.lbl_downloadDescription.text = [NSString stringWithFormat:@"%@ %@", album.title, song.songNumber];
            
            cell.pv_downloadProgress.progress = (float)status.totalBytesRead / (float)status.totalBytesExpectedToRead;
            
            cell.pv_downloadProgress.hidden = NO;
        }
            break;

        case fileDownloadStatusCompleted:
        {
            cell.pv_downloadProgress.hidden = YES;
    
        }
            break;
    
        case fileDownloadStatusError:
        {
            cell.pv_downloadProgress.hidden = YES;
        }
            
        default:
            break;
        }
    
}

- (IBAction)cancelAll:(id)sender
{
    NSMutableArray *downloadQueue = [AFNetWorkingOperationManagerHelper sharedManagerHelper].downloadQueue;
    
    for (AFHTTPRequestOperation *operation in downloadQueue) {
        [operation cancel];
    }
    
    //update UI
    
    for (int i = 0; i < [AFNetWorkingOperationManagerHelper sharedManagerHelper].downloadQueue.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        DownloadCell *cell = (DownloadCell*)[_tableview cellForRowAtIndexPath:indexPath];
        
        cell.btn_cancel.titleLabel.text = @"已取消";
    }
}

#pragma mark UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AFNetWorkingOperationManagerHelper sharedManagerHelper].downloadQueue.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadCell *cell = [_tableview dequeueReusableCellWithIdentifier:@"DownloadCell"];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
