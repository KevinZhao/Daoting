//
//  SongTableViewCell.h
//  Daoting
//
//  Created by Kevin on 14-5-16.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel      *lbl_songNumber;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_songTitle;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_playbackDuration;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_songStatus;
@property (nonatomic, strong) IBOutlet UIButton     *bt_downloadOrPause;
@property (nonatomic, strong) IBOutlet UIImageView  *img_playingStatus;
//@property (nonatomic, strong) IBOutlet DACircularProgressView *cirProgView_downloadProgress;

@end
