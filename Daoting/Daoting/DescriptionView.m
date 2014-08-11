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
    [_lbl_description setNumberOfLines:0];
    _lbl_description.lineBreakMode = NSLineBreakByWordWrapping;
    _lbl_description.text = _album.longdescription;
    
    UIFont *font = [UIFont fontWithName:@"Arial" size:12];
    //设置一个行高上限
    CGSize size = CGSizeMake(320,2000);
    //计算实际frame大小，并将label的frame变成实际大小
    CGSize labelsize = [_album.longdescription sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    [_lbl_description setFrame:CGRectMake(0, 0, labelsize.width, labelsize.height)];
    
    //[self setFrame:CGRectMake(0, 0, 320, (labelsize.height + 250))];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    self.backgroundColor = _appDelegate.defaultBackgroundColor;
    
    //self.txt_description.backgroundColor = _appDelegate.defaultBackgroundColor;
}

@end
