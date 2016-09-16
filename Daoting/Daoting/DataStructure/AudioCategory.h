//
//  AudioCategory.h
//  Daoting
//
//  Created by Kevin on 14/9/5.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioCategory : NSObject<NSCoding>

@property (nonatomic, retain) NSString  *shortName;
@property (nonatomic, retain) NSString  *title;
@property (nonatomic, retain) NSURL     *imageUrl;
@property (nonatomic, retain) NSURL     *albumListUrl;
@property (nonatomic, retain) NSString  *description;
@property (nonatomic, retain) NSString  *updatedCategory;

@property (nonatomic, retain) NSMutableArray *albumArray;

@end
