//
//  CategoryManager.h
//  Daoting
//
//  Created by Kevin on 14/9/1.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioCategory.h"

@interface CategoryManager : NSObject
{
    NSMutableArray      *_categoryArray;
}

@property (nonatomic, retain)  NSMutableArray      *categoryArray;


+ (CategoryManager *)sharedManager;

- (AudioCategory *)searchAudioCategoryByShortName:(NSString*) shortName;



@end
