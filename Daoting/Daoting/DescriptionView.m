//
//  DescriptionView.m
//  Daoting
//
//  Created by ZHAOKE MING on 14-7-31.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "DescriptionView.h"

@implementation DescriptionView


- (void)didMoveToWindow
{
    [_img_artist setImageWithURL:_album.imageUrl];
    _lbl_description.text = _album.description;
}




@end
