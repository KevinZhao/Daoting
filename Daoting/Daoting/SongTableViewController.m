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
    [super viewDidLoad];
 
    //Configure Local variable
    _playerHelper   = [STKAudioPlayerHelper sharedInstance];
    _audioPlayer    = _playerHelper.audioPlayer;
    _appData        = [AppData sharedAppData];
    
    _appDelegate    = [[UIApplication sharedApplication]delegate];
    _slider.tintColor = _appDelegate.defaultColor_light;

    UIImage *progressBarImage = [UIImage imageNamed:@"progressBar.png"];
    [_slider setThumbImage:progressBarImage forState:UIControlStateNormal];
    
    _tableview.backgroundColor = _appDelegate.defaultBackgroundColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _playerHelper.delegate = self;
    _songArray = [[CategoryManager sharedManager]searchSongArrayByAlbum:_album];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //Calculate size of scroll view
    scrollViewHeight = self.view.frame.size.height - self.img_PlayBar.frame.size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    scrollViewWidth = self.view.frame.size.width * 2;
    
    [scrollView setFrame:CGRectMake(0, ([UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height), self.view.frame.size.width, scrollViewHeight)];
    scrollView.contentSize = CGSizeMake(scrollViewWidth, scrollViewHeight);
    scrollView.delegate = self;
    
    //Configure tableview
    _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, scrollViewHeight) style:UITableViewStylePlain];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.rowHeight = 45;
    _tableview.backgroundColor = _appDelegate.defaultBackgroundColor;
    
    //Load from xib for prototype cell
    [_tableview registerNib:[UINib nibWithNibName:@"SongCell" bundle:nil]forCellReuseIdentifier:@"SongCell"];

    //Configure Scroll View
    [scrollView addSubview:_tableview];
    [self setupDescriptionView];
    [scrollView addSubview:_descriptionView];
    
    //Configure pagecontrol
    pageControl.currentPage = 0;
    pageControl.numberOfPages = 2;
    pageControl.currentPageIndicatorTintColor = _appDelegate.defaultColor_dark;
    pageControl.pageIndicatorTintColor = _appDelegate.defaultColor_light;
    
    //Scroll to latest playing row
    [self navigateToLatestSong];
    
    self.navigationItem.title = _album.title;
    [self setupTimer];
    
    [CategoryManager sharedManager].delegate = self;
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [_tableview reloadData];
    
    [_timer invalidate];
    
    _playerHelper.delegate = nil;
    
    [CategoryManager sharedManager].delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Internal business logic
