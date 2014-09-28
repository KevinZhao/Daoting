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
