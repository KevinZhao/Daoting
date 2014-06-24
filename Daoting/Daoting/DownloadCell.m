//
//  DownloadCell.m
//  Daoting
//
//  Created by Kevin on 14/6/5.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "DownloadCell.h"

@implementation DownloadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onbtn_cancelPressed:(id)sender
{
    NSIndexPath* indexPath = [(UITableView*)self.superview.superview indexPathForCell:self];
    
    NSMutableArray *downloadQueue = [AFNetWorkingOperationManagerHelper sharedManagerHelper].downloadQueue;
    AFHTTPRequestOperation *operation =downloadQueue[indexPath.row];

    [operation cancel];
    
    self.btn_cancel.titleLabel.text = @"已取消";
}


@end
