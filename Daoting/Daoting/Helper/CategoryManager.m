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
    
    [self updateCategory];
    
    return self;
}

- (void)initializeCategory
{
    
}

- (void)updateCategory
{
    
}


@end
