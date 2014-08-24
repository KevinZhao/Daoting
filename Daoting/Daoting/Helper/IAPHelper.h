//
//  IAPHelper.h
//  Daoting
//
//  Created by Kevin on 14-5-15.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

#import "AppData.h"

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@protocol IAPHelperDelegate <NSObject>

/// Raised when an item has started playing
-(void) onLoadedProducts;
-(void) onTransactionFailed;

@end

@interface IAPHelper : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProductsRequest * _productsRequest;
    
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

@property (readwrite, unsafe_unretained) id<IAPHelperDelegate> delegate;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)buyProduct:(SKProduct *)product;

@end