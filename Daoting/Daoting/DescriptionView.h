//
//  DescriptionView.h
//  Daoting
//
//  Created by ZHAOKE MING on 14-7-31.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "UIImageView+AFNetworking.h"

@interface DescriptionView : UIView

@property (nonatomic, strong) IBOutlet UILabel      *lbl_description;
@property (nonatomic, strong) IBOutlet UIButton     *btn_downloadAll;
@property (nonatomic, strong) IBOutlet UIImageView  *img_artist;

@property (nonatomic, retain) IBOutlet Album        *album;

@end
