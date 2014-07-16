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
    NSURL *albumListUrl = [[NSURL alloc]initWithString:@"http://bcs.duapp.com/daoting/PlistFolder/AlbumList.plist"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:albumListUrl];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
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
         
         //There is an update
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
             [self initializeAlbums];
         }

     }
     //Download Failed
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //left blank
     }
     ];
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

@end
