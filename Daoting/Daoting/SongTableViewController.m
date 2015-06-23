//
//  SongTableViewController.m
//  Daoting
//
//  Created by Kevin on 14-5-12.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "SongTableViewController.h"

@implementation SongTableViewController
@synthesize pageControl, scrollView;

#pragma mark - UIView delegate

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    //Configure Local variable
    _sharedAudioplayerHelper    = [STKAudioPlayerHelper sharedInstance];
    _sharedAFDownloadHelper     = [AFDownloadHelper sharedAFDownloadHelper];
    _sharedCategoryManager      = [CategoryManager sharedManager];
    _sharedPurchaseRecordsHelper = [PurchaseRecordsHelper sharedInstance];
    
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
    
    _sharedAudioplayerHelper.delegate = self;
    _sharedAFDownloadHelper.delegate = self;
    _sharedPurchaseRecordsHelper.delegate = self;
    
    _songArray = [[CategoryManager sharedManager]initializeSongArrayByAlbum:_album];
    
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
    _sharedCategoryManager.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _sharedAudioplayerHelper.delegate = nil;
    _sharedAFDownloadHelper.delegate = nil;
    _sharedCategoryManager.delegate = nil;
    _sharedPurchaseRecordsHelper.delegate = nil;
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
    /*UIButton *btn_downloadAll = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn_downloadAll setFrame:CGRectMake(220, 54, 70, 30)];
    [btn_downloadAll setTitle:@"全部下载" forState:UIControlStateNormal];
    [_scrollView_description addSubview:btn_downloadAll];*/
    
    //[btn_downloadAll addTarget:self action:@selector(downloadAll) forControlEvents:UIControlEventTouchUpInside];
    
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
        
        if ( _appData.coins > [song.price integerValue]) {
            
            //Purchase succeed
            if ([self purchaseSong:song]) {
                
                //1. update song status for plist
                if ([song.updatedSong isEqualToString:@"YES"]) {
                    song.updatedSong = @"NO";
                    
                    [[CategoryManager sharedManager] writeBacktoSongListinAlbum:_album];
                }
                
                //2. play song
                [self playSongbyHelper:song];
                
                //3. UI updating
                [TSMessage showNotificationInViewController:self title:[NSString stringWithFormat:@"金币  -%@", song.price] subtitle:nil type:TSMessageNotificationTypeSuccess];
                
                //4. Record in remote database
                [_sharedPurchaseRecordsHelper purchase:song.songNumber in:_album.shortName];
                
            }
            //Purchase failed
            else
            {
                [TSMessage showNotificationInViewController:self title:@"程序错误，请从商店重新下载或联系客服" subtitle:nil type:TSMessageNotificationTypeWarning];
            }
        }
        //Coin is not enough
        else
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
    [_sharedAudioplayerHelper playSong:song InAlbum:_album];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[song.songNumber intValue] - 1 inSection:0];
    [_tableview beginUpdates];
    [_tableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [_tableview endUpdates];
}


- (void)setDetailItem:(Album *)album
{
    _album = album;
}

