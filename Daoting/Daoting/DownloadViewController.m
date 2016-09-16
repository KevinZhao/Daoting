//
//  DownloadTableViewController.m
//  Daoting
//
//  Created by Kevin on 14/6/5.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "DownloadViewController.h"

@implementation DownloadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    //1. configure label for no download
    CGSize lblSize = CGSizeMake(200, 40);
    CGSize screenSize = [UIScreen mainScreen].applicationFrame.size;
    
    _lbl_noDownloadQueue = [[UILabel alloc]initWithFrame:
                            CGRectMake((screenSize.width-lblSize.width)/2 , screenSize.height/3, lblSize.width, lblSize.height)];
    
    _lbl_noDownloadQueue.textAlignment = NSTextAlignmentCenter;
    _lbl_noDownloadQueue.text = @"当前没有下载任务";
    
    [self.view addSubview: _lbl_noDownloadQueue];
    [self.view insertSubview:_lbl_noDownloadQueue atIndex:1];
    
    //2. background view
    _img_background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    _img_background.backgroundColor = _appDelegate.defaultBackgroundColor;
    
    self.view.backgroundColor = _appDelegate.defaultBackgroundColor;
    [self.view insertSubview:_img_background atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _downloadQueue = [AFDownloadHelper sharedOperationManager].operationQueue;
    
    if (_downloadQueue.operations.count > 0) {
        
        self.tableView.separatorColor = [UIColor grayColor];
        _img_background.hidden = YES;
        [self.tableView reloadData];
        [self setupTimer];
        
        _lbl_noDownloadQueue.hidden = YES;
    }
    else
    {
        _img_background.hidden = NO;
        self.tableView.separatorColor = [UIColor clearColor];
        _lbl_noDownloadQueue.hidden = NO;
        [_timer invalidate];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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
    _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)tick
{
    NSArray *cells = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in cells) {
    
        [self updateCellAt:indexPath];
    }
    
    //there is some download task
    if (_downloadQueue.operations.count > 0) {
        
        self.tableView.separatorColor = [UIColor grayColor];
        _img_background.hidden = YES;
        _lbl_noDownloadQueue.hidden = YES;
    }
    //there is no download task
    else
    {
        _img_background.hidden = NO;
        _lbl_noDownloadQueue.hidden = NO;
        self.tableView.separatorColor = [UIColor clearColor];
        [_timer invalidate];
    }
}

-(void)updateCellAt:(NSIndexPath*)indexPath
{
    DownloadCell *cell = (DownloadCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
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
        [self.tableView reloadData];
    }
}

- (IBAction)cancelAll:(id)sender
{
    @try
    {
        for (AFHTTPRequestOperation *operation in [AFDownloadHelper sharedOperationManager].operationQueue.operations)
        {
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
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    _lbl_noDownloadQueue.hidden = NO;
}

#pragma mark UItableView Delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AFDownloadHelper sharedOperationManager].operationQueue.operations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadCell"];
    
    //1. Set album image
    if ((indexPath.row + 1) <= _downloadQueue.operations.count){
        
        AFHTTPRequestOperation *operation = [AFDownloadHelper sharedOperationManager].operationQueue.operations[indexPath.row];
        Album *album = [operation.userInfo objectForKey:@"album"];
    
        NSURLRequest *request = [NSURLRequest requestWithURL:album.imageUrl];
        UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
    
        __weak DownloadCell *weakCell = cell;
    
        [cell.img_album setImageWithURLRequest:request
                               placeholderImage:placeholderImage
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             [weakCell.img_album setImage:image];
             [weakCell setNeedsLayout];
         
         } failure:nil];
    
        //2. Configure Color
        cell.btn_cancel.tintColor = _appDelegate.defaultColor_dark;
        cell.pv_downloadProgress.tintColor = _appDelegate.defaultColor_light;
    }
    else
    {
        [tableView reloadData];
    }
    
    return cell;
}


@end
