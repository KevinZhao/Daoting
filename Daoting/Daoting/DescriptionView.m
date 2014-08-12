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
    /*[_lbl_description setNumberOfLines:0];
    _lbl_description.lineBreakMode = NSLineBreakByWordWrapping;
    _lbl_description.text = _album.longdescription;
    
    UIFont *font = [UIFont fontWithName:@"Arial" size:12];
    //设置一个行高上限
    CGSize size = CGSizeMake(320,2000);
    //计算实际frame大小，并将label的frame变成实际大小
    CGSize labelsize = [_album.longdescription sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    [_lbl_description setFrame:CGRectMake(0, 0, labelsize.width, labelsize.height)];*/
    
    ///int descriptionviewheight = labelsize.height + 250;
    //_scrollView_description.contentSize = CGSizeMake(320, descriptionviewheight);
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    self.backgroundColor = _appDelegate.defaultBackgroundColor;
    
    UILabel* lbl_description = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 280, 2500)];
    
    [lbl_description setNumberOfLines:0];
    lbl_description.lineBreakMode = NSLineBreakByWordWrapping;
    lbl_description.text = _album.longdescription;
    
    //UIFont *font =[UIFont fontWithName:@"Arial" size:12];
    //CGSize labelsize = [_album.longdescription sizeWithFont:font constrainedToSize:CGSizeMake(280, 2000) lineBreakMode:NSLineBreakByWordWrapping];
    
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:_album.longdescription];
    
    NSRange range = NSMakeRange(0, attrStr.length);
    NSDictionary *dic = [attrStr attributesAtIndex:0 effectiveRange:&range];
    
    CGSize textSize = [_album.longdescription boundingRectWithSize:CGSizeMake(280, 2000) // 用于计算文本绘制时占据的矩形块
                                                  options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading // 文本绘制时的附加选项
                                               attributes:dic        // 文字的属性
                                                  context:nil].size; // context上下文。包括一些信息，例如如何调整字间距以及缩放。该对象包含的信息将用于文本绘制。该参数可为nil
    
   
    
    [lbl_description setFrame:CGRectMake(20, 0, textSize.width, 1000)];
    
    _scrollView_description.contentSize = CGSizeMake(320, 2000);
    [_scrollView_description addSubview:lbl_description];
    
        //self.txt_description.backgroundColor = _appDelegate.defaultBackgroundColor;
    
    
}

@end
