//
//  PurchaseRecordsHelper.h
//  Daoting
//
//  Created by Kevin on 15/1/23.
//  Copyright (c) 2015年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppData.h"

@protocol PurchaseRecordsHelperDelegate <NSObject>

-(void) onPurchaseSucceed:(Song*) song;

@end

@interface PurchaseRecordsHelper : NSObject
{
    AppData     *_appData;
}

@property (readwrite, unsafe_unretained) id<PurchaseRecordsHelperDelegate> delegate;

+ (PurchaseRecordsHelper *)sharedInstance;
- (void)purchase:(NSString*)songNumber in:(NSString*)albumShortname;
- (void)purchaseCoins:(int)coins;
-(BOOL)addtoPurchasedQueue:(Song*)song withAlbumShortname:(NSString *)albumShortname;

@end
