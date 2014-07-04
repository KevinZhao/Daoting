//
//  ClearCacheCell.h
//  Daoting
//
//  Created by Kevin on 14/7/4.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClearCacheCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *lbl_albumName;
@property (nonatomic, strong) IBOutlet UILabel *lbl_size;
@property (nonatomic, strong) IBOutlet UIButton *btn_clear;

@end
