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
         
         //there is new song in the plist
         if (newPlist_dictionary.count > oldPlist_dictionary.count)
         {
             int oldCount = (int)oldPlist_dictionary.count;
             int j = (int)(newPlist_dictionary.count - oldPlist_dictionary.count);
             
             //Copy items in new Plist to old Plist
             for (int i = 1; i<= j; i++)
             {
                 NSDictionary *newSong = [newPlist_dictionary objectForKey:[NSString stringWithFormat:@"%d",oldCount + i]];
                 
                 [oldPlist_dictionary setValue:newSong forKey:[NSString stringWithFormat:@"%d", (oldCount + i)]];
             }
             [oldPlist_dictionary writeToFile:plistPath atomically:NO];
             
             //re-initialize songs and update table view
             [self initializeSongs:albumShortName];
             
             //call back, ask song table view to reload
             //todo, mark something new had updated
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

@end
