//
//  AlbumTableViewController.m
//  Daoting
//
//  Created by Kevin on 14-5-12.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "AlbumTableViewController.h"
#import "CoinIAPHelper.h"
#import "Album.h"
#import "AlbumCell.h"
#import "UIImageView+AFNetworking.h"
#import "SongTableViewController.h"

@interface AlbumTableViewController ()

@end

@implementation AlbumTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadAlbums];
    
    [self updateAlbums];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Internal Business Logic

- (void)loadAlbums
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
    [self.tableView reloadData];
}

- (void)initializeAlbums
{
    _albums = [[NSMutableArray alloc]init];
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    
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
    
    appDelegate.albums = _albums;
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
             
             [self.tableView reloadData];
         }
         else
         {
             //there is no update for albums
         }
         
     }
     //Download Failed
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"网络异常" message:@"当前网络无法连接，无法检查更新" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
         //[alert show];
     }
     ];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Album *album = [_albums objectAtIndex:indexPath.row];
    AlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell" forIndexPath:indexPath];
    
    //Configure Cell
    cell.lbl_albumTitle.text = album.title;
    cell.lbl_albumDescription.text = album.description;
    
    if ([album.updatingStatus isEqual:@"Updating"]) {
    
        cell.lbl_Status.text = @"更新中";
    }
    
    if ([album.updatingStatus isEqual:@"Completed"]) {
        cell.lbl_Status.text = @"已完结";
    }
    
    //Updating Cell Image
    NSURLRequest *request = [NSURLRequest requestWithURL:album.imageUrl];
    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
    
    __weak AlbumCell *weakCell = cell;
    
    [cell.img_albumImage setImageWithURLRequest:request
                               placeholderImage:placeholderImage
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
    {
        [weakCell.img_albumImage setImage:image];
        [weakCell setNeedsLayout];
                                       
    } failure:nil];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSongList"]) {
        
        NSIndexPath *indexpath = [self.tableView indexPathForSelectedRow];

        SongTableViewController *destinationViewController = [segue destinationViewController];
        
        destinationViewController.hidesBottomBarWhenPushed = YES;
        [destinationViewController setDetailItem: [_albums objectAtIndex:indexpath.row]];
    }
}

@end
