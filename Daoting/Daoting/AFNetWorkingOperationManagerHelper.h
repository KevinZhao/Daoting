//
//  AFNetWorkingOperationManagerHelper.h
//  Daoting
//
//  Created by Kevin on 14-5-27.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetWorking.h"

@interface AFNetWorkingOperationManagerHelper : NSObject
{
    
}

@property (nonatomic, retain) NSMutableDictionary   *downloadQueue;

+ (AFHTTPRequestOperationManager *)sharedInstance;
+ (AFNetWorkingOperationManagerHelper *)sharedManagerHelper;



@end
