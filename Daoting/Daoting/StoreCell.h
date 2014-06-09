//
//  StoreCell.h
//  Daoting
//
//  Created by Kevin on 14/6/8.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel      *lbl_STKProductTitle;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_STKProductPrice;
@property (nonatomic, strong) IBOutlet UIButton     *bt_Buy;

@end
