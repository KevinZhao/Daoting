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
    
    //1. Album image
    //UIImageView *img_artist = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 64, 64)];
    
    UIImageView *img_artist = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 406)];
    [img_artist setImageWithURL:_album.imageUrl];
    
    img_artist.alpha = 0.2;
    [img_artist setImageToBlur:img_artist.image blurRadius:2 completionBlock:nil];
    
    
    [_scrollView_description addSubview:img_artist];
    
    
    
    /*//2. Download all button
    UIButton *btn_downloadAll = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn_downloadAll setFrame:CGRectMake(220, 54, 70, 30)];
    [btn_downloadAll setTitle:@"全部下载" forState:UIControlStateNormal];
    [_scrollView_description addSubview:btn_downloadAll];
    
    //3. description label
    UILabel* lbl_description = [[UILabel alloc]init];
    
    [lbl_description setNumberOfLines:0];
    lbl_description.lineBreakMode = NSLineBreakByWordWrapping;
    lbl_description.text = _album.longdescription;
    
    UIFont *font =[UIFont fontWithName:lbl_description.font.familyName size:17];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];

    CGSize textSize = [lbl_description.text boundingRectWithSize:CGSizeMake(280, 2000)
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      attributes:dic
                                                         context:nil].size;
    
    [lbl_description setFrame:CGRectMake(20, 90, textSize.width, textSize.height)];
    
    // 4. Resize scroll view
    _scrollView_description.contentSize = CGSizeMake(self.frame.size.width, textSize.height + 90);
    [_scrollView_description addSubview:lbl_description];*/
}


@end
