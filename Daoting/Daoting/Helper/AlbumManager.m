//
//  AlbumManager.m
//  Daoting
//
//  Created by Kevin on 14/7/15.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "AlbumManager.h"

@implementation AlbumManager

+ (AlbumManager *)sharedManager {
    static dispatch_once_t once;
    static AlbumManager * sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [[AlbumManager alloc]init];

    });
    return sharedInstance;
}

- (AlbumManager *)init
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPathinDocumentDirectory = [bundleDocumentDirectoryPath stringByAppendingString:@"/AlbumList.plist"];
    
    //if yes, load from document directory,
    if ([fileManager fileExistsAtPath:plistPathinDocumentDirectory])
    {
        [self initializeAlbums];
    }
    //if no, copy from resource directory to document directory
    else
    {
        NSString *plistPathinResourceDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/AlbumList.plist"];
        
        if ([fileManager fileExistsAtPath:plistPathinResourceDirectory]) {
            [fileManager copyItemAtPath:plistPathinResourceDirectory toPath:plistPathinDocumentDirectory error:nil];
            
            [self initializeAlbums];
        }
    }
    
    [self updateAlbums];
    
    return self;
}

- (void)initializeAlbums
{
    _albums = [[NSMutableArray alloc]init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:@"/AlbumList.plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    for (int i = 1; i<= dictionary.count; i++)
    {
        NSDictionary *AlbumDic = [dictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        
        Album *album = [[Album alloc]init];
        album.title = [AlbumDic objectForKey:@"Title"];
        album.description = [AlbumDic objectForKey:@"Description"];
        album.imageUrl = [[NSURL alloc]initWithString:[AlbumDic objectForKey:@"ImageURL"]];
        album.plistUrl = [[NSURL alloc]initWithString:[AlbumDic objectForKey:@"SongList"]];
        album.shortName = [AlbumDic objectForKey:@"ShortName"];
        album.artistName = [AlbumDic objectForKey:@"Artist"];
        album.updatingStatus = [AlbumDic objectForKey:@"UpdatingStatus"];
        album.category = [AlbumDic objectForKey:@"Category"];
        album.longdescription = [AlbumDic objectForKey:@"LongDescription"];
        album.updatedAlbum = [AlbumDic objectForKey:@"UpdatedAlbum"];
        
        [_albums addObject:album];
    }
}

- (void)updateAlbums
{
    //1. Check if plist is in document directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:@"/AlbumList.plist"];
    
    //2. Download plist from cloud storage
    NSURL *albumListUrl = [[NSURL alloc]initWithString:@"http://bcs.duapp.com/daoting/PlistFolder%2FAlbumList.plist"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:albumListUrl];
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
         
         //There is an update
         if (newCount != oldCount)
         {
             for (NSInteger i = 1; i <= newCount; i++) {
                 NSDictionary *newAlbum = [newPlist_dictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
                 
                 //Check if the Album is a new Album
                 if ([self searchAlbum:newAlbum InOldAlbum:oldPlist_dictionary]) {
                     [newAlbum setValue:@"NO" forKey:@"UpdatedAlbum"];
                 }
                 else
                 {
                     [newAlbum setValue:@"YES" forKey:@"UpdatedAlbum"];
                 }
                 
                 //Copy newAlbum to oldPlist
                 [newPlist_dictionary setValue:newAlbum forKey:[NSString stringWithFormat:@"%d", i]];
             }
             
             [newPlist_dictionary writeToFile:plistPath atomically:NO];
             
             //re-initialize albums and callback to update table view
             [self initializeAlbums];
             
             //call back
             if (self.delegate != nil) {
                [self.delegate onAlbumUpdated];
             }
         }
     }
     //Download Failed
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //left blank
     }
     ];
}

- (BOOL) searchAlbum:(NSDictionary *)newDirectory InOldAlbum:(NSMutableDictionary *)oldPlist_directory
{
    BOOL result = FALSE;
    
    for (NSInteger i = 1; i <= oldPlist_directory.count; i++) {
        
        NSDictionary *oldDirectory = [oldPlist_directory objectForKey:[NSString stringWithFormat:@"%d", i]];
        
        NSString *albumShortName_old = [oldDirectory objectForKey:@"ShortName"];
        NSString *albumShortName_new = [newDirectory objectForKey:@"ShortName"];
        
        if ([albumShortName_new isEqualToString:albumShortName_old]) {
            return TRUE;
        }
        
    }
    
    return result;
}


- (Album *)searchAlbumByShortName:(NSString*) shortName
{
    Album *album;
    
    for (Album *subAlbum in _albums) {
        if ([subAlbum.shortName isEqual:shortName]) {
            
            album = subAlbum;
            break;
        }
    }
    
    return album;
}

- (void)writeBacktoPlist
{
    NSMutableDictionary *newPlist_dictionary = [[NSMutableDictionary alloc]init];
    
    for (NSInteger i = 1; i <= _albums.count; i++ ) {
        NSMutableDictionary *albumDirectory = [[NSMutableDictionary alloc]init];
        
        Album *album = _albums[i-1];
        
        [albumDirectory setValue:album.title forKey:@"Title"];
        [albumDirectory setValue:album.description forKey:@"Description"];
        [albumDirectory setValue:[album.imageUrl absoluteString]  forKey:@"ImageURL"];
        [albumDirectory setValue:[album.plistUrl absoluteString] forKey:@"SongList"];
        [albumDirectory setValue:album.shortName forKey:@"ShortName"];
        [albumDirectory setValue:album.artistName forKey:@"Artist"];
        [albumDirectory setValue:album.updatingStatus forKey:@"UpdatingStatus"];
        [albumDirectory setValue:album.category forKey:@"Category"];
        [albumDirectory setValue:album.longdescription forKey:@"LongDescription"];
        [albumDirectory setValue:album.updatedAlbum forKey:@"UpdatedAlbum"];
        
        [newPlist_dictionary setValue:albumDirectory forKey:[NSString stringWithFormat:@"%d", i]];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:@"/AlbumList.plist"];
    
    [newPlist_dictionary writeToFile:plistPath atomically:NO];
}

@end
