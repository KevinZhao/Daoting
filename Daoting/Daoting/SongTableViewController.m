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
    
    _songs = [[SongManager sharedManager] searchSongArrayByAlbumName:_album.shortName];

    [self setupTimer];
    
    [self setupNotificationView];
    
    _actionSheetStrings = [[NSMutableDictionary alloc] init];
    [_actionSheetStrings setObject:@"取消" forKey:@"cancel"];
    [_actionSheetStrings setObject:@"分享" forKey:@"share"];
    [_actionSheetStrings setObject:@"全部下载" forKey:@"downloadOrCancelAll"];
    
    UIImage *progressBarImage = [UIImage imageNamed:@"progressBar.png"];
    [_slider setThumbImage:progressBarImage forState:UIControlStateNormal];
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
    _tableview.rowHeight = 48;
    
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
                
                [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download_pause.png"] forState:UIControlStateNormal];
                [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download_pause_pressed.png"] forState:UIControlStateSelected];
            }
                break;
            //Downloading
            case fileDownloadStatusDownloading:
            {
                //1. Updating progress
                songCell.cirProgView_downloadProgress.hidden = NO;
                
                if (status.totalBytesExpectedToRead != 0) {
                    
                    songCell.cirProgView_downloadProgress.progress =(float) status.totalBytesRead / (float)status.totalBytesExpectedToRead;
                }
                
                //2. 
                songCell.btn_downloadOrPause.hidden = NO;
                [songCell.btn_downloadOrPause removeTarget:songCell action:@selector(onbtn_downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
                [songCell.btn_downloadOrPause addTarget:songCell action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download_pause.png"] forState:UIControlStateNormal];
                [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download_pause_pressed.png"] forState:UIControlStateSelected];

            }
                break;
            //Download Completed
            case fileDownloadStatusCompleted:
            {
                songCell.cirProgView_downloadProgress.hidden = YES;
                
                songCell.btn_downloadOrPause.hidden = YES;
                songCell.btn_downloadOrPause.enabled = false;
                songCell.lbl_songDuration.hidden = NO;
            }
                break;
            //Download Failed
            case fileDownloadStatusError:
            {
                songCell.btn_downloadOrPause.hidden = NO;
                [songCell.btn_downloadOrPause removeTarget:songCell action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
                [songCell.btn_downloadOrPause addTarget:songCell action:@selector(onbtn_downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
                [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
                [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download_pressed.png"] forState:UIControlStateSelected];

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

            songCell.btn_downloadOrPause.hidden = YES;
            [songCell.btn_downloadOrPause removeTarget:songCell action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
            songCell.lbl_songDuration.hidden = NO;

        }
        //Not Downloaded yet
        else{
            songCell.cirProgView_downloadProgress.hidden = YES;
            
            songCell.btn_downloadOrPause.hidden = NO;
            [songCell.btn_downloadOrPause removeTarget:songCell action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
            [songCell.btn_downloadOrPause addTarget:songCell action:@selector(onbtn_downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
            [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download_pressed.png"] forState:UIControlStateSelected];
        }
    }
    
    //2. Check if the song had been purchased
    if ([_appData songNumber:song.songNumber ispurchasedwithAlbum:_album.shortName]) {
        songCell.img_locked.hidden = YES;
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
                //[self playPreviousSong];
                [_playerHelper playPreviousSong];
                break;
            }
            case UIEventSubtypeRemoteControlNextTrack:
            {
                //[self playNextSong];
                [_playerHelper playNextSong];
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
    //todo if cois is not enough, navigate to store view and give notification
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
    [_playerHelper playNextSong];
}

- (IBAction)onbtn_previousPressed:(id)sender
{
    [_playerHelper playPreviousSong];
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
    
    cell.cirProgView_downloadProgress.thicknessRatio = 0.075;
    [cell.cirProgView_downloadProgress setTrackTintColor:[UIColor grayColor]];
    [cell.cirProgView_downloadProgress setProgressTintColor:[UIColor greenColor]];
    
    //Update UI according to song status
    cell.lbl_songTitle.text = song.title;
    cell.lbl_songDuration.hidden = YES;
    cell.lbl_songDuration.text = song.duration;
    cell.lbl_songNumber.text = song.songNumber;
    
    //customize the selected table view cell
    UIImageView *imageView_playing = [[UIImageView alloc] initWithFrame:CGRectMake(0, 6, 5, 38)];
    imageView_playing.image = [UIImage imageNamed:@"playingsong.png"];
    
    [cell.selectedBackgroundView addSubview:imageView_playing];
    
    cell.song = song;
    cell.album = _album;
    
    //set separator color
    [tableView setSeparatorColor:[UIColor clearColor]];
    
    //set tableviewcell background
    UIImage *img = [UIImage imageNamed:@"songcell_bg.png"];
    UIEdgeInsets insets = UIEdgeInsetsMake(2, 28, 2, 2);
    img = [img resizableImageWithCapInsets:insets];

    [cell setBackgroundView:[[UIImageView alloc]initWithImage:img]];
    
    //set tableviewcell background when pressed
    
    

    
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

-(void) onPlayerHelperSongChanged
{
    //3. update for selection change
    if ([_album.shortName isEqualToString: _appData.currentAlbum.shortName]) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_appData.currentSong.songNumber integerValue] -1 inSection:0];
        
        [_tableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
    }
}

@end
