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
    
    NSString *plistPath = [DocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_SongList.plist", albumShortName]];
    
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
         
         //1. there is new song in the plist
         if (newCount > oldCount)
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
         
         //[self increamentalUpdate:albumShortName];
     }
     //Download Failed
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //try to download again
         NSLog(@"error%@", error.domain);
     }];
}

- (void)increamentalUpdate:(NSString*)albumShortName
{
    //1. create new url
    NSMutableArray *songArray = [self searchSongArrayByAlbumName:albumShortName];
    
    Song *lastSong = songArray[songArray.count - 1];
    NSMutableString *lastSongUrl = [[NSMutableString alloc]initWithString:[lastSong.Url absoluteString]];
    
    int songNumber = [lastSong.songNumber intValue];
    NSMutableString *oldSongNumber = [NSMutableString stringWithFormat:@"%d", songNumber];
    
    if (oldSongNumber.length == 2) {
        [oldSongNumber insertString:@"0" atIndex:0];
    }
    if (oldSongNumber.length == 1) {
        [oldSongNumber insertString:@"00" atIndex:0];
    }
    
    songNumber += 1;
    NSMutableString *newSongNumber = [NSMutableString stringWithFormat:@"%d",songNumber];
    
    if (newSongNumber.length == 2) {
        [newSongNumber insertString:@"0" atIndex:0];
    }
    if (newSongNumber.length == 1) {
        [newSongNumber insertString:@"00" atIndex:0];
    }
    
    [lastSongUrl replaceOccurrencesOfString:oldSongNumber withString:newSongNumber options:NSLiteralSearch range:NSMakeRange(0, lastSongUrl.length)];
    
    NSURL *newSongURL = [[NSURL alloc]initWithString:lastSongUrl];
    
    //2. check if there is new download
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:newSongURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    
    [operation start];
    
    //Download complete block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //left blank
         NSLog(@"this is not intended");
     }
     //Download Failed
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //there is no update
         NSLog(@"error%@", error.domain);
         
         return;
     }];
    
    AFHTTPRequestOperation __weak *operation_ = operation;
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        // there is a update file
        Song *newSong = [[Song alloc]init];
        
        newSong.songNumber = newSongNumber;
        newSong.title = lastSong.title;
        newSong.Url = newSongURL;
        newSong.price = lastSong.price;
        newSong.updatedSong = @"YES";
        
        NSMutableArray *songs = [self searchSongArrayByAlbumName:albumShortName];
        
        if (([songs valueForKey:newSongNumber] == nil)) {
            //3. write back to plist
            [songs insertObject:newSong atIndex:songs.count];
            [self writeBacktoPlist:albumShortName];
            [operation_ cancel];
        };
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
    
    //if yes, load from document directory,
    if ([fileManager fileExistsAtPath:plistPathinDocumentDirectory])
    {
        [self initializeSongs:albumShortName];
    }
    //if no copy from resource directory to document directory
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
    
    //[self updateSongs:albumShortName];
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
        
        if (song.duration != nil) {
            [songDirectory setObject:song.duration forKey:@"Duration"];
        }
        else
        {
            [songDirectory setObject:@"" forKey:@"Duration"];
        }

        [songDirectory setObject:[song.Url absoluteString] forKey:@"Url"];
        
        if (song.filePath != nil) {
            [songDirectory setObject:[song.filePath absoluteString] forKey:@"FilePath"];
        }
        else
        {
            [songDirectory setObject:@"" forKey:@"FilePath"];
        }
        
        [songDirectory setObject:song.price forKey:@"Price"];
        
        if (song.updatedSong != nil) {
            [songDirectory setObject:song.updatedSong forKey:@"UpdatedSong"];
        }
        else
        {
            [songDirectory setObject:@"" forKey:@"UpdatedSong"];
        }

        [newPlist_dictionary setValue:songDirectory forKey:[NSString stringWithFormat:@"%@", song.songNumber]];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_SongList_new.plist", albumName]];
    
    [newPlist_dictionary writeToFile:plistPath atomically:NO];
}

@end