- (void)setupDescriptionView
{
    //int scrollViewHeight = self.view.frame.size.height - self.img_PlayBar.frame.size.height;
    _descriptionView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, scrollViewHeight)];
    _descriptionView.backgroundColor = _appDelegate.defaultBackgroundColor;
    
    UIScrollView *_scrollView_description = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, scrollViewHeight)];
    [_descriptionView addSubview:_scrollView_description];
    
    //1. Album image
    UIImageView *img_artist = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 64, 64)];
    [img_artist setImageWithURL:_album.imageUrl];
    [_scrollView_description addSubview:img_artist];
    
    //Next Version
    /*UIImageView *img_artist = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 406)];
     [img_artist setImageWithURL:_album.imageUrl];
     
     img_artist.alpha = 0.2;
     [img_artist setImageToBlur:img_artist.image blurRadius:kLBBlurredImageDefaultBlurRadius completionBlock:nil];*/
    
    //2. Download all button
    UIButton *btn_downloadAll = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn_downloadAll setFrame:CGRectMake(220, 54, 70, 30)];
    [btn_downloadAll setTitle:@"全部下载" forState:UIControlStateNormal];
    [_scrollView_description addSubview:btn_downloadAll];
    
    [btn_downloadAll addTarget:self action:@selector(downloadAll) forControlEvents:UIControlEventTouchUpInside];
    
    //3. description label
    UILabel* lbl_description = [[UILabel alloc]init];
    
    [lbl_description setNumberOfLines:0];
    lbl_description.lineBreakMode = NSLineBreakByWordWrapping;
    lbl_description.text = _album.longdescription;
    
    UIFont *font =[UIFont fontWithName:lbl_description.font.familyName size:17];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    
    CGSize textSize = [lbl_description.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 20, 2000)
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      attributes:dic
                                                         context:nil].size;
    
    [lbl_description setFrame:CGRectMake(20, 90, textSize.width, textSize.height)];
    
    // 4. Resize scroll view
    _scrollView_description.contentSize = CGSizeMake(_descriptionView.frame.size.width, textSize.height + 90);
    [_scrollView_description addSubview:lbl_description];

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
            [_appData save];
            [_appData updateToiCloud];
            
            [self playSongbyHelper:song];
            
            //Add to purchased queue
            [_appData addtoPurchasedQueue:song withAlbumShortname:_album.shortName];
            
            if ([song.updatedSong isEqualToString:@"YES"]) {
                song.updatedSong = @"NO";
                
                [[CategoryManager sharedManager] writeBacktoSongListinAlbum:_album];
            }
            
            [_appData save];
            
            [TSMessage showNotificationInViewController:self title:[NSString stringWithFormat:@"金币  -%@", song.price] subtitle:nil type:TSMessageNotificationTypeSuccess];
        }
        else
        //2.2.2 cois is not enough
        {
            //notify user and show store view
            [TSMessage showNotificationInViewController:self title:[NSString stringWithFormat:@"现有金币不足，请从商店购买"]  subtitle:nil type:TSMessageNotificationTypeWarning];
            
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
    [_timer invalidate];
    
    _timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(tick) userInfo:nil repeats:YES];
        
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
            break;
        
        case STKAudioPlayerStatePaused:
            [_btn_playAndPause setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_n.png"] forState:UIControlStateNormal];
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
    Song *song = [_songArray objectAtIndex:indexPath.row];
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
                songCell.cirProgView_downloadProgress.hidden = NO;
                songCell.cirProgView_downloadProgress.progress = 0;
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
                //[songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download_pause_pressed.png"] forState:UIControlStateSelected];

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
    
    if ([song.updatedSong isEqualToString:@"YES"]) {
        songCell.img_new.hidden = NO;
    }
    else
    {
        songCell.img_new.hidden = YES;
    }
    
    //2. Check if the song had been purchased
    if ([_appData songNumber:song.songNumber ispurchasedwithAlbum:_album.shortName]) {
        
        songCell.img_locked.hidden = YES;
        songCell.img_new.hidden = YES;
    }
    else
    {
        songCell.img_locked.hidden = NO;
        songCell.img_new.hidden = NO;
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
        [dict setObject:[NSString stringWithFormat:@"%@ %@", song.title, song.songNumber] forKey:MPMediaItemPropertyAlbumTitle];
        [dict setObject:album.artistName forKey:MPMediaItemPropertyArtist];
        //Revisit next Version
        //todo
        //[dict setObject:[NSNumber numberWithInteger:_audioPlayer.duration] forKey:MPMediaItemPropertyPlaybackDuration];
        //[dict setObject:[NSNumber numberWithInteger:_audioPlayer.progress] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        [dict setObject:[NSNumber numberWithInteger:6000] forKey:MPMediaItemPropertyPlaybackDuration];
        [dict setObject:[NSNumber numberWithInteger:1000] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        [dict setObject:[NSNumber numberWithInteger:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        [dict setObject:[NSNumber numberWithInteger:2] forKey:MPMediaItemPropertyAlbumTrackCount];
        
        UIImage *placeholderImage = [UIImage imageNamed:@"Icon-72.png"];
        UIImageView *imgv = [[UIImageView alloc]init];
        //todo: bug, when app move to background and back to foreground
        [imgv setImageWithURL:album.imageUrl placeholderImage:placeholderImage];
        UIImage *img = imgv.image;
        
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
                [_playerHelper playPreviousSong];
                break;
            }
            case UIEventSubtypeRemoteControlNextTrack:
            {
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
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"评书、有声书都有,我正在听 %@的《%@》%@", _album.artistName,_album.title, _appDelegate.appUrlinAws]
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:[_album.imageUrl absoluteString]]
                                                title:[NSString stringWithFormat:@"评书、有声书都有,我正在听 %@的《%@》%@", _album.artistName,_album.title, _appDelegate.appUrlinAws]
                                                  url:_appDelegate.appUrlinAws
                                          description:@""
                                            mediaType:SSPublishContentMediaTypeNews];
    
    
    [ShareSDK showShareViewWithType:ShareTypeWeixiTimeline
                          container:nil
                            content:publishContent
                      statusBarTips:NO authOptions:nil
                       shareOptions:nil
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSResponseStateSuccess)
                                 {
                                     [TSMessage showNotificationInViewController:self title:@"分享成功" subtitle:nil type:TSMessageNotificationTypeSuccess];
                                 }
                                 else if (state == SSResponseStateFail)
                                 {
                                     //NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
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
    for (int i = 0; i < _songArray.count; i++) {
        
        Song *song = _songArray[i];
        
        //1.1 check the song had been purchased or not
        BOOL purchased = [_appData songNumber:song.songNumber ispurchasedwithAlbum:_album.shortName];
        if (!purchased) {
            coinsNeeded = coinsNeeded + [song.price intValue];
        }
    }
    //2.if coin is enough, add all download item into download queue
    if (_appData.coins >= coinsNeeded) {
        
        for (int i = 0; i < _songArray.count; i++) {
            
            Song *song = _songArray[i];
            
            //2.1 check the song had been downloaded or not
            BOOL downloaded = [[NSFileManager defaultManager] fileExistsAtPath:[song.filePath absoluteString]];
            if (!downloaded) {
                [[AFDownloadHelper sharedAFDownloadHelper] downloadSong:song inAlbum:_album];
            }
            
            //2.2 check the song had been purchased or not
            BOOL purchased = [_appData songNumber:song.songNumber ispurchasedwithAlbum:_album.shortName];
            
            if (!purchased) {
                _appData.coins = _appData.coins - [song.price intValue];
                
                [[AppData sharedAppData] addtoPurchasedQueue:song withAlbumShortname:_album.shortName];
                if ([song.updatedSong isEqualToString:@"YES"]) {
                    song.updatedSong = @"NO";
                }
            }
        }
        
        [[CategoryManager sharedManager] writeBacktoSongListinAlbum:_album];
        [_appData save];
        [_appData updateToiCloud];
        
        [TSMessage showNotificationInViewController:[self getTabbarViewController] title:[NSString stringWithFormat:@"金币  -%d", coinsNeeded]  subtitle:nil type:TSMessageNotificationTypeSuccess];
    }
    //if cois is not enough, navigate to store view and give notification
    else{
        
        for (int i = 0; i < _songArray.count; i++) {
            
            Song *song = _songArray[i];
            
            //2.2 check the song had been purchased or not
            BOOL purchased = [_appData songNumber:song.songNumber ispurchasedwithAlbum:_album.shortName];
            if (purchased) {
                
                //2.1 check the song had been downloaded or not
                BOOL downloaded = [[NSFileManager defaultManager] fileExistsAtPath:[song.filePath absoluteString]];
                if (!downloaded) {
                    [[AFDownloadHelper sharedAFDownloadHelper] downloadSong:song inAlbum:_album];
                }
            }
        }
        
        UITabBarController *tabBarController = [self getTabbarViewController];
        tabBarController.selectedIndex = 2;
        
        [TSMessage showNotificationInViewController:tabBarController title:@"您的金币不足，请购买更多金币" subtitle:nil type:TSMessageNotificationTypeWarning];
        

    }
}

- (void)cancelDownloadAll
{
    for (int i = 0; i < _songArray.count; i++) {
        Song *song = _songArray[i];
        
        NSString *key = [NSString stringWithFormat:@"%@_%@", _album.shortName, song.songNumber];
        
        AFHTTPRequestOperation *operation = [[AFDownloadHelper sharedAFDownloadHelper] searchOperationbyKey:key];
        
        if (![operation isEqual:nil]) {
            [operation cancel];
        }
    }
}

- (void)navigateToLatestSong
{
    //Scroll to latest playing row
    NSString* songNumberstring = (NSString*)[_appData.playingPositionQueue objectForKey:_album.title];
    NSInteger songNumber = [songNumberstring integerValue];
    
    NSIndexPath *indexPath;
    if (songNumber > 0) {
        indexPath = [NSIndexPath indexPathForRow:(songNumber-1) inSection:0];
    }
    else
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }

    if (songNumber <= _songArray.count) {
        [_tableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}


#pragma mark - UI operation event

- (IBAction)onbtn_playAndPausePressed:(id)sender
{
    //is playing
    if (_audioPlayer.state == STKAudioPlayerStatePlaying) {
        [_playerHelper pauseSong];
    }
    //no song is playing
    else
    {
        //not current song record
        if (_appData.currentSong != nil) {
            [self playSong:_appData.currentSong];
        }
        else
        {
            [self playSong:_songArray[0]];
        }
    }
}

- (IBAction)onbtn_nextPressed:(id)sender
{
    //check currentSongNumber
    NSInteger currentSongNumber = [_appData.currentSong.songNumber intValue];
    
    if (currentSongNumber < _songArray.count) {
        Song *song = [_songArray objectAtIndex:currentSongNumber];
        
        [self playSong:song];
    }
    
    [self onPlayerHelperSongChanged];
}

- (IBAction)onbtn_previousPressed:(id)sender
{
    //[self test];
    
    NSInteger currentSongNumber = [_appData.currentSong.songNumber intValue];
    
    if ( currentSongNumber - 1 > 0) {
        Song *song = [_songArray objectAtIndex:(currentSongNumber -2)];
        
        [self playSong:song];
    }
    
    [self onPlayerHelperSongChanged];
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

- (IBAction)onbtn_sharePressed:(id)sender
{
    [self shareAlbum];
}

- (IBAction)onbtn_downloadAllPressed:(id)sender
{
    [self downloadAll];
}


#pragma mark - Category Manager Delegate

- (void)onSongUpdated
{
    _songArray = [[CategoryManager sharedManager] searchSongArrayByAlbum:_album];
    
    [_tableview reloadData];
    
    [self navigateToLatestSong];
    
    //[self test];
}

- (void)onCategoryUpdated
{

}

-(void)onAlbumUpdated
{
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _songArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = [_songArray objectAtIndex:indexPath.row];
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    //Clear content
    cell.cirProgView_downloadProgress.hidden = YES;
    cell.btn_downloadOrPause.hidden = YES;
    cell.img_new.hidden = YES;
    
    cell.cirProgView_downloadProgress.thicknessRatio = 0.075;
    [cell.cirProgView_downloadProgress setTrackTintColor:[UIColor grayColor]];
    [cell.cirProgView_downloadProgress setProgressTintColor:_appDelegate.defaultColor_light];
    
    //Update UI according to song status
    cell.lbl_songTitle.text = song.title;
    cell.lbl_songDuration.hidden = YES;
    cell.lbl_songDuration.text = song.duration;
    cell.lbl_songNumber.text = song.songNumber;
    
    //revisit
    cell.lbl_songDescription.text = song.description;
    cell.lbl_songDescription.font = [UIFont fontWithName:@"Arial" size:10.0f];
    cell.lbl_songDescription.marqueeType = MLContinuous;
    cell.lbl_songDescription.scrollDuration = 10.0f;
    cell.lbl_songDescription.animationCurve = UIViewAnimationCurveEaseInOut;
    cell.lbl_songDescription.fadeLength = 10.0f;
    cell.lbl_songDescription.continuousMarqueeExtraBuffer = 10.0f;
    [cell.lbl_songDescription pauseLabel];
    
    //customize the selected table view cell
    UIImageView *imageView_playing = [[UIImageView alloc] initWithFrame:CGRectMake(0, 4, 5, 36)];
    imageView_playing.image = [UIImage imageNamed:@"playingsong.png"];
    
    [cell.selectedBackgroundView addSubview:imageView_playing];
    
    cell.song = song;
    cell.album = _album;
    
    //set separator color
    [tableView setSeparatorColor:[UIColor clearColor]];
    
    //set tableviewcell background
    UIImage *img = [UIImage imageNamed:@"songcell_bg.png"];
    UIEdgeInsets insets = UIEdgeInsetsMake(1, 28, 1, 1);
    img = [img resizableImageWithCapInsets:insets];
    
    [cell setBackgroundView:[[UIImageView alloc]initWithImage:img]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *selectedSong = [_songArray objectAtIndex:indexPath.row];
    
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
    //1. update for selection change
    if ([_album.shortName isEqualToString: _appData.currentAlbum.shortName]) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_appData.currentSong.songNumber integerValue] -1 inSection:0];
        
        [_tableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}

#pragma mark - Test

- (void)test
{
    t_currentsong = 0;
    
    Song *song = _songArray[t_currentsong];
    
    [self playSongbyHelper:song];
}

- (void)onTest
{
    NSLog(@"onTest %d", t_currentsong);
    
    if (t_currentsong == (_songArray.count - 1)) {
        [[CategoryManager sharedManager] writeBacktoSongListinAlbum:_album];
        return;
    }
    
    Song *song = _songArray[t_currentsong];
    
    song.duration = [self formatTimeFromSeconds:_playerHelper.audioPlayer.duration];
    
    [self onbtn_nextPressed:nil];
    t_currentsong++;
}

@end
