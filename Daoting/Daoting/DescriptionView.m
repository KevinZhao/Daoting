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
    _txt_description.text = _album.longdescription;
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    self.backgroundColor = _appDelegate.defaultBackgroundColor;
    
    self.txt_description.backgroundColor = _appDelegate.defaultBackgroundColor;
}


@end
