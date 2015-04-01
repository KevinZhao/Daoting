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
    _appData        = [AppData sharedAppData];
    
    if (_appData.purchasedQueue != nil) {
        [_appData.purchasedQueue setValue:song.songNumber forKey:[NSString stringWithFormat:@"%@_%@", albumShortname, song.songNumber]];
        [_appData save];
        
        [self.delegate onPurchaseSucceed:song];
        
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)purchase:(NSString*)songNumber in:(NSString*)albumShortname from:(NSString*)deviceID
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *parameters = @{@"device_id": deviceID, @"album_shortname": albumShortname, @"song_number":songNumber};
    [manager POST:@"http://182.254.148.156:8080/addToPurchaseRecords.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end