//
//  SongTableViewController.m
//  Daoting
//
//  Created by Kevin on 14-5-12.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "SongTableViewController.h"

@interface SongTableViewController ()
@end

@implementation SongTableViewController
@synthesize pageControl, scrollView;

#pragma mark - UIView delegate

- (void)viewDidLoad
{
    _playerHelper   = [STKAudioPlayerHelper sharedInstance];
    _audioPlayer    = _playerHelper.audioPlayer;
    _appData        = [AppData sharedAppData];
    _playerHelper.delegate = self;
    
    [super viewDidLoad];
    
    [self loadSongs];
    
    [self updateSongs];
    
    [self setupTimer];
    
    [self setupNotificationView];
    
    _actionSheetStrings = [[NSMutableDictionary alloc] init];
    [_actionSheetStrings setObject:@"取消" forKey:@"cancel"];
    [_actionSheetStrings setObject:@"分享" forKey:@"share"];
    [_actionSheetStrings setObject:@"全部下载" forKey:@"downloadOrCancelAll"];
}


- (void)viewWillAppear:(BOOL)animated
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    scrollView.contentSize = CGSizeMake(640, 406);
    scrollView.delegate = self;
    
    //Configure tableview
    _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 406) style:UITableViewStylePlain];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.rowHeight = 60;
    
    //Load from xib for prototype cell
    [_tableview registerNib:[UINib nibWithNibName:@"SongCell" bundle:nil]forCellReuseIdentifier:@"SongCell"];

    [scrollView addSubview:_tableview];
    
    //Todo: Change to another UIView to give description of album
    UIImageView *test = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wangyuebo.jpg"]];
    test.frame = CGRectMake(320, 0, 320, 406);
    [scrollView addSubview:test];
    
    //Configure pagecontrol
    pageControl.currentPage = 0;
    pageControl.numberOfPages = 2;
    
    NSString* songNumberstring = (NSString*)[_appData.playingPositionQueue objectForKey:_album.title];
    NSInteger songNumber = [songNumberstring integerValue];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(songNumber-1) inSection:0];
    
    [_tableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_timer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Internal business logic

- (void)setupNotificationView
{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"NotificationView_iphone" owner:self options:nil];
    
    _notificationView = [nibViews objectAtIndex:0];
    _notificationView.center = self.view.center;
    [self.view addSubview:_notificationView];
    
    [_notificationView.layer setMasksToBounds:YES];
    [_notificationView.layer setCornerRadius:10.0];
    [_notificationView.layer setBorderWidth:5.0];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 0, 0, 1, 0.2 });
    [_notificationView.layer setBorderColor:colorref];//边框颜色
    
    _notificationView.alpha = 0.0;
}

