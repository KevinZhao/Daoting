//
//  ClearCacheViewController.m
//  Daoting
//
//  Created by Kevin on 14/7/4.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "ClearCacheViewController.h"

@interface ClearCacheViewController ()

@end

@implementation ClearCacheViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    _storagePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/Daoting/"];
    
    _albumArray = [[NSMutableArray alloc]init];
    [self buildAlbumList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _albumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClearCacheCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"ClearCacheCell" forIndexPath:indexPath];
    
    //1. get album title
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSMutableArray *albums = appDelegate.albums;
    
    for (Album *album in albums) {
        if ([album.shortName isEqual: _albumArray[indexPath.row]]) {
            cell.lbl_albumName.text = album.title;
            break;
        }
    }

    //2. get album size
    long size = [self calculateSize:[_storagePath stringByAppendingString:[NSString stringWithFormat:@"/%@", _albumArray[indexPath.row]]]];
    
    cell.lbl_size.text = [self sizeToMb:size];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)buildAlbumList
{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    _albumArray = (NSMutableArray *)[fm contentsOfDirectoryAtPath:_storagePath error:nil];
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
    
    sizeString = [NSString stringWithFormat:@"%d.%d MB",Mbsize,hundredKbsize];
    
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
        
        NSString *directory = [_storagePath stringByAppendingString:[NSString stringWithFormat:@"/%@", _albumArray[_selectedIndexPath.row]]];
        
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
        [_albumArray removeObjectAtIndex:_selectedIndexPath.row];
        
        [self.tableView beginUpdates];
        
        [self.tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
    }
    
}

@end
