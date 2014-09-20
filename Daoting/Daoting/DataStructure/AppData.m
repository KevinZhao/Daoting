//
//  AppData.m
//  Daoting
//
//  Created by Kevin on 14-5-26.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "AppData.h"

static NSString* const SSDataforCoinsKey = @"coins";
static NSString* const SSDataforPlayingBackProgressQueue = @"playingBackProgressQueue";
static NSString* const SSDataforPurchasedQueue = @"purchasedQueue";
static NSString* const SSDataforPlayingPositionQueue = @"playingPositionQueue";
static NSString* const SSDataforDailyCheckinQueue = @"dailyCheckinQueue";
static NSString* const SSDataforIsAutoPurchase = @"isAutoPurchase";
static NSString* const SSDataforIsAutoPlay = @"isAutoPlay";
static NSString* const SSDataChecksumKey = @"SSDataChecksumKey";
static NSString* const SSDataCurrentSong = @"SSDataCurrentSong";
static NSString* const SSDataCurrentAlbum = @"SSDataCurrentAlbum";

@implementation AppData

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeDouble:self.coins forKey: SSDataforCoinsKey];
    [encoder encodeObject:_playingBackProgressQueue forKey:SSDataforPlayingBackProgressQueue];
    [encoder encodeObject:_purchasedQueue forKey:SSDataforPurchasedQueue];
    [encoder encodeObject:_playingPositionQueue forKey:SSDataforPlayingPositionQueue];
    [encoder encodeObject:_dailyCheckinQueue forKey:SSDataforDailyCheckinQueue];
    [encoder encodeBool:_isAutoPurchase forKey:SSDataforIsAutoPurchase];
    [encoder encodeBool:_isAutoPlay forKey:SSDataforIsAutoPlay];
    [encoder encodeObject:_currentAlbum forKey:SSDataCurrentAlbum];
    [encoder encodeObject:_currentSong forKey:SSDataCurrentSong];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        _coins = [decoder decodeDoubleForKey:SSDataforCoinsKey];

        _playingBackProgressQueue = [[decoder decodeObjectForKey:SSDataforPlayingBackProgressQueue] mutableCopy];
        _purchasedQueue = [[decoder decodeObjectForKey:SSDataforPurchasedQueue] mutableCopy];
        _playingPositionQueue = [[decoder decodeObjectForKey:SSDataforPlayingPositionQueue] mutableCopy];
        _dailyCheckinQueue = [[decoder decodeObjectForKey:SSDataforDailyCheckinQueue] mutableCopy];
        
        _isAutoPurchase = [decoder decodeBoolForKey:SSDataforIsAutoPurchase];
        _isAutoPlay = [decoder decodeBoolForKey:SSDataforIsAutoPlay];
        
        _currentSong = [decoder decodeObjectForKey:SSDataCurrentSong];
        _currentAlbum = [decoder decodeObjectForKey:SSDataCurrentAlbum];

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
    AppData* appData;
    
    NSData* decodedData = [NSData dataWithContentsOfFile: [AppData filePath]];
    if (decodedData) {
        //1
        NSString* checksumOfSavedFile = [KeychainWrapper computeSHA256DigestForData: decodedData];
        
        //2
        NSString* checksumInKeychain = [KeychainWrapper keychainStringFromMatchingIdentifier: SSDataChecksumKey];

        //3
        if ([checksumOfSavedFile isEqualToString: checksumInKeychain]) {
            appData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        }
        else
        {
            NSLog(@"Critical Error, checksum is different");
            NSLog(@"checksumofSavedFile= %@", checksumOfSavedFile);
            NSLog(@"checksumInKeyChain = %@", checksumInKeychain);
        }
    }else
    {
        appData = [[AppData alloc] init];
        
        NSUbiquitousKeyValueStore *iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
        
        appData.coins = [iCloudStore doubleForKey: SSDataforCoinsKey];
        
        NSLog(@"iCloud coin = %d", appData.coins);
        
        [appData save];
    }
    
    return appData;
}

-(void)save
{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[AppData filePath] atomically:YES];
    
    NSString* checksum = [KeychainWrapper computeSHA256DigestForData: encodedData];
    
    if ([KeychainWrapper keychainStringFromMatchingIdentifier: SSDataChecksumKey]) {
        [KeychainWrapper updateKeychainValue:checksum forIdentifier:SSDataChecksumKey];
    } else {
        [KeychainWrapper createKeychainValue:checksum forIdentifier:SSDataChecksumKey];
    }
}

- (void)updateiCloud
{
    NSUbiquitousKeyValueStore *iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
    
    if (iCloudStore) {
        long cloudCoins= [iCloudStore doubleForKey: SSDataforCoinsKey];
        
        if (self.coins != cloudCoins ) {
            
            [iCloudStore setDouble:self.coins forKey:SSDataforCoinsKey];
            BOOL success = [iCloudStore synchronize];
            
            if (success) {
                NSLog(@"update icloud succeed");
            }
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
        
        if (_playingBackProgressQueue == nil) {
            _playingBackProgressQueue = [[NSMutableDictionary alloc]init];
        }
        
        if (_purchasedQueue == nil) {
            _purchasedQueue = [[NSMutableDictionary alloc]init];
        }
        
        if (_playingPositionQueue == nil) {
            _playingPositionQueue = [[NSMutableDictionary alloc]init];
        }
        
        if (_dailyCheckinQueue == nil) {
            _dailyCheckinQueue = [[NSMutableDictionary alloc]init];
        }
        
        _isAutoPurchase = true;
        _isAutoPlay = true;
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
}

@end
