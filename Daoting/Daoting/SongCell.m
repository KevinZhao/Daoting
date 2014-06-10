//
//  SongCell.m
//  Daoting
//
//  Created by Kevin on 14-5-16.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "SongCell.h"
#import "SongTableViewController.h"


@implementation SongCell

@synthesize song, album;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)onbtn_downloadPressed:(id)sender
{
    //todo: check network status？
    
    //change download button to pause button
    [_btn_downloadOrPause removeTarget:self action:@selector(onbtn_downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_btn_downloadOrPause addTarget:self action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
    //[_btn_downloadOrPause ]
    [_btn_downloadOrPause setBackgroundImage:[UIImage imageNamed:@"downloadProgressButtonPause.png"] forState:UIControlStateNormal];
    
    //Start download
    [[AFNetWorkingOperationManagerHelper sharedManagerHelper] downloadSong:song inAlbum:album];
}

- (IBAction)onbtn_pausePressed:(id)sender
{
    [_btn_downloadOrPause removeTarget:self action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
    [_btn_downloadOrPause addTarget:self action:@selector(onbtn_downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [_btn_downloadOrPause setBackgroundImage:[UIImage imageNamed:@"downloadButton.png"] forState:UIControlStateNormal];
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", album.shortName, song.songNumber];
    AFHTTPRequestOperation *operation = [[AFNetWorkingOperationManagerHelper sharedManagerHelper] searchOperationByKey:key];
    
    [operation cancel];
}
@end
