//
//  ClearCacheViewController.m
//  Daoting
//
//  Created by Kevin on 14/7/4.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "ClearCacheViewController.h"


@implementation ClearCacheViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    
    NSURL* CachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    
    _storagePath = [[CachesDirectoryURL path] stringByAppendingString:@"/Daoting/"];
    
    _albumShortnameArray = [[NSMutableArray alloc]init];
    [self buildAlbumList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _albumShortnameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClearCacheCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"ClearCacheCell" forIndexPath:indexPath];
    
    //1. get album title
    NSString *albumShortName = (NSString *)_albumShortnameArray[indexPath.row];
    Album *album = [[CategoryManager sharedManager] searchAlbumByShortName:albumShortName];
    //Todo: if album == nil
             
    cell.lbl_albumName.text = album.title;

    //2. get album size
    long size = [self calculateSize:[_storagePath stringByAppendingString:[NSString stringWithFormat:@"/%@", _albumShortnameArray[indexPath.row]]]];
    cell.lbl_size.text = [self sizeToMb:size];
    
    return cell;
}

- (void)buildAlbumList
{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    _albumShortnameArray = (NSMutableArray *)[fm contentsOfDirectoryAtPath:_storagePath error:nil];
}

-(long)calculateSize:(NSString *)directory
{
    long size = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSArray* array = [fileManager contentsOfDirectoryAtPath:directory error:nil];
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [directory stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            NSDictionary *fileAttributeDic=[fileManager attributesOfItemAtPath:fullPath error:nil];
            size += fileAttributeDic.fileSize;
        }
        else
        {
            //left blank;
        }
    }
    
    return size;
}

- (NSString*)sizeToMb:(long)size
{
    NSString *sizeString;
    
    NSInteger Mbsize = size / 1024 / 1024;
    
    NSInteger hundredKbsize = fmod(size/1024, 1024)/100;
    
    sizeString = [NSString stringWithFormat:@"%ld.%ld MB",(long)Mbsize,(long)hundredKbsize];
    
    return sizeString;
}

-(IBAction)clearCache:(id)sender
{
    UITableViewCell *cell = [self GetTableViewCell:sender];
    
    _selectedIndexPath = [self.tableView indexPathForCell:cell];
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"清空缓存" message:@"确定要清空专辑中的全部缓存文件" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [alertView show];
}

- (UITableViewCell *)GetTableViewCell:(id)sender
{
    Class vcc = [UITableViewCell class];
    UIResponder *responder = sender;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: vcc])
            return (UITableViewCell *)responder;
    return nil;
}

#pragma mark alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        NSString *directory = [_storagePath stringByAppendingString:[NSString stringWithFormat:@"%@", _albumShortnameArray[_selectedIndexPath.row]]];
        
        NSArray* array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
        for(int i = 0; i<[array count]; i++)
        {
            NSString *fullPath = [directory stringByAppendingPathComponent:[array objectAtIndex:i]];
            
            BOOL isDir;
            if ( !([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
            {
                [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
            }
            else
            {
                //left blank;
            }
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:directory error:nil];

        //update UI
        [_albumShortnameArray removeObjectAtIndex:_selectedIndexPath.row];
        
        [self.tableView beginUpdates];
        
        [self.tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
    }
    
}

@end
