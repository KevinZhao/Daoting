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
        
    }
    return self;
}

- (void)awakeFromNib
{
    _appData = [AppData sharedAppData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)onbtn_downloadPressed:(id)sender
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", album.shortName, song.songNumber];
    
    //1 check the song had been purchased or not
    BOOL purchased = [[_appData.purchasedQueue objectForKey:key] isEqualToString:@"Yes"];
    
    //2.1 if the song had been purchased
    if (purchased) {
        
        [self startDownload];
    }
    //2.2 if the song had not been purchased
    else{
        
        //2.2.1 if coin is enough, buy it.
        if (_appData.coins >= [song.price intValue]) {
            
            _appData.coins = _appData.coins - [song.price intValue];
            
            [self startDownload];
            
            [_appData.purchasedQueue setObject:@"Yes" forKey:[NSString stringWithFormat:@"%@_%@", album.shortName, song.songNumber]];
            
            [_appData save];
            
            //todo: if ios version = 7
            //NSString *notification = [NSString stringWithFormat:@"金币  -%@", song.price];
            //[(SongTableViewController*)self.  showNotification:notification];
        }
        //2.2.2 cois is not enough
        else
        {
            //todo notify user and show store view
        }
    
    }
}

- (void)startDownload
{
    //change download button to pause button
    [_btn_downloadOrPause removeTarget:self action:@selector(onbtn_downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_btn_downloadOrPause addTarget:self action:@selector(onbtn_pausePressed:) forControlEvents:UIControlEventTouchUpInside];
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
