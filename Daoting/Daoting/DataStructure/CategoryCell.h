//
//  CategoryCell.h
//  Daoting
//
//  Created by Kevin on 14/9/5.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel      *lbl_categoryTitle;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_categoryDescription;
@property (nonatomic, strong) IBOutlet UIImageView  *img_categoryImage;
@property (nonatomic, strong) IBOutlet UIImageView  *img_categoryNewIndicator;

@end
