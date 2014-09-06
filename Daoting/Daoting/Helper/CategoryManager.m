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

- (CategoryManager *)init
{
    //Load Category List
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPathinDocumentDirectory = [bundleDocumentDirectoryPath stringByAppendingString:@"/CategoryList.plist"];
    
    //if yes, load from document directory,
    if ([fileManager fileExistsAtPath:plistPathinDocumentDirectory])
    {
        [self initializeCategory];
    }
    //if no, copy from resource directory to document directory
    else
    {
        NSString *plistPathinResourceDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/CategoryList.plist"];
        
        if ([fileManager fileExistsAtPath:plistPathinResourceDirectory]) {
            [fileManager copyItemAtPath:plistPathinResourceDirectory toPath:plistPathinDocumentDirectory error:nil];
            
            [self initializeCategory];
        }
    }
    
    //[self updateCategory];
    
    return self;
}

- (void)initializeCategory
{
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
}

- (AudioCategory *)searchAlbumByShortName:(NSString*) shortName
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
    
}


@end
