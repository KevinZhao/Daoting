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
static NSString* const SSDataforFirstPurchaseKey = @"purchaseTimes1";
static NSString* const SSDataforPlayingBackProgressQueue = @"playingBackProgressQueue";
static NSString* const SSDataforPurchasedQueue = @"purchasedQueue";
static NSString* const SSDataforPlayingPositionQueue = @"playingPositionQueue";
static NSString* const SSDataforDailyCheckinQueue = @"dailyCheckinQueue";
static NSString* const SSDataforIsAutoPurchase = @"isAutoPurchase";
static NSString* const SSDataforIsAutoPlay = @"isAutoPlay";
static NSString* const SSDataChecksumKey = @"SSDataChecksumKey";
static NSString* const SSDataCurrentSong = @"SSDataCurrentSong";
static NSString* const SSDataCurrentAlbum = @"SSDataCurrentAlbum";


static NSString* const SSData_WX_OpenId = @"WX_OpenId";
static NSString* const SSData_WX_NickName = @"NickName";
static NSString* const SSData_WX_HeadImgUrl = @"WX_HeadImgUrl";

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
    
    NSURL* url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"appData"];
    NSError *err;
    
    //check if there is decode data
    NSData* decodedData = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&err];
    
    if (err) {
        //NSLog(err);
    }
    
    if (decodedData) {
        
        appData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];

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
        
        if (_purchasedQueue == nil) {
            _purchasedQueue = [[NSMutableDictionary alloc]init];
        }
        
        if (_dailyCheckinQueue == nil) {
            _dailyCheckinQueue = [[NSMutableDictionary alloc]init];
        }
        
        _isAutoPurchase = true;
        _isAutoPlay = false;
        _purchaseTimes = 0;
        
        //if App had not been used
        if (![iCloudStore boolForKey:SSDataforAppExistKey]) {
            self.coins = 300;
        }
    }
    return self;
}

//todo bug is here
-(NSURL*)filePath
{
    NSURL* filePath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    filePath = [filePath URLByAppendingPathComponent:@"appData"];
        
    return filePath;
}

-(void)save
{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject:self];
    [encodedData writeToURL:[self filePath] atomically:YES];
}

#pragma mark iCloud Operation

- (void)saveToiCloud
{
    if (iCloudStore) {
    
        //1. update coins
        long cloudCoins= [iCloudStore doubleForKey: SSDataforCoinsKey];
        
        if (self.coins != cloudCoins ) {
            [iCloudStore setDouble:self.coins forKey:SSDataforCoinsKey];
        }
        
        //2. update purchased songs
        NSDictionary *purchasedSongs = [iCloudStore dictionaryForKey:SSDataforPurchasedQueue];
        
        if (self.purchasedQueue.count >= purchasedSongs.count) {
            [iCloudStore setDictionary:self.purchasedQueue forKey:SSDataforPurchasedQueue];
        }
        
        //3. Mark this app had initiated
        [iCloudStore setBool:YES forKey:SSDataforAppExistKey];
        
        //4. update Purchase times to iCloud
        [iCloudStore setLongLong: self.purchaseTimes forKey:SSDataforFirstPurchaseKey];
        
        //synchronize
        bool success = [iCloudStore synchronize];
        if (success) {
            //NSLog(@"update icloud succeed for other");
        }
    }
    else
    {
        //NSLog(@"updateiToCloud failed due to iCloud is not enabled");
    }
}

-(void)updateFromiCloud
{
    if (iCloudStore) {
        //1. load coin from iCloud
        self.coins = [iCloudStore doubleForKey:SSDataforCoinsKey];
        if (self.coins == 0) {
            
            //if App had not been used
            if (![iCloudStore boolForKey:SSDataforAppExistKey]) {
                self.coins = 300;
            }
        }
        
        //2. load purchase Queue from iCloud
        self.purchasedQueue = [[NSMutableDictionary alloc]initWithDictionary:[iCloudStore dictionaryForKey:SSDataforPurchasedQueue]];
        
        //4. load purchase time
        self.purchaseTimes = (NSInteger)[iCloudStore longLongForKey:SSDataforFirstPurchaseKey];
        
        [self save];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: SSDataforCoinsKey object:nil];
        
        //NSLog(@"update From iCloud succeed");
    }
    else
    {
        //NSLog(@"updateFromiCloud failed due to iCloud is not enabled");
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
    
    [encoder encodeInteger:_purchaseTimes forKey:SSDataforFirstPurchaseKey];
    
    [encoder encodeObject:_WX_OpenId forKey:SSData_WX_OpenId];
    [encoder encodeObject:_WX_NickName forKey:SSData_WX_NickName];
    [encoder encodeObject:_WX_HeadImgUrl forKey:SSData_WX_HeadImgUrl];

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
        _purchaseTimes = [decoder decodeIntegerForKey:SSDataforFirstPurchaseKey];
        
        _currentSong = [decoder decodeObjectForKey:SSDataCurrentSong];
        _currentAlbum = [decoder decodeObjectForKey:SSDataCurrentAlbum];
        
        _WX_OpenId = [decoder decodeObjectForKey:SSData_WX_OpenId];
        _WX_NickName = [decoder decodeObjectForKey:SSData_WX_NickName];
        _WX_HeadImgUrl = [decoder decodeObjectForKey:SSData_WX_HeadImgUrl];
        
    }
    return self;
}

#pragma mark Test purpose only

-(void) cleariCloudData
{
    [iCloudStore removeObjectForKey:SSDataforCoinsKey];
    [iCloudStore removeObjectForKey:SSDataforPurchasedQueue];
    [iCloudStore removeObjectForKey:SSDataforAppExistKey];
    [iCloudStore removeObjectForKey:SSDataforFirstPurchaseKey];
    
    [iCloudStore synchronize];
        
    self.coins = 0;
    self.currentAlbum = nil;
    self.currentSong = nil;
    self.playingBackProgressQueue = nil;
    self.playingPositionQueue = nil;
    self.purchasedQueue = nil;
    self.dailyCheckinQueue = nil;
    
    self.purchaseTimes = 0;
    self.isAutoPurchase = NO;
    self.isAutoPlay = NO;
    
    [self save];
}


@end