- (void)updateCellUIFor:(Song*) song
{
    NSIndexPath *songIndexPath = [NSIndexPath indexPathForRow:([song.songNumber integerValue]-1) inSection:0];
    SongCell *songCell = (SongCell*)[_tableview cellForRowAtIndexPath:songIndexPath];
    
    if (songCell != nil) {
        
        switch (song.downloadingStatus) {
                
                //Waiting for download
            case DownloadStatusWaiting:
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
            case DownloadStatusDownloading:
            {
                songCell.btn_downloadOrPause.hidden = NO;
                [songCell.btn_downloadOrPause removeTarget:songCell action:@selector(onbtn_downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
                [songCell.btn_downloadOrPause addTarget:songCell action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download_pause.png"] forState:UIControlStateNormal];
                [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download_pause_pressed.png"] forState:UIControlStateSelected];
                
            }
                break;
                //Download Completed
            case DownloadStatusCompleted:
            {
                songCell.cirProgView_downloadProgress.hidden = YES;
                
                songCell.btn_downloadOrPause.hidden = YES;
                songCell.lbl_songDuration.hidden = NO;
            }
                break;
                //Download Failed
            case DownloadStatusError:
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
}

-(NSString*)formatTimeFromSeconds:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
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

/*- (void)downloadAll
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
}*/

- (BOOL)purchaseSong:(Song*) song
{
    if ([_sharedPurchaseRecordsHelper addtoPurchasedQueue:song withAlbumShortname:_album.shortName]) {
        _appData.coins = _appData.coins - [song.price intValue];
            
        [_appData save];
        [_appData saveToiCloud];
        
    }
    else
    {
        return NO;
    }
    
    return YES;
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

    if (_songArray.count > 0) {
        [_tableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}


#pragma mark - UI operation event

- (IBAction)onbtn_playAndPausePressed:(id)sender
{
    //is playing
    if (_sharedAudioplayerHelper.playerState == STKAudioPlayerStatePlaying) {
        [_sharedAudioplayerHelper pauseSong];
    }
    //no song is playing
    else
    {
        //not current song record
        if (_appData.currentSong != nil) {
            
            if ([_appData.currentAlbum.shortName isEqualToString:_album.shortName]) {
                [self playSong:_appData.currentSong];
            }
            
            else
            {
                //Scroll to latest playing row
                NSString* songNumberstring = (NSString*)[_appData.playingPositionQueue objectForKey:_album.title];
                NSInteger songNumber = [songNumberstring integerValue];
                
                if (songNumber > 0) {
                    [self playSong:_songArray[songNumber - 1]];
                }
                else
                {
                    [self playSong:_songArray[0]];
                }
            }
        }
        else
        {
            [self playSong:_songArray[0]];
        }
    }
}

- (IBAction)onbtn_nextPressed:(id)sender
{
    [_sharedAudioplayerHelper playNextSong];
}

- (IBAction)onbtn_previousPressed:(id)sender
{

//#ifdef DEBUG
//    [_appData cleariCloudData];
//#else
    [_sharedAudioplayerHelper playPreviousSong];
//#endif

}

- (IBAction)onsliderValueChanged:(id)sender
{
    [_sharedAudioplayerHelper seekToProgress:_slider.value];
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

/*- (IBAction)onbtn_downloadAllPressed:(id)sender
{
    [self downloadAll];
}*/


#pragma mark - Category Manager Delegate

- (void)onSongUpdated
{
    _songArray = [[CategoryManager sharedManager] initializeSongArrayByAlbum:_album];
    
    [_tableview reloadData];
    
    [self navigateToLatestSong];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SongCell* songCell = (SongCell*) cell;
    Song *song = [_songArray objectAtIndex:indexPath.row];
    
    //1. Clear content
    songCell.cirProgView_downloadProgress.hidden = YES;
    songCell.btn_downloadOrPause.hidden = YES;
    songCell.img_new.hidden = YES;
    songCell.lbl_songDuration.hidden = YES;
    
    //2. Check song had been downloaded
    //Song had been downloaded
    if (![[song.filePath absoluteString] isEqualToString:@""]){
        
        NSURL* fileURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        fileURL = [fileURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", [song.filePath path]]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
            songCell.cirProgView_downloadProgress.hidden = YES;
            songCell.btn_downloadOrPause.hidden = YES;
            [songCell.btn_downloadOrPause removeTarget:songCell action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
            songCell.lbl_songDuration.hidden = NO;
        }
        //todo: this is casued by clear cache method, need to be revisit next version
        else
        {
            song.filePath = [NSURL URLWithString:@""];
            [_sharedCategoryManager writeBacktoSongListinAlbum:_album];
            
            songCell.cirProgView_downloadProgress.hidden = YES;
            
            songCell.btn_downloadOrPause.hidden = NO;
            [songCell.btn_downloadOrPause removeTarget:songCell action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
            [songCell.btn_downloadOrPause addTarget:songCell action:@selector(onbtn_downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
            [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download_pressed.png"] forState:UIControlStateSelected];
        }
    }
    //Song had not been downloaded
    else{
        switch (song.downloadingStatus) {
            case DownloadStatusNotDownload:
            {
                songCell.cirProgView_downloadProgress.hidden = YES;
                
                songCell.btn_downloadOrPause.hidden = NO;
                [songCell.btn_downloadOrPause removeTarget:songCell action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
                [songCell.btn_downloadOrPause addTarget:songCell action:@selector(onbtn_downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
                [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download_pressed.png"] forState:UIControlStateSelected];
            }
                break;
                
                //Waiting for download
            case DownloadStatusWaiting:
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
            case DownloadStatusDownloading:
            {
                songCell.btn_downloadOrPause.hidden = NO;
                [songCell.btn_downloadOrPause removeTarget:songCell action:@selector(onbtn_downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
                [songCell.btn_downloadOrPause addTarget:songCell action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download_pause.png"] forState:UIControlStateNormal];
                [songCell.btn_downloadOrPause setImage:[UIImage imageNamed:@"download_pause_pressed.png"] forState:UIControlStateSelected];
                
            }
                break;
                //Download Completed
            case DownloadStatusCompleted:
            {
                songCell.cirProgView_downloadProgress.hidden = YES;
                
                songCell.btn_downloadOrPause.hidden = YES;
                songCell.lbl_songDuration.hidden = NO;
            }
                break;
                //Download Failed
            case DownloadStatusError:
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
    
    
    //3. Check if the song had been purchased
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = [_songArray objectAtIndex:indexPath.row];
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell" forIndexPath:indexPath];
    
    //1. Set value for static UI componenet
    cell.lbl_songTitle.text = song.title;
    cell.lbl_songDuration.text = song.duration;
    cell.lbl_songNumber.text = song.songNumber;
    
    cell.lbl_songDescription.text = song.description;
    cell.lbl_songDescription.font = [UIFont fontWithName:@"Arial" size:10.0f];
    cell.lbl_songDescription.marqueeType = MLContinuous;
    cell.lbl_songDescription.scrollDuration = 10.0f;
    cell.lbl_songDescription.animationCurve = UIViewAnimationCurveEaseInOut;
    cell.lbl_songDescription.fadeLength = 10.0f;
    
    //2. Configure download progress view
    cell.cirProgView_downloadProgress.thicknessRatio = 0.075;
    [cell.cirProgView_downloadProgress setTrackTintColor:[UIColor grayColor]];
    [cell.cirProgView_downloadProgress setProgressTintColor:_appDelegate.defaultColor_light];

    //3. Set cell background
    cell.backgroundColor = [UIColor clearColor];
    
    UIImage *img = [UIImage imageNamed:@"songcell_bg.png"];
    UIEdgeInsets insets = UIEdgeInsetsMake(1, 28, 1, 1);
    img = [img resizableImageWithCapInsets:insets];
    [cell setBackgroundView:[[UIImageView alloc]initWithImage:img]];

    [tableView setSeparatorColor:[UIColor clearColor]];
    
    //4. Customize the selected view for cell
    UIImageView *imageView_playing = [[UIImageView alloc] initWithFrame:CGRectMake(0, 4, 5, 36)];
    imageView_playing.image = [UIImage imageNamed:@"playingsong.png"];
    [cell.selectedBackgroundView addSubview:imageView_playing];
    
    //5. Metada for cell
    cell.song = song;
    cell.album = _album;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *selectedSong = [_songArray objectAtIndex:indexPath.row];
    
    //1. check the selected song is current playing song
    if ([[selectedSong.Url absoluteString] isEqualToString:[_appData.currentSong.Url absoluteString]]) {
        //1.1 check current song is playing or paused
        if (_sharedAudioplayerHelper.playerState == STKAudioPlayerStatePlaying) {
            
            //pause the song
            [_sharedAudioplayerHelper pauseSong];
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

-(void) onProgressUpdated
{
    _lbl_progressCurrentValue.text = [NSString stringWithFormat:@"%@", [self formatTimeFromSeconds:_sharedAudioplayerHelper.progress]];
    _lbl_progressMaxValue.text = [NSString stringWithFormat:@"%@", [self formatTimeFromSeconds:_sharedAudioplayerHelper.duration]];
        
    _slider.enabled = YES;
    _slider.minimumValue = 0;
    _slider.maximumValue = _sharedAudioplayerHelper.duration;
    _slider.value = _sharedAudioplayerHelper.progress;
    
    [_btn_playAndPause setBackgroundImage:[UIImage imageNamed:@"playing_btn_pause_n.png"] forState:UIControlStateNormal];
}

-(void) onPlayerPaused
{
    [_btn_playAndPause setBackgroundImage:[UIImage imageNamed:@"playing_btn_play_n.png"] forState:UIControlStateNormal];
}

#pragma mark AFDownloadHelperDelegate

-(void) onDownloadStartedForOperation:(AFHTTPRequestOperation*) operation
{
    Song* song = [operation.userInfo objectForKey:@"song"];
    Album* album = [operation.userInfo objectForKey:@"album"];
    DownloadingStatus* downloadStatus = [operation.userInfo objectForKey:@"status"];
    
    if ([album.shortName isEqualToString:_album.shortName]) {
        song.downloadingStatus = downloadStatus.downloadingStatus;
        [self updateCellUIFor:song];
    }
}

-(void) onDownloadProgressedForOperation:(AFHTTPRequestOperation*) operation
{
    Song* song = [operation.userInfo objectForKey:@"song"];
    Album* album = [operation.userInfo objectForKey:@"album"];
    DownloadingStatus* downloadStatus = [operation.userInfo objectForKey:@"status"];
    
    if ([album.shortName isEqualToString:_album.shortName]) {
        song.downloadingStatus = downloadStatus.downloadingStatus;
        NSIndexPath *songIndexPath = [NSIndexPath indexPathForRow:([song.songNumber integerValue]-1) inSection:0];
        SongCell* songCell = (SongCell*)[_tableview cellForRowAtIndexPath:songIndexPath];
        
        songCell.cirProgView_downloadProgress.hidden = NO;
        songCell.cirProgView_downloadProgress.progress =(float) downloadStatus.totalBytesRead / (float)downloadStatus.totalBytesExpectedToRead;
        
        [self updateCellUIFor:song];
    }
}

-(void) onDownloadCompletedForOperation:(AFHTTPRequestOperation*) operation
{
    Song* song = [operation.userInfo objectForKey:@"song"];
    Album* album = [operation.userInfo objectForKey:@"album"];
    DownloadingStatus* downloadStatus = [operation.userInfo objectForKey:@"status"];
    
    if ([album.shortName isEqualToString:_album.shortName]) {
        song.downloadingStatus = downloadStatus.downloadingStatus;
        [self updateCellUIFor:song];
    }
}

-(void) onDownloadFailedForOperation:(AFHTTPRequestOperation*) operation
{
    Song* song = [operation.userInfo objectForKey:@"song"];
    Album* album = [operation.userInfo objectForKey:@"album"];
    DownloadingStatus* downloadStatus = [operation.userInfo objectForKey:@"status"];
    
    if ([album.shortName isEqualToString:_album.shortName]) {
        song.downloadingStatus = downloadStatus.downloadingStatus;
        [self updateCellUIFor:song];
    }
}

- (void)onPurchaseSucceed:(Song *)song
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:([song.songNumber integerValue] - 1) inSection:0];
    SongCell *songcell = (SongCell*)[_tableview cellForRowAtIndexPath:indexPath];
    songcell.img_locked.hidden = YES;
    songcell.img_new.hidden = YES;
}


@end
