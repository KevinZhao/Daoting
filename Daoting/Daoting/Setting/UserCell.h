//
//  UserCell.h
//  Daoting
//
//  Created by Kevin on 15/7/1.
//  Copyright (c) 2015年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView  *img_User;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_UserName;

@property (nonatomic, retain) IBOutlet UILabel      *lbl_coins;

@end
