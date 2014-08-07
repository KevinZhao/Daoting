//
//  DownloadCell.m
//  Daoting
//
//  Created by Kevin on 14/6/5.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "DownloadCell.h"

@implementation DownloadCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onbtn_cancelPressed:(id)sender
{
    NSIndexPath* indexPath = [(UITableView*)self.superview.superview indexPathForCell:self];
    
    AFHTTPRequestOperation *operation = [AFDownloadHelper sharedOperationManager].operationQueue.operations[indexPath.row];

    [operation cancel];
}


@end
