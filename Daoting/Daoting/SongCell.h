//
//  SongCell.h
//  Daoting
//
//  Created by Kevin on 14-5-16.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Song.h"
#import "Album.h"
#import "AFNetworking.h"
#import "AFNetWorkingOperationManagerHelper.h"



@interface SongCell : UITableViewCell
{
}

@property (nonatomic, strong) IBOutlet UILabel      *lbl_songNumber;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_songTitle;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_songDuration;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_songStatus;
@property (nonatomic, strong) IBOutlet UIButton     *btn_downloadOrPause;
@property (nonatomic, strong) IBOutlet UIImageView  *img_playingStatus;

@property (nonatomic, retain) Song                  *song;
@property (nonatomic, retain) Album                 *album;

//@property (nonatomic, strong) IBOutlet DACircularProgressView *cirProgView_downloadProgress;

- (IBAction)onbtn_downloadPressed:(id)sender;

@end