- (void)initializeSongs
{
    _songs = [[NSMutableArray alloc]init];
    
    NSString *DocumentDirectoryPath =
        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *plistPath =
        [DocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_SongList.plist", _album.shortName]];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    for (int i = 1; i<= dictionary.count; i++)
    {
        NSDictionary *SongDic = [dictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        
        Song *song = [[Song alloc]init];
        
        song.songNumber = [NSString stringWithFormat:@"%d", i];
        song.title      = [SongDic objectForKey:@"Title"];
        song.duration   = [SongDic objectForKey:@"Duration"];
        song.Url        = [[NSURL alloc] initWithString:[SongDic objectForKey:@"Url"]];
        song.filePath   = [[NSURL alloc] initWithString:[SongDic objectForKey:@"FilePath"]];
        song.price      = [SongDic objectForKey:@"Price"];
        
        [_songs addObject:song];
    }
}

- (void)updateSongs
{
    //1. Check if plist is in document directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:@"/"];
    plistPath = [plistPath stringByAppendingString:_album.shortName];
    plistPath = [plistPath stringByAppendingString:@"_SongList.plist"];
    
    //2. Download plist from cloud storage
    NSURLRequest *request = [NSURLRequest requestWithURL:_album.plistUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    NSString *path = NSTemporaryDirectory();
    NSString *fileName = @"PlayList.plist";
    NSString *filePath = [path stringByAppendingString:fileName];
    
    [fileManager removeItemAtPath:filePath error:nil];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    [[AFDownloadHelper sharedOperationManager].operationQueue addOperation:operation];
    
    //Download complete block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //Compare
         NSMutableDictionary *newPlist_dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
         NSMutableDictionary *oldPlist_dictionary = [[NSMutableDictionary alloc] init];
         
         if ([fileManager fileExistsAtPath:plistPath])
         {
             oldPlist_dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
         }
         
         //there is new song in the plist
         if (newPlist_dictionary.count > oldPlist_dictionary.count)
         {
             int oldCount = (int)oldPlist_dictionary.count;
             int j = (int)(newPlist_dictionary.count - oldPlist_dictionary.count);
             
             //Copy items in new Plist to old Plist
             for (int i = 1; i<= j; i++)
             {
                 NSDictionary *newSong = [newPlist_dictionary objectForKey:[NSString stringWithFormat:@"%d",oldCount + i]];
                 
                 [oldPlist_dictionary setValue:newSong forKey:[NSString stringWithFormat:@"%d", (oldCount + i)]];
             }
             [oldPlist_dictionary writeToFile:plistPath atomically:NO];
             
             //re-initialize songs and update table view
             [self initializeSongs];
             
             [_tableview reloadData];
         }
         //there is no new song in the plist
         else
         {
             //do nothing
         }
         
     }
     //Download Failed
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //todo for next version: try to redownload from cloud for 3 times
     }];
}

- (void)loadSongs
{
    //1. Check if there is a playlist in document directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPathinDocumentDirectory = [bundleDocumentDirectoryPath stringByAppendingString:@"/"];
    plistPathinDocumentDirectory = [plistPathinDocumentDirectory stringByAppendingString:_album.shortName];
    plistPathinDocumentDirectory = [plistPathinDocumentDirectory stringByAppendingString:@"_SongList.plist"];
    
    //if yes, load from document directory, if no copy from resource directory to document directory
    if ([fileManager fileExistsAtPath:plistPathinDocumentDirectory])
    {
        [self initializeSongs];
    }
    else
    {
        NSString *plistPathinResourceDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"];
        plistPathinResourceDirectory = [plistPathinResourceDirectory stringByAppendingString:_album.shortName];
        plistPathinResourceDirectory = [plistPathinResourceDirectory stringByAppendingString:@"_SongList.plist"];
        
        if ([fileManager fileExistsAtPath:plistPathinResourceDirectory]) {
            [fileManager copyItemAtPath:plistPathinResourceDirectory toPath:plistPathinDocumentDirectory error:nil];
            
            [self initializeSongs];
        }
    }
    
    [_tableview reloadData];
}

-(void)playNextSong
{
    //play next song
    NSInteger currentSongNumber = [_appData.currentSong.songNumber integerValue];
    
    if ( currentSongNumber < _playerHelper.playbackList.count) {
        
        Song *song = [_playerHelper.playbackList objectAtIndex:(currentSongNumber)];
        
        [self playSong:song];
    }
}

-(void)playPreviousSong
{
    NSInteger currentSongNumber = [_appData.currentSong.songNumber integerValue];
    
    if ( currentSongNumber - 1 > 0) {
        
        Song *song = [_playerHelper.playbackList objectAtIndex:(currentSongNumber - 2)];
        
        [self playSong:song];
    }
}

-(void)playSong:(Song*)song
{
    //2.1 check the song had been purchased or not
    BOOL purchased = [_appData songNumber:song.songNumber ispurchasedwithAlbum:_album.shortName];
    
    //if the song had been purchased
    if (purchased) {
        
        //play the song
        [self playSongbyHelper:song];
        
    }
    //2.2 the song had not been purchased yet
    else{
        
        //2.2.1 if coin is enough, buy it.
        if (_appData.coins >= [song.price intValue]) {
            
            _appData.coins = _appData.coins - [song.price intValue];
            
            [self playSongbyHelper:song];
            
            //Add to purchased queue
            [_appData addtoPurchasedQueue:song withAlbumShortname:_album.shortName];
            
            [_appData save];
            
            NSString *notification = [NSString stringWithFormat:@"金币  -%@", song.price];
            [self showNotification:notification];
        }
        else
        //2.2.2 cois is not enough
        {
            //todo notify user and show store view
            UITabBarController *tabBarController = [self getTabbarViewController];
            tabBarController.selectedIndex = 2;
        }
    }
}

