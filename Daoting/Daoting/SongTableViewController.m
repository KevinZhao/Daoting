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
    _audioPlayer = [STKAudioPlayerHelper sharedAudioPlayer];
    
    [super viewDidLoad];
    
    [self loadSongs];
    
    [self updateSongs];
    
    [self setupTimer];
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

    [scrollView addSubview:_tableview];
    
    //Todo: Change to another UIView to give description of album
    UIImageView *test = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wangyuebo.jpg"]];
    test.frame = CGRectMake(320, 0, 320, 406);
    [scrollView addSubview:test];
    
    //Configure pagecontrol
    pageControl.currentPage = 0;
    pageControl.numberOfPages = 2;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Internal business logic

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
    
    //Writeback to songsDictionary
    [[AppData sharedAppData].playingQueue setObject:_songs forKey:_album.shortName];
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
    [[AFNetWorkingOperationManagerHelper sharedInstance].operationQueue addOperation:operation];
    
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
         }
         
     }
     //Download Failed
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //todo: try to redownload from cloud for 3 times
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

-(void)playSong:(Song*)song
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", _album.shortName, song.songNumber];
    
    //2.1 check the song had been purchased or not
    BOOL purchased = [[[AppData sharedAppData].purchasedQueue objectForKey:key] isEqualToString:@"Yes"];
    
    //if the song had been purchased
    if (purchased) {
        
        //play from local reposistory for the song
        [[STKAudioPlayerHelper sharedInstance] playSong:song InAlbum:_album AtProgress:0];
        
    }
    //2.2 the song had not been purchased yet
    else{
        
        //2.2.1 if coin is enough, buy it.
        if ([AppData sharedAppData].coins >= [song.price intValue]) {
            
            [AppData sharedAppData].coins = [AppData sharedAppData].coins - [song.price intValue];
            
            [[STKAudioPlayerHelper sharedInstance] playSong:song InAlbum:_album AtProgress:0];
            
            //Add to purchased queue
            [[AppData sharedAppData].purchasedQueue setObject:@"Yes" forKey:[NSString stringWithFormat:@"%@_%@", _album.shortName, song.songNumber]];
            
            [[AppData sharedAppData] save];
        }
        else
            //2.2.2 cois is not enough
        {
            //todo notify user and show store view
        }
    }
}


- (void)setDetailItem:(Album *)album
{
    _album = album;
}

