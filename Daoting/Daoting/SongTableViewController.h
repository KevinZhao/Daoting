//
//  SongTableViewController.h
//  Daoting
//
//  Created by Kevin on 14-5-12.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

#import "Album.h"
#import "Song.h"
#import "SongCell.h"
#import "AFNetworking.h"
#import "STKAudioPlayer.h"
#import "SampleQueueId.h"
#import "AppData.h"
#import "AppDelegate.h"
#import "STKAudioPlayerHelper.h"
#import <ShareSDK/ShareSDK.h>
#import "SongManager.h"
#import "TSMessageView.h"
#import "UIImageView+AFNetworking.h"

@interface SongTableViewController : UIViewController<UIScrollViewDelegate, UITableViewDataSource,
    UITableViewDelegate, STKAudioPlayerHelperDelegate, SongManagerDelegate>
{
    NSMutableArray                      *_songs;
    UITableView                         *_tableview;
    Album                               *_album;
    STKAudioPlayer                      *_audioPlayer;
    NSTimer                             *_timer;
    AppData                             *_appData;
    STKAudioPlayerHelper                *_playerHelper;
    SongManager                         *_songManager;
    AppDelegate                         *_appDelegate;
    UIView                              *_descriptionView;
    
    int scrollViewHeight;
    int scrollViewWidth;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) IBOutlet UILabel *lbl_progressMaxValue;
@property (nonatomic, retain) IBOutlet UILabel *lbl_progressCurrentValue;
@property (nonatomic, retain) IBOutlet UIButton *btn_playAndPause;
@property (nonatomic, retain) IBOutlet UIButton *btn_previous;
@property (nonatomic, retain) IBOutlet UIButton *btn_next;
@property (nonatomic, retain) IBOutlet UIButton *btn_share;
@property (nonatomic, retain) IBOutlet UIButton *btn_downloadAll;
@property (nonatomic, retain) IBOutlet UISlider *slider;
@property (nonatomic, retain) IBOutlet UIImageView *img_PlayBar;

- (IBAction)onbtn_playAndPausePressed:(id)sender;
- (IBAction)onbtn_nextPressed:(id)sender;
- (IBAction)onbtn_previousPressed:(id)sender;
- (IBAction)onsliderValueChanged:(id)sender;
- (IBAction)onpageChanged:(id)sender;
- (void)setDetailItem:(Album *)album;
- (void)showNotification:(NSString *)notification;

//this is ugly, need to revisit next version
- (UITabBarController *)getTabbarViewController;


@end
