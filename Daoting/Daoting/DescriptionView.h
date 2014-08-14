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
#import "AppDelegate.h"

@interface DescriptionView : UIView
{
    AppDelegate *_appDelegate;
}

@property (nonatomic, strong) IBOutlet UIScrollView   *scrollView_description;
@property (nonatomic, retain) IBOutlet Album        *album;

@end