-(void)setupTimer
{
	_timer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(tick) userInfo:nil repeats:YES];
	
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
        
        [AppData sharedAppData].currentProgress = _audioPlayer.progress;
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
    NSLog(@" indexPath.row = %d", indexPath.row);
    
    SongCell* songCell = (SongCell*)[_tableview cellForRowAtIndexPath:indexPath];
    Song *song = [_songs objectAtIndex:indexPath.row];
    NSString *key = [NSString stringWithFormat:@"%@_%@", _album.shortName, song.songNumber];
    NSString *PositioninQueue =  [[AFNetWorkingOperationManagerHelper sharedManagerHelper].downloadKeyQueue objectForKey:key];
    
    //1. Check if the operation in download queue
    if (PositioninQueue != nil) {
    
        DownloadingStatus *status = [[AFNetWorkingOperationManagerHelper sharedManagerHelper].downloadStatusQueue objectAtIndex:[PositioninQueue intValue]];
        
        
        switch (status.downloadingStatus) {
            case fileDownloadStatusDownloading:
            {
                songCell.lbl_songDuration.text = [NSString stringWithFormat:@"%lld / %lld", status.totalBytesRead, status.totalBytesExpectedToRead];
            }
                break;

            case fileDownloadStatusCompleted:
            {
                //songCell.btn_downloadOrPause.hidden = YES;
            }
                break;
            
            case fileDownloadStatusError:
            {
                
            }
            
            default:
                break;
        }
    }
    
    //2. Check if the file had been downloaded for the cell
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[song.filePath absoluteString]])
    {
        //NSLog([song.filePath absoluteString]);
        songCell.btn_downloadOrPause.hidden = YES;
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
    Album *album = [AppData sharedAppData].currentAlbum;
    Song *song= [AppData sharedAppData].currentSong;
    STKAudioPlayer *player = [STKAudioPlayerHelper sharedAudioPlayer];
    
    //Set Information for Nowplaying Info Center
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:song.title forKey:MPMediaItemPropertyAlbumTitle];
        [dict setObject:album.artistName forKey:MPMediaItemPropertyArtist];
        [dict setObject:[NSNumber numberWithInteger:player.duration] forKey:MPMediaItemPropertyPlaybackDuration];
        [dict setObject:[NSNumber numberWithInteger:player.progress] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        [dict setObject:[NSNumber numberWithInteger:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        [dict setObject:[NSNumber numberWithInteger:2] forKey:MPMediaItemPropertyAlbumTrackCount];
        
        UIImage *img = [UIImage imageNamed: @"wangyuebo.jpg"];
        MPMediaItemArtwork * mArt = [[MPMediaItemArtwork alloc] initWithImage:img];
        [dict setObject:mArt forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
        
    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    STKAudioPlayer *player = [STKAudioPlayerHelper sharedAudioPlayer];
    
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                if (player.state == STKAudioPlayerStatePlaying) {
                    
                    [player pause];
                    
                }else{
                    
                    [player resume];
                }
                break;
            }
            case UIEventSubtypeRemoteControlPause:
            {
                [player pause];
                
                break;
            }
                
            case UIEventSubtypeRemoteControlPlay:
            {
                [player resume];
                //[self playOrResumeSong:storedPlayingIndexPath At:0];
                break;
            }
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                //NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:(currentPlayingIndexPath.row-1) inSection:0];
                //[self playOrResumeSong:previousIndexPath At:0];
                break;
            }
            case UIEventSubtypeRemoteControlNextTrack:
            {
                //NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:(currentPlayingIndexPath.row+1) inSection:0];
                //[self playOrResumeSong:nextIndexPath At:0];
                break;
            }
            default:
                break;
        }
    }
}


#pragma mark - UI operation event

- (IBAction)onbtn_playAndPausePressed:(id)sender
{
    if (_audioPlayer.state == STKAudioPlayerStatePlaying) {
        [_audioPlayer pause];
    }
    else
    {
        //[_audioPlayer play:]
    }

    
}
- (IBAction)onbtn_nextPressed:(id)sender
{

}

-(void)test
{
    //test: processing plist in document and download it back
    NSString *bundleDocumentDirectoryPath =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *plistPath =
    [bundleDocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_SongList.plist", _album.shortName]];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    for (int i = 1; i<= dictionary.count; i++)
    {
        NSMutableDictionary *songArray = [dictionary objectForKey:[NSString stringWithFormat:@"%d",i]];
        [songArray setObject:@"" forKey:@"Price"];
    }
    
    plistPath = [plistPath stringByAppendingString:@"_new"];
    
    [dictionary writeToFile:plistPath atomically:YES];
    
    NSLog(@"completed");
}

- (IBAction)onbtn_previousPressed:(id)sender
{
    
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


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = [_songs objectAtIndex:indexPath.row];
    
    //Load from xib for prototype cell
    [tableView registerNib:[UINib nibWithNibName:@"SongCell" bundle:nil]forCellReuseIdentifier:@"SongCell"];
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell"];
    
    //Update UI according to song status
    cell.lbl_songTitle.text = song.title;
    cell.lbl_songDuration.text = song.duration;
    cell.lbl_songNumber.text = song.songNumber;
    cell.lbl_songDuration.text = song.duration;
    
    cell.song = song;
    cell.album = _album;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *selectedSong = [_songs objectAtIndex:indexPath.row];
    
    //1. check the selected song is current playing song
    if (selectedSong == [AppData sharedAppData].currentSong) {
        //1.1 check current song is playing or paused
        if (_audioPlayer.state == STKAudioPlayerStatePlaying) {
            
            //pause the song
            [_audioPlayer pause];
        }
        else{
         
            //resume the song
            [[STKAudioPlayerHelper sharedInstance] playSong:selectedSong InAlbum:_album AtProgress:[AppData sharedAppData].currentProgress];
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

@end
