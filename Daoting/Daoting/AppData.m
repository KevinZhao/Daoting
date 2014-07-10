//
//  AppData.m
//  Daoting
//
//  Created by Kevin on 14-5-26.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "AppData.h"

static NSString* const SSDataforCoinsKey = @"coins";
static NSString* const SSDataforPlayingQueue = @"playingQueue";
static NSString* const SSDataforPurchasedQueue = @"purchasedQueue";
static NSString* const SSDataforPlayingProgressQueue = @"playingProgressQueue";
static NSString* const SSDataforDailyCheckinQueue = @"dailyCheckinQueue";
static NSString* const SSDataforIsAutoPurchase = @"isAutoPurchase";


static NSString* const SSDataChecksumKey = @"SSDataChecksumKey";


@implementation AppData


@synthesize playingQueue, playingProgressQueue, dailyCheckinQueue;

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeDouble:self.coins forKey: SSDataforCoinsKey];
    [encoder encodeObject:playingQueue forKey:SSDataforPlayingQueue];
    [encoder encodeObject:_purchasedQueue forKey:SSDataforPurchasedQueue];
    [encoder encodeObject:playingProgressQueue forKey:SSDataforPlayingProgressQueue];
    [encoder encodeObject:dailyCheckinQueue forKey:SSDataforDailyCheckinQueue];
    [encoder encodeBool:_isAutoPurchase forKey:SSDataforIsAutoPurchase];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        _coins = [decoder decodeDoubleForKey:SSDataforCoinsKey];

        playingQueue = [[decoder decodeObjectForKey:SSDataforPlayingQueue] mutableCopy];
        if (playingQueue == nil) {
            playingQueue = [[NSMutableDictionary alloc]init];
        }
        
        _purchasedQueue = [[decoder decodeObjectForKey:SSDataforPurchasedQueue] mutableCopy];
        if (_purchasedQueue == nil) {
            _purchasedQueue = [[NSMutableDictionary alloc]init];
        }
        
        playingProgressQueue = [[decoder decodeObjectForKey:SSDataforPlayingProgressQueue] mutableCopy];
        if (playingProgressQueue == nil) {
            playingProgressQueue = [[NSMutableDictionary alloc]init];
        }
        
        dailyCheckinQueue = [[decoder decodeObjectForKey:SSDataforDailyCheckinQueue] mutableCopy];
        if (dailyCheckinQueue == nil) {
            dailyCheckinQueue = [[NSMutableDictionary alloc]init];
        }
        
        _isAutoPurchase = [decoder decodeBoolForKey:SSDataforIsAutoPurchase];

    }
    return self;
}


+ (instancetype)sharedAppData {
    static AppData *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}


+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"appData"];
    }
    return filePath;
}

+ (instancetype)loadInstance
{
    NSData* decodedData = [NSData dataWithContentsOfFile: [AppData filePath]];
    if (decodedData) {
        //1
        NSString* checksumOfSavedFile = [KeychainWrapper computeSHA256DigestForData: decodedData];
        
        //2
        NSString* checksumInKeychain = [KeychainWrapper keychainStringFromMatchingIdentifier: SSDataChecksumKey];

        //3
        if ([checksumOfSavedFile isEqualToString: checksumInKeychain]) {
            AppData* appData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
            
            return appData;
        }
    }
    
    return [[AppData alloc] init];
}

-(void)save
{
    //iCloud related
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[AppData filePath] atomically:YES];
    
    NSString* checksum = [KeychainWrapper computeSHA256DigestForData: encodedData];
    if ([KeychainWrapper keychainStringFromMatchingIdentifier: SSDataChecksumKey]) {
        [KeychainWrapper updateKeychainValue:checksum forIdentifier:SSDataChecksumKey];
    } else {
        [KeychainWrapper createKeychainValue:checksum forIdentifier:SSDataChecksumKey];
    }
    
    if([NSUbiquitousKeyValueStore defaultStore]) {
        [self updateiCloud];
    }
}

-(void)updateiCloud
{
    NSUbiquitousKeyValueStore *iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
    long cloudCoins= [iCloudStore doubleForKey: SSDataforCoinsKey];
    
    if (self.coins > cloudCoins ) {
        [iCloudStore setDouble:self.coins forKey:SSDataforCoinsKey];
        BOOL success = [iCloudStore synchronize];
        
        if (success) {
            NSLog(@"update icloud succeed");
        }
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //1
        if([NSUbiquitousKeyValueStore defaultStore]) {
            
            //2
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(updateFromiCloud:)
                                                         name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                       object:nil];
        }
        
        _isAutoPurchase = true;
    }
    return self;
}

-(void)updateFromiCloud:(NSNotification*) notificationObject
{
    NSUbiquitousKeyValueStore *iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
    long cloudCoins = [iCloudStore doubleForKey:SSDataforCoinsKey];
    self.coins = MAX(cloudCoins, self.coins);
    
    [self save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: SSDataforCoinsKey object:nil];
}

-(BOOL)songNumber:(NSString *)songNumber ispurchasedwithAlbum:(NSString*)albumShortname
{
    BOOL result = NO;
    
    NSMutableDictionary *purchasedArray = [_purchasedQueue objectForKey:albumShortname];
    
    if (!([purchasedArray objectForKey:songNumber] == nil)) {
        result = YES;
    }
    
    return result;
}

-(void)addtoPurchasedQueue:(Song*)song withAlbumShortname:(NSString *)albumShortname
{
    NSMutableDictionary *purchasedArray = [_purchasedQueue objectForKey:albumShortname];
    
    if (purchasedArray == nil) {
        purchasedArray = [[NSMutableDictionary alloc]init];
    }
    
    [purchasedArray setValue:song forKey:song.songNumber];
    
    [_purchasedQueue setValue:purchasedArray forKey:albumShortname];
    
    [self save];
}

@end
