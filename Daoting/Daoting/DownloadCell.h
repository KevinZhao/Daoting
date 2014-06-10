//
//  DownloadCell.h
//  Daoting
//
//  Created by Kevin on 14/6/5.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel          *lbl_downloadDescription;
@property (nonatomic, strong) IBOutlet UIProgressView   *pv_downloadProgress;

@end
