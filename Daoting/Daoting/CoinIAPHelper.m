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
                                      @"DSoft.com.Daoting.1000coins",
                                      @"DSoft.com.Daoting.10000coins",
                                      @"DSoft.com.Daoting.2500coins",
                                      @"DSoft.com.Daoting.25000coins",
                                      @"DSoft.com.Daoting.500coins",
                                      nil];
        
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end