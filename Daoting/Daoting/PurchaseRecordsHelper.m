//
//  PurchaseRecordsHelper.m
//  Daoting
//
//  Created by Kevin on 15/1/23.
//  Copyright (c) 2015年 赵 克鸣. All rights reserved.
//

#import "PurchaseRecordsHelper.h"
#import "AFNetWorking.h"
#import "Song.h"
#import "Album.h"

//#ifdef DEBUG
//const NSString* hostName = @"http://localhost/";
//#else
static const NSString* hostName = @"http://www.zhaoxiangyu.com:8080/";
//#endif

@implementation PurchaseRecordsHelper

+ (PurchaseRecordsHelper *)sharedInstance {
    static dispatch_once_t once;
    static PurchaseRecordsHelper * sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [[PurchaseRecordsHelper alloc]init];
        
    });
    return sharedInstance;
}

-(BOOL)addtoPurchasedQueue:(Song*)song withAlbumShortname:(NSString *)albumShortname
{
    _appData = [AppData sharedAppData];
    
    if (_appData.purchasedQueue != nil) {
        [_appData.purchasedQueue setValue:song.songNumber forKey:[NSString stringWithFormat:@"%@_%@", albumShortname, song.songNumber]];
        [_appData save];
        
        if (self.delegate != nil) {
            [self.delegate onPurchaseSucceed:song];
        }
        
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)purchase:(NSString*)songNumber in:(NSString*)albumShortname
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSTimeInterval secondsFor8Hour = 8 * 60 * 60;
    NSDate* date = [[NSDate alloc]initWithTimeIntervalSinceNow:secondsFor8Hour];
    NSString* deviceID = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    
    //parameters
    NSDictionary *parameters = @{@"device_id": deviceID, @"album_shortname": albumShortname, @"song_number":songNumber, @"purchase_date":date};

    //post Url
    NSString* postUrl = [hostName stringByAppendingString:@"addToPurchaseRecords.php"];
    
    [manager POST:postUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)purchaseCoins:(int)coins
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSTimeInterval secondsFor8Hour = 8 * 60 * 60;
    NSDate* date = [[NSDate alloc]initWithTimeIntervalSinceNow:secondsFor8Hour];
    NSString* purchasedCoins = [NSString stringWithFormat:@"%d", coins];
    NSString* deviceID = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    
    //parameters
    NSDictionary *parameters = @{@"device_id": deviceID, @"coins": purchasedCoins, @"purchase_date":date};
    
    //post Url
    NSString* postUrl = [hostName stringByAppendingString:@"addToPurchaseRecords2.php"];
    
    [manager POST:postUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"operation: %@", operation.responseString);
        
        NSLog(@"Error: %@", error);
    }];
}


@end
