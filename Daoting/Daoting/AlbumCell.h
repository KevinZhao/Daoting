//
//  AlbumCell.h
//  Daoting
//
//  Created by Kevin on 14-5-15.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel      *lbl_albumTitle;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_albumDescription;
@property (nonatomic, strong) IBOutlet UIImageView  *img_albumImage;

@end
