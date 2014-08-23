//
//  SongManager.m
//  Daoting
//
//  Created by Kevin on 14/7/16.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "SongManager.h"

@implementation SongManager

+ (SongManager *)sharedManager {
    static dispatch_once_t once;
    static SongManager * sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [[SongManager alloc]init];
        
    });
    return sharedInstance;
}

- (SongManager *)init
{
    self = [super init];
    
    _songArrayDictionaryByAlbumName = [[NSMutableDictionary alloc]init];
    
    return self;
}

- (void)initializeSongs:(NSString *)albumShortName
{
    NSMutableArray *_songs = [[NSMutableArray alloc]init];
    
    NSString *DocumentDirectoryPath =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *plistPath =
    [DocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_SongList.plist", albumShortName]];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    for (int i = 1; i<= dictionary.count; i++)
    {
        NSDictionary *SongDic = [dictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        
        Song *song = [[Song alloc]init];
        
        song.songNumber = [NSString stringWithFormat:@"%d", i];
        song.title      = [SongDic objectForKey:@"Title"];
        song.duration   = [SongDic objectForKey:@"Duration"];
        song.Url        = [[NSURL alloc] initWithString:[SongDic objectForKey:@"Url"]];
        song.filePath   = [[NSURL alloc] initWithString:[SongDic objectForKey:@"FilePath"]];
        song.price      = [SongDic objectForKey:@"Price"];
        song.updatedSong = [SongDic objectForKey:@"UpdatedSong"];
        
        [_songs addObject:song];
    }
    
    [_songArrayDictionaryByAlbumName setValue:_songs forKey:albumShortName];
}

- (void)updateSongs:(NSString *)albumShortName
{
    Album *album = [[AlbumManager sharedManager] searchAlbumByShortName:albumShortName];
    
    //1. Check if plist is in document directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:@"/"];
    plistPath = [plistPath stringByAppendingString:albumShortName];
    plistPath = [plistPath stringByAppendingString:@"_SongList.plist"];
    
    //2. Download plist from cloud storage
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:album.plistUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
     
    NSString *path = NSTemporaryDirectory();
    NSString *fileName = @"PlayList.plist";
    NSString *filePath = [path stringByAppendingString:fileName];
    
    [fileManager removeItemAtPath:filePath error:nil];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    [operation start];
    
    //Download complete block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //Compare
         NSMutableDictionary *newPlist_dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
         NSMutableDictionary *oldPlist_dictionary = [[NSMutableDictionary alloc] init];
         
         if ([fileManager fileExistsAtPath:plistPath])
         {
             oldPlist_dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
         }
         
         NSInteger oldCount = oldPlist_dictionary.count;
         NSInteger newCount = newPlist_dictionary.count;
         
         //there is new song in the plist
         if (newCount != oldCount)
         {
             [[AlbumManager sharedManager] foundNewSonginAlbum:album];
             
             //Copy items in new Plist to old Plist
             for (NSInteger i = 1; i <= newCount; i++) {
                 NSDictionary *newSong = [newPlist_dictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
                 
                 //Check if the Song is a new Song
                 if ([self searchSong:newSong InOldSongs:oldPlist_dictionary]) {
                     [newSong setValue:@"NO" forKey:@"UpdatedSong"];
                 }
                 else
                 {
                     [newSong setValue:@"YES" forKey:@"UpdatedSong"];
                 }
                  
                 //Copy newAlbum to oldPlist
                 [newPlist_dictionary setValue:newSong forKey:[NSString stringWithFormat:@"%d", i]];
             }
             
             [newPlist_dictionary writeToFile:plistPath atomically:NO];
             
             //re-initialize songs and update table view
             [self initializeSongs:albumShortName];
             
             //call back, ask song table view to reload
             if (self.delegate != nil) {
                 [self.delegate onSongUpdated];
             }
         }
     }
     //Download Failed
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //try to download again
         NSLog(@"error%@", error.domain);
     }];
}

- (void)loadSongs:(NSString*)albumShortName
{
    //1. Check if there is a playlist in document directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPathinDocumentDirectory = [bundleDocumentDirectoryPath stringByAppendingString:@"/"];
    plistPathinDocumentDirectory = [plistPathinDocumentDirectory stringByAppendingString:albumShortName];
    plistPathinDocumentDirectory = [plistPathinDocumentDirectory stringByAppendingString:@"_SongList.plist"];
    
    //if yes, load from document directory, if no copy from resource directory to document directory
    if ([fileManager fileExistsAtPath:plistPathinDocumentDirectory])
    {
        [self initializeSongs:albumShortName];
    }
    else
    {
        NSString *plistPathinResourceDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"];
        plistPathinResourceDirectory = [plistPathinResourceDirectory stringByAppendingString:albumShortName];
        plistPathinResourceDirectory = [plistPathinResourceDirectory stringByAppendingString:@"_SongList.plist"];
        
        if ([fileManager fileExistsAtPath:plistPathinResourceDirectory]) {
            [fileManager copyItemAtPath:plistPathinResourceDirectory toPath:plistPathinDocumentDirectory error:nil];
            
            [self initializeSongs:albumShortName];
        }
    }
    
    //Check if there is update on cloud storage
    [self updateSongs:albumShortName];
}

- (NSMutableArray *)searchSongArrayByAlbumName:(NSString*) albumName
{
    NSMutableArray *songArray;
    
    songArray = [_songArrayDictionaryByAlbumName objectForKey:albumName];
    
    if (songArray == nil) {
        
        [self loadSongs:albumName];
        songArray = [_songArrayDictionaryByAlbumName objectForKey:albumName];
    }
    
    return songArray;
}

- (BOOL) searchSong:(NSDictionary *)newDirectory InOldSongs:(NSMutableDictionary *)oldPlist_directory
{
    BOOL result = FALSE;
    
    for (NSInteger i = 1; i <= oldPlist_directory.count; i++) {
        
        NSDictionary *oldDirectory = [oldPlist_directory objectForKey:[NSString stringWithFormat:@"%d", i]];
        
        NSString *songUrl_old = [oldDirectory objectForKey:@"Url"];
        NSString *songUrl_new = [newDirectory objectForKey:@"Url"];
        
        if ([songUrl_new isEqualToString:songUrl_old]) {
            return TRUE;
        }
    }
    
    return result;
}

- (void)writeBacktoPlist:(NSString*) albumName;
{
    NSMutableDictionary *newPlist_dictionary = [[NSMutableDictionary alloc]init];
    
    NSMutableArray *_songs = [_songArrayDictionaryByAlbumName objectForKey:albumName];
    
    for (NSInteger i = 1; i <= _songs.count; i++ ) {
        NSMutableDictionary *songDirectory = [[NSMutableDictionary alloc]init];
        
        Song *song = _songs[i-1];
        [songDirectory setObject:song.title forKey:@"Title"];
        [songDirectory setObject:song.duration forKey:@"Duration"];
        [songDirectory setObject:[song.Url absoluteString] forKey:@"Url"];
        [songDirectory setObject:[song.filePath absoluteString] forKey:@"FilePath"];
        [songDirectory setObject:song.price forKey:@"Price"];
        [songDirectory setObject:song.updatedSong forKey:@"UpdatedSong"];
        
        [newPlist_dictionary setValue:songDirectory forKey:[NSString stringWithFormat:@"%@", song.songNumber]];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_SongList.plist", albumName]];
    
    bool result = [newPlist_dictionary writeToFile:plistPath atomically:NO];
}

@end
