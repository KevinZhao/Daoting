//
//  AFNetWorkingOperationManagerHelper.m
//  Daoting
//
//  Created by Kevin on 14-5-27.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "AFNetWorkingOperationManagerHelper.h"

@implementation AFNetWorkingOperationManagerHelper

+ (AFHTTPRequestOperationManager *)sharedInstance {
    static dispatch_once_t once;
    static AFHTTPRequestOperationManager * sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [AFHTTPRequestOperationManager manager];
        
    });
    return sharedInstance;
}

+ (AFNetWorkingOperationManagerHelper *)sharedManagerHelper
{
    static dispatch_once_t once;
    static AFNetWorkingOperationManagerHelper * sharedManagerHelper;
    dispatch_once(&once, ^{
        
        sharedManagerHelper = [[AFNetWorkingOperationManagerHelper alloc]init];
        
    });
    return sharedManagerHelper;
    
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _downloadQueue = [[NSMutableDictionary alloc]init];
        
    }
    return self;
}

@end
