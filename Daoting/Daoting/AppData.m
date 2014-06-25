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
static NSString* const SSDataforPlayingPositionQueue = @"playingPositionQueue";
static NSString* const SSDataforDailyCheckinQueue = @"dailyCheckinQueue";


static NSString* const SSDataChecksumKey = @"SSDataChecksumKey";


@implementation AppData


@synthesize playingQueue, purchasedQueue, playingPositionQueue, dailyCheckinQueue;

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeDouble:self.coins forKey: SSDataforCoinsKey];
    [encoder encodeObject:playingQueue forKey:SSDataforPlayingQueue];
    [encoder encodeObject:purchasedQueue forKey:SSDataforPurchasedQueue];
    [encoder encodeObject:playingPositionQueue forKey:SSDataforPlayingPositionQueue];
    [encoder encodeObject:dailyCheckinQueue forKey:SSDataforDailyCheckinQueue];
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
        
        purchasedQueue = [[decoder decodeObjectForKey:SSDataforPurchasedQueue] mutableCopy];
        if (purchasedQueue == nil) {
            purchasedQueue = [[NSMutableDictionary alloc]init];
        }
        
        playingPositionQueue = [[decoder decodeObjectForKey:SSDataforPlayingPositionQueue] mutableCopy];
        if (playingPositionQueue == nil) {
            playingPositionQueue = [[NSMutableDictionary alloc]init];
        }
        
        dailyCheckinQueue = [[decoder decodeObjectForKey:SSDataforDailyCheckinQueue] mutableCopy];
        if (dailyCheckinQueue == nil) {
            dailyCheckinQueue = [[NSMutableDictionary alloc]init];
        }
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


@end
