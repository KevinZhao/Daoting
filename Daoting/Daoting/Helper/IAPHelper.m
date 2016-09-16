//
//  IAPHelper.m
//  Daoting
//
//  Created by Kevin on 14-5-15.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "IAPHelper.h"
#import "VerificationController.h"

NSString *const kSubscriptionExpirationDateKey = @"ExpirationDate";

@implementation IAPHelper

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

-(int)daysRemainingOnSubscription {
    
    NSDate * expiryDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
    
    NSDateFormatter *dateformatter = [NSDateFormatter new];
    [dateformatter setDateFormat:@"dd MM yyyy"];
    NSTimeInterval timeInt = [[dateformatter dateFromString:[dateformatter stringFromDate:expiryDate]] timeIntervalSinceDate: [dateformatter dateFromString:[dateformatter stringFromDate:[NSDate date]]]]; //Is this too complex and messy?
    int days = timeInt / 60 / 60 / 24;
    
    if (days >= 0) {
        return days;
    } else {
        return 0;
    }
}
-(NSString *)getExpirationDateString {
    if ([self daysRemainingOnSubscription] > 0) {
        NSDate *today = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        return [NSString stringWithFormat:@"Subscribed! \nExpires: %@ (%i Days)",[dateFormat stringFromDate:today],[self daysRemainingOnSubscription]];
    } else {
        return @"Not Subscribed";
    }
}

-(NSDate *)getExpirationDateForMonths:(int)months {
    
    NSDate *originDate;
    
    if ([self daysRemainingOnSubscription] > 0) {
        originDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
    } else {
        originDate = [NSDate date];
    }
	NSDateComponents *dateComp = [[NSDateComponents alloc] init];
	[dateComp setMonth:months];
	[dateComp setDay:1]; //an extra days grace because I am nice...
	return [[NSCalendar currentCalendar] dateByAddingComponents:dateComp toDate:originDate options:0];
}

-(void)purchaseSubscriptionWithMonths:(int)months {
    
    /*PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    
    [query getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject *object, NSError *error) {
        
        NSDate * serverDate = [[object objectForKey:@"ExpirationDate"] lastObject];
        NSDate * localDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
        
        if ([serverDate compare:localDate] == NSOrderedDescending) { //if server date is more recent, update local date
            [[NSUserDefaults standardUserDefaults] setObject:serverDate forKey:@"ExpirationDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSDate * expiryDate = [self getExpiryDateForMonths:months];
        
        [object addObject:expiryDate forKey:@"ExpirationDate"];
        [object saveInBackground];
        
        [[NSUserDefaults standardUserDefaults] setObject:expiryDate forKey:@"ExpirationDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"Subscription Complete!");
    }];*/
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}


- (void)buyProduct:(SKProduct *)product {
    
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)validateReceiptForTransaction:(SKPaymentTransaction *)transaction {
    VerificationController * verifier = [VerificationController sharedInstance];
    [verifier verifyPurchase:transaction completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"Successfully verified receipt!");
            [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
        } else {
            NSLog(@"Failed to validate receipt.");
            [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        }
    }];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@" enter updatedTransactions");
    
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
        
        [self.delegate onLoadedProducts];
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [self validateReceiptForTransaction:transaction];
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    
    [self validateReceiptForTransaction:transaction];
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [self.delegate onTransactionFailed];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end
