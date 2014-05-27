//
//  AppData.h
//  Daoting
//
//  Created by Kevin on 14-5-26.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeychainWrapper.h"

@interface AppData : NSObject <NSCoding>
{
    
}

@property (assign, nonatomic) double coins;
@property (retain, nonatomic) NSMutableArray *purchasedSongs;

+(instancetype)sharedAppData;
+(NSString*)filePath;

-(void)save;

@end
