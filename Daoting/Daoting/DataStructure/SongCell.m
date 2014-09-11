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
    //1 check the song had been purchased or not
    BOOL purchased = [_appData songNumber:song.songNumber ispurchasedwithAlbum:album.shortName];
    
    //2.1 if the song had been purchased
    if (purchased) {
        
        [self startDownload];
    }
    //2.2 if the song had not been purchased
    else{
        
        //2.2.1 if coin is enough, buy it.
        if (_appData.coins >= [song.price intValue]) {
            
            _appData.coins = _appData.coins - [song.price intValue];
            [_appData save];
            [_appData updateiCloud];
            
            [self startDownload];
            
            [_appData addtoPurchasedQueue:song withAlbumShortname:album.shortName];
            
            if ([song.updatedSong isEqualToString:@"YES"]) {
                song.updatedSong = @"NO";
                //[[SongManager sharedManager] writeBacktoPlist:album.shortName];
                self.img_new.hidden = YES;
            }
            
            [_appData save];
            
            //show notification to user
            NSString *notification = [NSString stringWithFormat:@"金币  -%@", song.price];
            SongTableViewController* parentViewController = (SongTableViewController *)[self GetViewController];
            [TSMessage showNotificationInViewController:parentViewController title:notification subtitle:nil type:TSMessageNotificationTypeSuccess];
            
        }
        //2.2.2 cois is not enough
        else
        {
            [TSMessage showNotificationWithTitle:[NSString stringWithFormat:@"现有金币不足，请从商店购买"] type:TSMessageNotificationTypeWarning];
            
            SongTableViewController *parentViewController = (SongTableViewController *)[self GetViewController];
            [parentViewController getTabbarViewController].selectedIndex = 2;
        }
    }
}

- (IBAction)onbtn_pausePressed:(id)sender
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", album.shortName, song.songNumber];
    AFHTTPRequestOperation *operation = [[AFDownloadHelper sharedAFDownloadHelper] searchOperationbyKey:key];
    [operation cancel];
}


- (void)startDownload
{
    //Start download
    [[AFDownloadHelper sharedAFDownloadHelper] downloadSong:song inAlbum:album];
}

- (UIViewController *)GetViewController
{
    Class vcc = [UIViewController class];
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: vcc])
            return (UIViewController *)responder;
    return nil;
}

@end
