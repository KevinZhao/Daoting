//
//  CategoryManager.m
//  Daoting
//
//  Created by Kevin on 14/9/1.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "CategoryManager.h"

@implementation CategoryManager

#pragma mark public methods

+ (CategoryManager *)sharedManager {
    static dispatch_once_t once;
    static CategoryManager * sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [[CategoryManager alloc]init];
        
    });
    return sharedInstance;
}

- (CategoryManager *)init
{
    self = [super init];
    
    //Load Category List
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPathinDocumentDirectory = [bundleDocumentDirectoryPath stringByAppendingString:@"/CategoryList.plist"];
    
    //if yes, copy from resource directory to document directory
    if (![fileManager fileExistsAtPath:plistPathinDocumentDirectory])
    {
        NSString *plistPathinResourceDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/CategoryList.plist"];
        
        if ([fileManager fileExistsAtPath:plistPathinResourceDirectory]) {
            [fileManager copyItemAtPath:plistPathinResourceDirectory toPath:plistPathinDocumentDirectory error:nil];
        }
        
    }else{
        //Critical Error, should not happen
    }
    
    [self initializeCategory];
    
    return self;
}

- (void) update
{
    [self updateCategory];
}

#pragma mark Category Management

- (void)initializeCategory
{
    self.categoryUpdatingStatus = Initializing;
    
    _categoryArray = [[NSMutableArray alloc]init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:@"/CategoryList.plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    for (int i = 1; i<= dictionary.count; i++)
    {
        NSDictionary *CategoryDic = [dictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        
        AudioCategory *category = [[AudioCategory alloc]init];
        category.title = [CategoryDic objectForKey:@"Title"];
        category.description = [CategoryDic objectForKey:@"Description"];
        category.imageUrl = [[NSURL alloc]initWithString:[CategoryDic objectForKey:@"ImageURL"]];
        category.albumListUrl = [[NSURL alloc]initWithString:[CategoryDic objectForKey:@"AlbumListURL"]];
        category.shortName = [CategoryDic objectForKey:@"ShortName"];
        category.updatedCategory = [CategoryDic objectForKey:@"UpdatedCategory"];
        
        [_categoryArray addObject:category];
    }
    
    self.categoryUpdatingStatus = InitializingCompleted;
}

- (void)updateCategory
{
    self.categoryUpdatingStatus = Upgrating;
    
    //1. Check if plist is in document directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:@"/CategoryList.plist"];
    
    //2. Download plist from cloud storage
    NSURL *categoryListUrl = [[NSURL alloc]initWithString:@"http://182.254.148.156/Daoting/CategoryList.plist"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:categoryListUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    
    NSString *path = NSTemporaryDirectory();
    NSString *fileName = @"CategoryList.plist";
    NSString *newfilePath = [path stringByAppendingString:fileName];
    
    [fileManager removeItemAtPath:newfilePath error:nil];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:newfilePath append:NO];
    [operation start];
    
    //Download Complete
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSMutableDictionary *newPlist_dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:newfilePath];
        NSMutableDictionary *oldPlist_dictionary = [[NSMutableDictionary alloc] init];
        
        if ([fileManager fileExistsAtPath:plistPath])
        {
             oldPlist_dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        }
        
        //Copy new dictionary
        for (NSInteger i = 1; i <= newPlist_dictionary.count; i++) {
            
            NSDictionary *newCategory = [newPlist_dictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
            
            NSString *categoryShortName = (NSString*)[newCategory valueForKey:@"ShortName"];
            if ([self searchCategoryByShortName:categoryShortName] == nil){
                
                [newCategory setValue:@"YES" forKey:@"UpdatedCategory"];
            }
            
            [newPlist_dictionary setValue:newCategory forKey:[NSString stringWithFormat:@"%d", i]];
        }
        
        //Copy newAlbum to oldPlist
        if ([newPlist_dictionary writeToFile:plistPath atomically:NO]) {
            //re-initialize albums and callback to update table view
            [self initializeCategory];
        };
        
        //call back
        [self.delegate onCategoryUpdated];
        
        //update Album for each category
        for (AudioCategory* category in self.categoryArray) {
            [self updateAlbumByCategory:category];
        }
        
     }
     //Download Failed
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //left blank
     }];
    
    self.categoryUpdatingStatus = UpgratingCompleted;
}

#pragma mark Album Management

