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
    NSString *PositioninQueue =  [[AFNetWorkingOperationManagerHelper sharedManagerHelper].downloadKeyQueue objectForKey:key];
    
    //1. Check if the operation in download queue
    if (PositioninQueue != nil) {
        
        DownloadingStatus *status = [[AFNetWorkingOperationManagerHelper sharedManagerHelper].downloadStatusQueue objectAtIndex:[PositioninQueue intValue]];
        
        switch (status.downloadingStatus) {
            case fileDownloadStatusWaiting:
            {
                
            }
                break;
            case fileDownloadStatusDownloading:
            {
                cell.lbl_downloadDescription.text =
                [NSString stringWithFormat:@"%lld / %lld", status.totalBytesRead, status.totalBytesExpectedToRead];
            }
                break;
                
            case fileDownloadStatusCompleted:
            {
                
            }
                break;
                
            case fileDownloadStatusError:
            {
                
            }
                
            default:
                break;
        }}
}


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