- (void) playSongbyHelper:(Song*)song
{
    [_playerHelper playSong:song InAlbum:_album];
    
    _playerHelper.playbackList = _songs;
    [_appData.playingPositionQueue setObject:song.songNumber forKey:_album.title];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[song.songNumber intValue] - 1 inSection:0];
    [_tableview beginUpdates];
    [_tableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [_tableview endUpdates];
    
    [self configureNowPlayingInfo];
}


- (void)setDetailItem:(Album *)album
{
    _album = album;
}

-(void)setupTimer
{
	_timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(tick) userInfo:nil repeats:YES];
	
	[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)tick
{
    //There is a song playing
    if (_audioPlayer.duration != 0)
    {
        _lbl_progressCurrentValue.text = [NSString stringWithFormat:@"%@", [self formatTimeFromSeconds:_audioPlayer.progress]];
        _lbl_progressMaxValue.text = [NSString stringWithFormat:@"%@", [self formatTimeFromSeconds:_audioPlayer.duration]];
        
        _slider.enabled = YES;
        _slider.minimumValue = 0;
        _slider.maximumValue = _audioPlayer.duration;
        _slider.value = _audioPlayer.progress;
    }
    //There is no song playing
    else
    {
        _lbl_progressMaxValue.text = @"";
        _lbl_progressCurrentValue.text = @"";
        
        _slider.enabled = NO;
        _slider.value = 0;
        _slider.minimumValue = 0;
        _slider.maximumValue = 0;
    }
    
    switch (_audioPlayer.state) {
        case STKAudioPlayerStatePlaying:
            [_btn_playAndPause setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_n.png"] forState:UIControlStateNormal];
            [_btn_playAndPause setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_h.png"] forState:UIControlStateHighlighted];
            break;
        case STKAudioPlayerStatePaused:
            [_btn_playAndPause setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_n.png"] forState:UIControlStateNormal];
            [_btn_playAndPause setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_h.png"] forState:UIControlStateHighlighted];
            break;
        default:
            break;
    }
    
    //Update visible cell
    NSArray *visibleCell = [_tableview indexPathsForVisibleRows];
    for (int i = 0; i < visibleCell.count; i++) {
        
        [self updateCellAt:[visibleCell objectAtIndex:i]];
    }
    
}

- (void)updateCellAt:(NSIndexPath *)indexPath
{
    SongCell* songCell = (SongCell*)[_tableview cellForRowAtIndexPath:indexPath];
    Song *song = [_songs objectAtIndex:indexPath.row];
    NSString *key = [NSString stringWithFormat:@"%@_%@", _album.shortName, song.songNumber];
    AFHTTPRequestOperation *operation = [[AFDownloadHelper sharedAFDownloadHelper] searchOperationbyKey:key];

    //1. Check if the operation in download queue
    if (operation != nil) {
    
        DownloadingStatus *status = [operation.userInfo valueForKey:@"status"];
        
        switch (status.downloadingStatus) {
                
            //Waiting for download
            case fileDownloadStatusWaiting:
            {
                songCell.btn_downloadOrPause.hidden = NO;
                [songCell.btn_downloadOrPause removeTarget:songCell action:@selector(onbtn_downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
                [songCell.btn_downloadOrPause addTarget:songCell action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [songCell.btn_downloadOrPause setBackgroundImage:[UIImage imageNamed:@"downloadProgressButtonPause.png"] forState:UIControlStateNormal];
            }
                break;
            //Downloading
            case fileDownloadStatusDownloading:
            {
                //1.
                songCell.cirProgView_downloadProgress.hidden = NO;
                songCell.cirProgView_downloadProgress.progressTintColor = [UIColor blueColor];
                
                if (status.totalBytesExpectedToRead != 0) {
                    
                    songCell.cirProgView_downloadProgress.progress =(float) status.totalBytesRead / (float)status.totalBytesExpectedToRead;
                }
                
                //2.
                songCell.btn_downloadOrPause.hidden = NO;
                [songCell.btn_downloadOrPause removeTarget:songCell action:@selector(onbtn_downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
                [songCell.btn_downloadOrPause addTarget:songCell action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [songCell.btn_downloadOrPause setBackgroundImage:[UIImage imageNamed:@"downloadProgressButtonPause.png"] forState:UIControlStateNormal];

            }
                break;
            //Download Completed
            case fileDownloadStatusCompleted:
            {
                songCell.cirProgView_downloadProgress.hidden = YES;
                
                songCell.btn_downloadOrPause.hidden = NO;
                songCell.btn_downloadOrPause.enabled = false;
                [songCell.btn_downloadOrPause setBackgroundImage:[UIImage imageNamed:@"songDownloaded.png"] forState:UIControlStateNormal];
            }
                break;
            //Download Failed
            case fileDownloadStatusError:
            {
                songCell.btn_downloadOrPause.hidden = NO;
                [songCell.btn_downloadOrPause removeTarget:songCell action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
                [songCell.btn_downloadOrPause addTarget:songCell action:@selector(onbtn_downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
                [songCell.btn_downloadOrPause setBackgroundImage:[UIImage imageNamed:@"downloadButton.png"] forState:UIControlStateNormal];

                songCell.cirProgView_downloadProgress.hidden = YES;
            }
            
            default:
                break;
        }
    }
    else{
    
        //2. Check if the file had been downloaded for the cell
        //Download completed
        if ([[NSFileManager defaultManager] fileExistsAtPath:[song.filePath absoluteString]]){

            songCell.cirProgView_downloadProgress.hidden = YES;

            songCell.btn_downloadOrPause.hidden = NO;
            songCell.btn_downloadOrPause.enabled = false;
            [songCell.btn_downloadOrPause setBackgroundImage:[UIImage imageNamed:@"songDownloaded.png"] forState:UIControlStateNormal];

        }
        //Not Downloaded yet
        else{
            songCell.cirProgView_downloadProgress.hidden = YES;
            
            songCell.btn_downloadOrPause.hidden = NO;
            [songCell.btn_downloadOrPause removeTarget:songCell action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
            [songCell.btn_downloadOrPause addTarget:songCell action:@selector(onbtn_downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
            [songCell.btn_downloadOrPause setBackgroundImage:[UIImage imageNamed:@"downloadButton.png"] forState:UIControlStateNormal];
        }
    }
}

-(NSString*)formatTimeFromSeconds:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

-(void)updateUI
{
    [self tick];
}

- (void) configureNowPlayingInfo
{
    Album *album = _appData.currentAlbum;
    Song *song= _appData.currentSong;
    
    //Set Information for Nowplaying Info Center
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:song.title forKey:MPMediaItemPropertyAlbumTitle];
        [dict setObject:album.artistName forKey:MPMediaItemPropertyArtist];
        [dict setObject:[NSNumber numberWithInteger:_audioPlayer.duration] forKey:MPMediaItemPropertyPlaybackDuration];
        [dict setObject:[NSNumber numberWithInteger:_audioPlayer.progress] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        [dict setObject:[NSNumber numberWithInteger:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        [dict setObject:[NSNumber numberWithInteger:2] forKey:MPMediaItemPropertyAlbumTrackCount];
        
        //todo need to remove hard code
        UIImage *img = [UIImage imageNamed: @"wangyuebo.jpg"];
        MPMediaItemArtwork * mArt = [[MPMediaItemArtwork alloc] initWithImage:img];
        [dict setObject:mArt forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    STKAudioPlayer *player = _playerHelper.audioPlayer;
    
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                if (player.state == STKAudioPlayerStatePlaying) {
                    
                    //Pause
                    [_playerHelper pauseSong];
                    
                }else{
                    
                    //Resume
                    [self playSong:_appData.currentSong];
                }
                break;
            }
            case UIEventSubtypeRemoteControlPause:
            {
                [_playerHelper pauseSong];
                
                break;
            }
                
            case UIEventSubtypeRemoteControlPlay:
            {
                [self playSong:_appData.currentSong];
                break;
            }
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                [self playPreviousSong];
                break;
            }
            case UIEventSubtypeRemoteControlNextTrack:
            {
                [self playNextSong];
                break;
            }
            default:
                break;
        }
    }
}

- (void)shareAlbum
{
    id<ISSContent> publishContent = [ShareSDK content:@"我正在听王玥波的评书《聊斋》，收集整理的好全，严重推荐! http://t.cn/RvTAdqk"
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:[_album.imageUrl absoluteString]]
                                                title:@"我正在听王玥波的评书《聊斋》，收集整理的好全，严重推荐！http://t.cn/RvTAdqk"
                                                  url:@"http://t.cn/RvTAdqk"
                                          description:@""
                                            mediaType:SSPublishContentMediaTypeNews];
    
    
    [ShareSDK showShareViewWithType:ShareTypeWeixiTimeline container:nil content:publishContent statusBarTips:NO authOptions:nil shareOptions:nil result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
        
        if (state == SSResponseStateSuccess)
        {
            //share
            _appData.coins = _appData.coins + 50;
            NSString *notification = @"+ 50";
            [self showNotification:notification];
        }
        else if (state == SSResponseStateFail)
        {
            NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
        }
    }];
}

- (UITabBarController *)getTabbarViewController
{
    Class vcc = [UITabBarController class];
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: vcc])
            return (UITabBarController *)responder;
    return nil;
}

- (void)downloadAll
{
    //1.calculate how many coins need for download all items
    
    int coinsNeeded = 0;
    for (int i = 0; i < _songs.count; i++) {
        
        Song *song = _songs[i];
        
        //NSString *key = [NSString stringWithFormat:@"%@_%@", _album.shortName, song.songNumber];
        
        //1.1 check the song had been purchased or not
        BOOL purchased = [_appData songNumber:song.songNumber ispurchasedwithAlbum:_album.shortName];
        if (!purchased) {
            coinsNeeded = coinsNeeded + [song.price intValue];
        }
    }
    
    NSLog(@"coinsNeeded = %d", coinsNeeded);
    
    //2.if coin is enough, add all download item into download queue
    if (_appData.coins >= coinsNeeded) {
        for (int i = 0; i < _songs.count; i++) {
            
            Song *song = _songs[i];
            
            //2.1 check the song had been downloaded or not
            BOOL downloaded = [[NSFileManager defaultManager] fileExistsAtPath:[song.filePath absoluteString]];
            if (!downloaded) {
                [[AFDownloadHelper sharedAFDownloadHelper] downloadSong:song inAlbum:_album];
            }
            
            //2.2 check the song had been purchased or not
            BOOL purchased = [_appData songNumber:song.songNumber ispurchasedwithAlbum:_album.shortName];
            
            if (!purchased) {
                _appData.coins = _appData.coins - [song.price intValue];
                
                [_appData addtoPurchasedQueue:song withAlbumShortname:_album.shortName];
            }
        }
        [_appData save];
        
        NSString *notification = [NSString stringWithFormat:@"金币  -%d", coinsNeeded];
        [self showNotification:notification];
        
    }
    //if cois is not enough, navigate to store view and give notification
    else{
        UITabBarController *tabBarController = [self getTabbarViewController];
        tabBarController.selectedIndex = 2;
    }
}

- (void)cancelDownloadAll
{
    for (int i = 0; i < _songs.count; i++) {
        Song *song = _songs[i];
        
        NSString *key = [NSString stringWithFormat:@"%@_%@", _album.shortName, song.songNumber];
        
        AFHTTPRequestOperation *operation = [[AFDownloadHelper sharedAFDownloadHelper] searchOperationbyKey:key];
        
        if (![operation isEqual:nil]) {
            [operation cancel];
        }
    }
}

#pragma mark - UI operation event

- (IBAction)onbtn_playAndPausePressed:(id)sender
{
    if (_audioPlayer.state == STKAudioPlayerStatePlaying) {
        [_playerHelper pauseSong];
    }
    else
    {
        [self playSong:_appData.currentSong];
    }
}
- (IBAction)onbtn_nextPressed:(id)sender
{
    [self playNextSong];
}

- (IBAction)onbtn_previousPressed:(id)sender
{
    [self playPreviousSong];
}

-(void)showNotification:(NSString *)notification;
{
    _notificationView.alpha = 1.0;
    
    _notificationView.lbl_coins.text = [NSString stringWithFormat:@"%d", _appData.coins];
    _notificationView.lbl_notification.text = notification;
    
    //show notification view
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.5];
    [UIView setAnimationDelay:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    _notificationView.alpha = 0.0;
    [UIView commitAnimations];
}


- (IBAction)onsliderValueChanged:(id)sender
{
    if (_audioPlayer) {
        [_audioPlayer seekToTime:_slider.value];
    }
}

- (IBAction)onpageChanged:(id)sender
{
    CGPoint offset = CGPointMake(pageControl.currentPage * scrollView.frame.size.width, 0);
    [scrollView setContentOffset:offset animated:YES];
}

- (IBAction)onbarbtn_actionPressed:(id)sender
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil                                                                                  delegate:self
                                                    cancelButtonTitle:[_actionSheetStrings objectForKey:@"cancel"]
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:[_actionSheetStrings objectForKey:@"share"],[_actionSheetStrings objectForKey:@"downloadOrCancelAll"], nil];
    [actionSheet showInView:self.view];

}

#pragma mark - UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        //share
        case 0:
        {
            [self shareAlbum];
        }
            break;
        //download all
        case 1:
        {
            if ([[_actionSheetStrings objectForKey:@"downloadOrCancelAll"] isEqual: @"全部下载"]) {
    
                [self downloadAll];
                [_actionSheetStrings setValue:@"停止下载" forKey:@"downloadOrCancelAll"];
                
                break;
                 
            }
            if ([[_actionSheetStrings objectForKey:@"downloadOrCancelAll"] isEqual: @"停止下载"])
                
                [self cancelDownloadAll];
                [_actionSheetStrings setValue:@"全部下载" forKey:@"downloadOrCancelAll"];
            
                break;
            }
            break;
        default:
            break;
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = [_songs objectAtIndex:indexPath.row];
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell" forIndexPath:indexPath];
    
    //Clear content
    cell.cirProgView_downloadProgress.hidden = YES;
    cell.btn_downloadOrPause.hidden = YES;
    
    //Update UI according to song status
    cell.lbl_songTitle.text = song.title;
    cell.lbl_songDuration.text = song.duration;
    cell.lbl_songNumber.text = song.songNumber;
    cell.lbl_songDuration.text = song.duration;
    
    //customize the selected table view cell
    UIImageView *imageView_playing = [[UIImageView alloc] initWithFrame:CGRectMake(0, 6, 5, 48)];
    imageView_playing.image = [UIImage imageNamed:@"playingsong.png"];
    
    [cell.selectedBackgroundView addSubview:imageView_playing];
    
    cell.song = song;
    cell.album = _album;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *selectedSong = [_songs objectAtIndex:indexPath.row];
    
    //1. check the selected song is current playing song
    if ([[selectedSong.Url absoluteString] isEqualToString:[_appData.currentSong.Url absoluteString]]) {
        //1.1 check current song is playing or paused
        if (_audioPlayer.state == STKAudioPlayerStatePlaying) {
            
            //pause the song
            [_playerHelper pauseSong];
        }
        else{
            //resume the song
            [self playSong:selectedSong];
        }
    }
    //2. the selected song is a new song
    else{
        
        [self playSong:selectedSong];
    }
    
    NSLog(@"%d", self.modalTransitionStyle);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    // First, determine which page is currently visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Update the page control
    pageControl.currentPage = page;
}

#pragma mark - STKAudioPlayerHelperDelegate

-(void) didFinishedPlayingSong
{
    [self playNextSong];
}

@end
