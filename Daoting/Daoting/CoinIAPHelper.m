//
//  CoinIAPHelper.m
//  Daoting
//
//  Created by Kevin on 14-5-15.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "CoinIAPHelper.h"

@implementation CoinIAPHelper

+ (CoinIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static CoinIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"500Coins",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end