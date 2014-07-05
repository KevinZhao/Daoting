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
    
    cell.lbl_albumName.text = _albumArray[indexPath.row];
    
    //get album size
    long size = [self calculateSize:[_storagePath stringByAppendingString:[NSString stringWithFormat:@"/%@", _albumArray[indexPath.row]]]];
    cell.lbl_size.text = [NSString stringWithFormat:@"%ld", size];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)buildAlbumList
{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    _albumArray = [fm contentsOfDirectoryAtPath:_storagePath error:nil];
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

-(IBAction)clearCache:(id)sender
{
    UITableViewCell *cell = [self GetTableViewCell:sender];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *directory = [_storagePath stringByAppendingString:[NSString stringWithFormat:@"/%@", _albumArray[indexPath.row]]];
    
    NSArray* array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [directory stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir;
        if ( !([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
            
            //update UI
            
        }
        else
        {
            //left blank;
        }
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
