//
//  AlbumTableViewController.h
//  Daoting
//
//  Created by Kevin on 14-5-12.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumTableViewController : UITableViewController
{
    //NSArray             *_products;
    NSMutableArray      *_albums;
}

@property (nonatomic, retain) NSMutableDictionary *songsDictionary;

@end
