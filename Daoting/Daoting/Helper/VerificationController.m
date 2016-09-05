#import "VerificationController.h"
#import "AFNetWorking.h"

static VerificationController *singleton;
static const NSString* hostName = @"http://www.zhaoxiangyu.com:8080/";

@implementation VerificationController {
    NSMutableDictionary * _completionHandlers;
}

+ (VerificationController *)sharedInstance
{
	if (singleton == nil)
    {
		singleton = [[VerificationController alloc] init];
	}
	return singleton;
}


- (id)init
{
	self = [super init];
	if (self != nil)
    {
        transactionsReceiptStorageDictionary = [[NSMutableDictionary alloc] init];
        _completionHandlers = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark Receipt Verification

// This method should be called once a transaction gets to the SKPaymentTransactionStatePurchased or SKPaymentTransactionStateRestored state
// Call it with the SKPaymentTransaction.transactionReceipt
- (void)verifyPurchase:(SKPaymentTransaction *)transaction completionHandler:(VerifyCompletionHandler)completionHandler
{
    NSError *error;
    
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    
    NSDictionary *requestContents = @{
                                      @"receipt-data":[receipt base64EncodedStringWithOptions:0],
                                      @"password":ITC_CONTENT_PROVIDER_SHARED_SECRET
                                      };
    
    
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                          options:0
                                                            error:&error];    

    // Send Verification Request to own Server
    NSURL *storeURL = [NSURL URLWithString:@"http://www.zhaoxiangyu.com:8080/itunesReceiptValidator.php"];
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    
    
    // Make a connection to own Server on a background queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   //TODO: Something Wrong here, need to check if the user is valid
                               }
                               else
                               {
                                   NSError *error;
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   if (!jsonResponse)
                                   {
                                       //TODO: Check json Response
                                   }
                               }
                           }];
}

@end


