//
//  AppData.m
//  Daoting
//
//  Created by Kevin on 14-5-26.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "AppData.h"

static NSString* const SSDataforCoinsKey = @"coins";
static NSString* const SSDataforAppExistKey = @"appExist";
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

#pragma mark static methods

+ (instancetype)sharedAppData {
    static AppData *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

+ (instancetype)loadInstance
{
    AppData* appData = nil;
    
    //check if there is decode data
    NSData* decodedData = [NSData dataWithContentsOfFile: [AppData filePath]];
    if (decodedData) {
        //1
        //NSString* checksumOfSavedFile = [KeychainWrapper computeSHA256DigestForData: decodedData];
        //NSString* checksumInKeychain = [KeychainWrapper keychainStringFromMatchingIdentifier: SSDataChecksumKey];
        
        //2
        //if ([checksumOfSavedFile isEqualToString: checksumInKeychain]) {
        appData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        
        //}
        //else
        //{
        //    NSLog(@"Critical Error, checksum is different");
        //    NSLog(@"checksumofSavedFile= %@", checksumOfSavedFile);
        //    NSLog(@"checksumInKeyChain = %@", checksumInKeychain);
        //}
    }
    //There is no decode Data
    else
    {
        appData = [[AppData alloc] init];
    }
    
    return appData;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
        
        //1
        if(iCloudStore) {
            
            //2
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(updateFromiCloud)
                                                         name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                       object:nil];
        }
        
        if (_playingBackProgressQueue == nil) {
            _playingBackProgressQueue = [[NSMutableDictionary alloc]init];
        }
        
        if (_playingPositionQueue == nil) {
            _playingPositionQueue = [[NSMutableDictionary alloc]init];
        }
        
        if (_dailyCheckinQueue == nil) {
            _dailyCheckinQueue = [[NSMutableDictionary alloc]init];
        }
        
        _isAutoPurchase = true;
        _isAutoPlay = false;
    }
    return self;
}

+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"appData"];
    }
    return filePath;
}

-(void)save
{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[AppData filePath] atomically:YES];
    
    NSString* checksum = [KeychainWrapper computeSHA256DigestForData: encodedData];
    if ([KeychainWrapper keychainStringFromMatchingIdentifier: SSDataChecksumKey]) {
        
        [KeychainWrapper updateKeychainValue:checksum forIdentifier:SSDataChecksumKey];
        NSLog(@"KeychainWrapper updateKeychainValue %@", checksum);
    }
    else
    {
        [KeychainWrapper createKeychainValue:checksum forIdentifier:SSDataChecksumKey];
        NSLog(@"createKeychainValue %@", checksum);
    }
}

#pragma mark iCloud Operation

- (void)updateToiCloud
{
    if (iCloudStore) {
    
        //update coins
        long cloudCoins= [iCloudStore doubleForKey: SSDataforCoinsKey];

        if (self.coins != cloudCoins ) {
            [iCloudStore setDouble:self.coins forKey:SSDataforCoinsKey];
        }
        
        //update purchased songs
        NSDictionary *purchasedSongs = [iCloudStore dictionaryForKey:SSDataforPurchasedQueue];
        
        if (self.purchasedQueue.count != purchasedSongs.count) {
            [iCloudStore setDictionary:self.purchasedQueue forKey:SSDataforPurchasedQueue];
        }
        
        [iCloudStore setBool:YES forKey:SSDataforAppExistKey];
        
        //synchronize
        BOOL success = [iCloudStore synchronize];
        if (success) {
            NSLog(@"update icloud succeed");
        }
    }
    else
    {
        NSLog(@"updateiToCloud failed due to iCloud is not enabled");
    }
}

-(void)updateFromiCloud
{
    if (iCloudStore) {
        //load coin from iCloud
        self.coins = [iCloudStore doubleForKey:SSDataforCoinsKey];
        if (self.coins == 0) {
            
            //if App had not been used
            if (![iCloudStore boolForKey:SSDataforAppExistKey]) {
                self.coins = 300;
            }
        }
        
        //load purchase Queue from iCloud
        self.purchasedQueue = [[NSMutableDictionary alloc]initWithDictionary:[iCloudStore dictionaryForKey:SSDataforPurchasedQueue]];
        
        [self save];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: SSDataforCoinsKey object:nil];
        
        NSLog(@"update From iCloud succeed");
    }
    else
    {
        NSLog(@"updateFromiCloud failed due to iCloud is not enabled");
    }
}

-(BOOL)songNumber:(NSString *)songNumber ispurchasedwithAlbum:(NSString*)albumShortname
{
    //Processing for old type
    NSMutableDictionary *purchasedArray = [_purchasedQueue objectForKey:albumShortname];
    if (!([purchasedArray objectForKey:songNumber] == nil)) {
        
        //Modify it to new type
        [_purchasedQueue setValue:songNumber forKey:[NSString stringWithFormat:@"%@_%@", albumShortname, songNumber]];
        
        //Remove old type
        [purchasedArray removeObjectForKey:songNumber];
        
        if (purchasedArray.count == 0) {
            [_purchasedQueue removeObjectForKey:albumShortname];
        }
        
        return YES;
    }
    
    //Processing for new type
    NSString* cloudSongNumber = [_purchasedQueue objectForKey:[NSString stringWithFormat:@"%@_%@", albumShortname, songNumber]];
    if ([songNumber isEqualToString:cloudSongNumber]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)addtoPurchasedQueue:(Song*)song withAlbumShortname:(NSString *)albumShortname
{
    [_purchasedQueue setValue:song.songNumber forKey:[NSString stringWithFormat:@"%@_%@", albumShortname, song.songNumber]];
}

#pragma mark @protocol NSCoding

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

@end