- (void)initializeAlbumByCategory:(AudioCategory *)category
{
    //1. Check if plist file had already in document library
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPathinDocumentDirectory = [DocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_AlbumList.plist",category.shortName]];
     
    //1.1 if no, copy from resource directory to document directory
    if (![fileManager fileExistsAtPath:plistPathinDocumentDirectory]){
    
        NSString *plistPathinResourceDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:[NSString stringWithFormat:@"/%@_AlbumList.plist",category.shortName]];
        
        if ([fileManager fileExistsAtPath:plistPathinResourceDirectory]) {
            [fileManager copyItemAtPath:plistPathinResourceDirectory toPath:plistPathinDocumentDirectory error:nil];
        }else
        {
            //Critical Error, the plist file not exist
        }
    }
    
    //2. initialize the albumArray
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPathinDocumentDirectory];
    NSMutableArray *albumArray = [[NSMutableArray alloc]init];
    
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
        
        [albumArray addObject:album];
    }
    
    category.albumArray = albumArray;
}

- (void)updateAlbumByCategory:(AudioCategory *)category
{
    self.albumUpdatingStatus = Upgrating;
    
    //1. Check if plist is in document directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_AlbumList.plist", category.shortName]];
    
    //2. Download plist from cloud storage
    NSURL *albumListUrl = category.albumListUrl;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:albumListUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    
    NSString *path = NSTemporaryDirectory();
    NSString *fileName = [NSString stringWithFormat:@"%@_AlbumList.plist", category.shortName];
    NSString *newfilePath = [path stringByAppendingString:fileName];
    
    [fileManager removeItemAtPath:newfilePath error:nil];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:newfilePath append:NO];
    [operation start];
    
    //Download Complete
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSMutableDictionary *newPlist_dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:newfilePath];
         
         if (newPlist_dictionary != nil) {
             
             NSMutableDictionary *oldPlist_dictionary = [[NSMutableDictionary alloc] init];
             if ([fileManager fileExistsAtPath:plistPath])
             {
                 oldPlist_dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
             }
             
             //Copy new dictionary
             for (NSInteger i = 1; i <= newPlist_dictionary.count; i++) {
                 
                 NSDictionary *newAlbum = [newPlist_dictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
                 
                 NSString *albumShortName = (NSString*)[newAlbum valueForKey:@"ShortName"];
                 if ([self searchAlbumByShortName:albumShortName inCategory:category] == nil){
                     
                     [newAlbum setValue:@"YES" forKey:@"UpdatedAlbum"];
                 }
                 
                 [newPlist_dictionary setValue:newAlbum forKey:[NSString stringWithFormat:@"%d", i]];
             }
             
             //Copy to oldPlist
             if ([newPlist_dictionary writeToFile:plistPath atomically:NO]) {
                 //re-initialize albums and callback to update table view
                 [self initializeAlbumByCategory:category];
             };
             
             //call back
             [self.delegate onAlbumUpdated];
             
             //update Songs for each Album
             for (Album* album in category.albumArray) {
                 
                 if ([album.updatingStatus isEqualToString:@"Updating"]) {
                    [self updateSongByAlbum:album];
                 }
             }
             
         }

     }
     //Download Failed
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //left blank
     }];
    
    self.albumUpdatingStatus = UpgratingCompleted;
}

#pragma mark Song Management

- (void)initializeSongByAlbum:(Album *)album
{
    //1. Check if plist file had already in document library
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPathinDocumentDirectory = [DocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_SongList.plist", album.shortName]];
    
    //1.1 if no, copy from resource directory to document directory
    if (![fileManager fileExistsAtPath:plistPathinDocumentDirectory]){
        
        NSString *plistPathinResourceDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:[NSString stringWithFormat:@"/%@_SongList.plist", album.shortName]];
        
        if ([fileManager fileExistsAtPath:plistPathinResourceDirectory]) {
            [fileManager copyItemAtPath:plistPathinResourceDirectory toPath:plistPathinDocumentDirectory error:nil];
        }else
        {
            //Critical Error, the plist file not exist
        }
    }
    
    //2. initialize the songArray
    NSMutableArray *songArray = [[NSMutableArray alloc]init];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPathinDocumentDirectory];
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
        song.description = [SongDic objectForKey:@"Description"];
        
        [songArray addObject:song];
    }
    
    album.songArray = songArray;
}

