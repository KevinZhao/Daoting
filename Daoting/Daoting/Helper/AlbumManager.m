//
//  AlbumManager.m
//  Daoting
//
//  Created by Kevin on 14/7/15.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "AlbumManager.h"

@implementation AlbumManager
/*
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
    self = [super init];
    
    _albumArrayDictionary = [[NSMutableDictionary alloc]init];
    
    return self;
    
    
 
}

- (void)initializeAlbums:(NSString *)categoryName;
{}

- (void)updateAlbums
{
    /*1. Check if plist is in document directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:@"/AlbumList.plist"];
    
    //2. Download plist from cloud storage
    NSURL *albumListUrl = [[NSURL alloc]initWithString:@"http://bcs.pubbcsapp.com/daoting/AlbumList.plist"];
    
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
         else
         {
         }
         //next version
         /*for (int i = 1; i<= newCount; i++)
         {
             NSDictionary *AlbumDic = [newPlist_dictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
             
             Album *album = [[Album alloc]init];
             album.shortName = [AlbumDic objectForKey:@"ShortName"];
             
             album.updatingStatus = [AlbumDic objectForKey:@"UpdatingStatus"];
             
             if ([album.updatingStatus isEqualToString:@"Updating"]) {
                 [[SongManager sharedManager] updateSongs:album.shortName];
             }
         }
         
         isUpdating = false;
     }*/
     //Download Failed
    /*failure:^(AFHTTPRequestOperation *operation, NSError *error)
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


- (Album *)searchAlbumByCategory:(NSString*) categoryShortName ByAlbumShortName:(NSString*) albumShortName
{
    NSMutableArray *albumArray = [_albumArrayDictionary valueForKey:categoryShortName];
    
    return [albumArray valueForKey:albumShortName];
}

- (NSMutableArray *)searchAlbumArrayByAlbumName:(NSString*) categoryName
{
    NSMutableArray *albumArray;
    
    albumArray = [_albumArrayDictionary objectForKey:categoryName];
    
    if (albumArray == nil) {
        
        [self loadAlbums:categoryName];
        
        albumArray = [_albumArrayDictionary objectForKey:categoryName];
    }
    
    return albumArray;
}

- (void)loadAlbums:(NSString*)categoryShortName
{
    //1. Check if there is a playlist in document directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPathinDocumentDirectory = [bundleDocumentDirectoryPath stringByAppendingString:@"/"];
    plistPathinDocumentDirectory = [plistPathinDocumentDirectory stringByAppendingString:categoryShortName];
    plistPathinDocumentDirectory = [plistPathinDocumentDirectory stringByAppendingString:@"_AlbumList.plist"];
    
    //if yes, load from document directory,
    if ([fileManager fileExistsAtPath:plistPathinDocumentDirectory])
    {
        [self initializeAlbums:categoryShortName];
    }
    //if no copy from resource directory to document directory
    else
    {
        NSString *plistPathinResourceDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"];
        plistPathinResourceDirectory = [plistPathinResourceDirectory stringByAppendingString:categoryShortName];
        plistPathinResourceDirectory = [plistPathinResourceDirectory stringByAppendingString:@"_AlbumList.plist"];
        
        if ([fileManager fileExistsAtPath:plistPathinResourceDirectory]) {
            [fileManager copyItemAtPath:plistPathinResourceDirectory toPath:plistPathinDocumentDirectory error:nil];
            
            [self initializeAlbums:categoryShortName];
        }
    }
    
    //[self updateSongs:categoryShortName];
}



- (void)writeBacktoPlist
{
    /*NSMutableDictionary *newPlist_dictionary = [[NSMutableDictionary alloc]init];
    
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

- (void)foundNewSonginAlbum:(Album*) newAlbum
{
    /*for (NSInteger i = 0; i < _albums.count; i++) {
        
        Album *oladAlbum = _albums[i];
        
        if ([newAlbum.shortName isEqualToString:oladAlbum.shortName]) {
            oladAlbum.updatedAlbum = @"YES";
        }
    }
    
    [self writeBacktoPlist];
    [self initializeAlbums];
    [self.delegate onAlbumUpdated];
    
}
*/
@end
