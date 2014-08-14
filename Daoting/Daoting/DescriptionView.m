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
    _appDelegate = [[UIApplication sharedApplication] delegate];
    self.backgroundColor = _appDelegate.defaultBackgroundColor;
    
    //1. Album Image
    UIImageView *img_artist = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 64, 64)];
    [img_artist setImageWithURL:_album.imageUrl];
    [_scrollView_description addSubview:img_artist];
    
    //2. Download All Button
    UIButton *btn_downloadAll = [[UIButton alloc]initWithFrame:CGRectMake(220, 54, 70, 30)];
    btn_downloadAll.titleLabel.text = @"全部下载";
    [_scrollView_description addSubview:btn_downloadAll];
    
    //3. Description Label
    UILabel* lbl_description = [[UILabel alloc]init];
    
    [lbl_description setNumberOfLines:0];
    lbl_description.lineBreakMode = NSLineBreakByWordWrapping;
    lbl_description.text = _album.longdescription;
    
    UIFont *font =[UIFont fontWithName:lbl_description.font.familyName size:17];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];

    
    CGSize textSize = [lbl_description.text boundingRectWithSize:CGSizeMake(280, 2000) // 用于计算文本绘制时占据的矩形块
                                                         options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading // 文本绘制时的附加选项
                                                      attributes:dic        // 文字的属性
                                                         context:nil].size; // context上下文。包括一些信息，例如如何调整字间距以及缩放。该对象包含的信息将用于文本绘制。该参数可为nil
    
    
    [lbl_description setFrame:CGRectMake(20, 90, textSize.width, textSize.height)];
    
    _scrollView_description.contentSize = CGSizeMake(self.frame.size.width, textSize.height + 90);
    [_scrollView_description addSubview:lbl_description];
    
    //self.txt_description.backgroundColor = _appDelegate.defaultBackgroundColor;
}


@end