- (void)updateSongByAlbum:(Album *)album
{
    self.songUpdatingStatus = Upgrating;
    
    //1. Check if plist is in document directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_SongList.plist", album.shortName]];
    
    //2. Download plist from cloud storage
    NSURL *songListUrl = album.plistUrl;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:songListUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    
    NSString *path = NSTemporaryDirectory();
    NSString *fileName = [NSString stringWithFormat:@"%@_SongList.plist", album.shortName];
    NSString *newfilePath = [path stringByAppendingString:fileName];
    
    [fileManager removeItemAtPath:newfilePath error:nil];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:newfilePath append:NO];
    [operation start];
    
    //Download Complete
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSMutableDictionary *newPlist_dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:newfilePath];
         
         if (newPlist_dictionary != nil) {
             
             NSMutableDictionary *oldPlist_dictionary = [[NSMutableDictionary alloc] init];
             if ([fileManager fileExistsAtPath:plistPath])
             {
                 oldPlist_dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
             }
             
             //Copy new dictionary
             for (NSInteger i = 1; i <= newPlist_dictionary.count; i++) {
                 
                 NSDictionary *newSong = [newPlist_dictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
                 
                 NSString *songNumber = [NSString stringWithFormat:@"%d", i];
                 if ([self searchSongBySongNumber:songNumber inAlbum:album] == nil){
                     
                     [newSong setValue:@"YES" forKey:@"UpdatedSong"];
                 }
                 else{
                     
                     NSDictionary* oldSong = [oldPlist_dictionary objectForKey:[NSString stringWithFormat:@"%d",i]];
                     NSString* oldUpdatedSong = (NSString*)[oldSong valueForKey:@"UpdatedSong"];
                     [newSong setValue:oldUpdatedSong forKey:@"UpdatedSong"];
                 }
                 
                 [newPlist_dictionary setValue:newSong forKey:[NSString stringWithFormat:@"%d", i]];
             }
             
             //Copy to oldPlist
             if ([newPlist_dictionary writeToFile:plistPath atomically:NO]) {
                 //re-initialize albums and callback to update table view
                 [self initializeSongByAlbum:album];
                 
                 NSLog(@"%@ Updated successfully", album.shortName);
             };
             
             //call back
             [self.delegate onSongUpdated];
             
         }
     }
     //Download Failed
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //left blank
     }];
    
    self.songUpdatingStatus = UpgratingCompleted;
}


#pragma mark search methods

- (AudioCategory*)searchCategoryByShortName:(NSString*) shortName
{
    AudioCategory* resultCategory = nil;
    
    for (AudioCategory *subCategory in _categoryArray) {
        if ([subCategory.shortName isEqual:shortName]) {
            
            resultCategory = subCategory;
            return resultCategory;
        }
    }
    
    return resultCategory;
}

- (Album*)searchAlbumByShortName:(NSString*) albumShortName inCategory:(AudioCategory*) category
{
    Album* resultAlbum = nil;
    
    if (category.albumArray == nil) {
        [self initializeAlbumByCategory:category];}
    
    
    for (Album *album in category.albumArray) {
        if ([album.shortName isEqualToString: albumShortName]) {
            
            resultAlbum = album;
            return resultAlbum;
        }
    }
    
    return resultAlbum;
}

- (Album*)searchAlbumByShortName:(NSString*) albumShortName
{
    Album* resultAlbum = nil;
    
    for (AudioCategory* category in _categoryArray) {
        
        resultAlbum = [self searchAlbumByShortName:albumShortName inCategory:category];
        
        if (resultAlbum != nil) {
            return resultAlbum;
        }
    }
    return resultAlbum;
}


- (Song*)searchSongBySongNumber:(NSString*)songNumber inAlbum:(Album*) album
{
    Song* resultSong;
    
    if (album.songArray == nil) {
        [self initializeSongByAlbum:album];
    }
    
    for (Song* song in album.songArray) {
        if ([song.songNumber isEqualToString:songNumber]) {
            
            resultSong = song;
            return resultSong;
        }
    }
    
    return resultSong;
}

- (NSMutableArray* ) searchAlbumArrayByCategory:(AudioCategory *) category
{
    if (category.albumArray == nil) {
        [self initializeAlbumByCategory:category];
    }
    
    return category.albumArray;
}

- (NSMutableArray* ) searchSongArrayByAlbum:(Album *) album
{
    if (album.songArray == nil) {
        [self initializeSongByAlbum:album];
    }
    
    return album.songArray;
}

#pragma mark write back to list

- (void) writeBacktoAlbumListinCategory:(AudioCategory*) category
{
    NSMutableDictionary *newPlist_dictionary = [[NSMutableDictionary alloc]init];
    
    for (NSInteger i = 1; i <= category.albumArray.count; i++ ) {
    
        NSMutableDictionary *albumDirectory = [[NSMutableDictionary alloc]init];
     
        Album *album = category.albumArray[i-1];
     
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
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_AlbumList.plist",category.shortName]];
     
    [newPlist_dictionary writeToFile:plistPath atomically:NO];
}

- (void) writeBacktoSongListinAlbum:(Album *)album
{
    NSMutableDictionary *newPlist_dictionary = [[NSMutableDictionary alloc]init];
    
    NSMutableArray *_songs = [self searchSongArrayByAlbum:album];
    
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
        
        if (song.description != nil) {
            [songDirectory setObject:song.description forKey:@"Description"];
        }
        else
        {
            [songDirectory setObject:@"" forKey:@"Description"];
        }
        
        [newPlist_dictionary setValue:songDirectory forKey:[NSString stringWithFormat:@"%@", song.songNumber]];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:[NSString stringWithFormat:@"/%@_SongList.plist", album.shortName]];
    
    [newPlist_dictionary writeToFile:plistPath atomically:NO];
}

@end