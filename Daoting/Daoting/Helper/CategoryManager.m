//
//  CategoryManager.m
//  Daoting
//
//  Created by Kevin on 14/9/1.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "CategoryManager.h"

@implementation CategoryManager

+ (CategoryManager *)sharedManager {
    static dispatch_once_t once;
    static CategoryManager * sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [[CategoryManager alloc]init];
        
    });
    return sharedInstance;
}


#pragma mark Initialize Category

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
        
        [_categoryArray addObject:category];
    }
    
    self.categoryUpdatingStatus = InitializingCompleted;
}

- (AudioCategory *)searchCategoryByShortName:(NSString*) shortName
{
    AudioCategory *category;
    
    for (AudioCategory *subCategory in _categoryArray) {
        if ([subCategory.shortName isEqual:shortName]) {
            
            category = subCategory;
            break;
        }
    }
    
    return category;
}

- (void)updateCategory
{
    self.categoryUpdatingStatus = Upgrating;
    
    
    self.categoryUpdatingStatus = UpgratingCompleted;
}

#pragma mark Initialize Album

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

#pragma mark Initialize Song

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
        
        [songArray addObject:song];
    }
    
    album.songArray = songArray;
}

#pragma mark public methods

- (Album*)searchAlbumByShortName:(NSString*) albumShortName
{
    Album* album = nil;
    
    //todo revisit
    /*for (<#type *object#> in _categoryArray) {
        <#statements#>
    }*/
    
    return album;
}

- (NSMutableArray* ) searchAlbumByCategory:(AudioCategory *) category
{
    if (category.albumArray == nil) {
        [self initializeAlbumByCategory:category];
    }
    
    return category.albumArray;
}

- (NSMutableArray* ) searchSongByAlbum:(Album *) album
{
    if (album.songArray == nil) {
        [self initializeSongByAlbum:album];
    }
    
    return album.songArray;
}

@end
