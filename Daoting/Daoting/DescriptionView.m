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
    
    //[_btn_downloadAll setTitleColor:_appDelegate.defaultColor_dark forState:UIControlStateNormal];
    //[_btn_downloadAll setTitleColor:_appDelegate.defaultColor_light forState:UIControlStateSelected];
    
    //[_btn_downloadAll.layer setMasksToBounds:YES];
    //[_btn_downloadAll.layer setCornerRadius:8.0];
    //[_btn_downloadAll.layer setBorderWidth:1.0];
    //[_btn_downloadAll.layer setBorderColor:_appDelegate.defaultColor_dark.CGColor];
}

@end
