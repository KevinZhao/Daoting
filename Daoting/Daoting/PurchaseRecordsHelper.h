//
//  PurchaseRecordsHelper.h
//  Daoting
//
//  Created by Kevin on 15/1/23.
//  Copyright (c) 2015年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PurchaseRecordsHelper : NSObject

+ (PurchaseRecordsHelper *)sharedInstance;
- (void)purchase:(NSString*)songNumber in:(NSString*)albumShortname from:(NSString*)deviceID;

@end
