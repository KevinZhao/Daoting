//
//  SongTableViewController.m
//  Daoting
//
//  Created by Kevin on 14-5-12.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "SongTableViewController.h"

@interface SongTableViewController ()
@end

@implementation SongTableViewController
@synthesize pageControl, scrollView;

//#define int kNumberOfPages = 2;

#pragma mark - UIView delegate

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    [self loadSongs];
    
    [self updateSongs];
}


- (void)viewWillAppear:(BOOL)animated
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    scrollView.contentSize = CGSizeMake(640, 406);
    
    //Configure tableview
    _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 406) style:UITableViewStylePlain];
    _tableview.delegate = self;
    _tableview.dataSource = self;

    [scrollView addSubview:_tableview];
    
    //Todo: Change to another UIView to give description of album
    UIImageView *test = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wangyuebo.jpg"]];
    test.frame = CGRectMake(320, 0, 320, 406);
    [scrollView addSubview:test];
    
    //Configure scrollview
    pageControl.currentPage = 0;
    pageControl.numberOfPages = 2;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Internal business logic

- (void)initializeSongs
{
    _songs = [[NSMutableArray alloc]init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];

    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:@"/"];
    plistPath = [plistPath stringByAppendingString:_album.shortName];
    plistPath = [plistPath stringByAppendingString:@"_SongList.plist"];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    for (int i = 1; i<= dictionary.count; i++)
    {
        NSDictionary *SongDic = [dictionary objectForKey:[NSString stringWithFormat:@"%d", i]];
        
        Song *song = [[Song alloc]init];
        
        song.songNumber = [NSString stringWithFormat:@"%d", i];
        song.title      = [SongDic objectForKey:@"Title"];
        song.duration   = [SongDic objectForKey:@"Duration"];
        song.Url        = [[NSURL alloc] initWithString:[SongDic objectForKey:@"Url"]];
        
        [_songs addObject:song];
    }
}

- (void)updateSongs
{
    //1. Check if plist is in document directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPath = [bundleDocumentDirectoryPath stringByAppendingString:@"/"];
    plistPath = [plistPath stringByAppendingString:_album.shortName];
    plistPath = [plistPath stringByAppendingString:@"_SongList.plist"];
    
    //2. Download plist from cloud storage
    NSURLRequest *request = [NSURLRequest requestWithURL:_album.plistUrl];
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
             [self initializeSongs];
             
             [_tableview reloadData];
             
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"更新成功" message:[NSString stringWithFormat:@"成功更新%d个新回目，请点击下载按钮", j] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"更新成功" message:@"目前没有可用更新" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
         }
         
     }
     //Download Failed
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"网络异常" message:@"当前网络无法连接，无法检查更新" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
         [alert show];
     }
     ];
}

- (void)loadSongs
{
    //1. Check if there is a playlist in document directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    NSString *plistPathinDocumentDirectory = [bundleDocumentDirectoryPath stringByAppendingString:@"/"];
    plistPathinDocumentDirectory = [plistPathinDocumentDirectory stringByAppendingString:_album.shortName];
    plistPathinDocumentDirectory = [plistPathinDocumentDirectory stringByAppendingString:@"_SongList.plist"];
    
    //if yes, load from document directory, if no copy from resource directory to document directory
    if ([fileManager fileExistsAtPath:plistPathinDocumentDirectory])
    {
        [self initializeSongs];
    }
    else
    {
        NSString *plistPathinResourceDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"];
        plistPathinResourceDirectory = [plistPathinResourceDirectory stringByAppendingString:_album.shortName];
        plistPathinResourceDirectory = [plistPathinResourceDirectory stringByAppendingString:@"_SongList.plist"];
        
        if ([fileManager fileExistsAtPath:plistPathinResourceDirectory]) {
            [fileManager copyItemAtPath:plistPathinResourceDirectory toPath:plistPathinDocumentDirectory error:nil];
            
            [self initializeSongs];
        }
        

    }
    
    [_tableview reloadData];
}


- (void)setDetailItem:(Album *)album
{
    _album = album;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _songs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Song *song = [_songs objectAtIndex:indexPath.row];
    
    //Load from xib for prototype cell
    [tableView registerNib:[UINib nibWithNibName:@"SongCell" bundle:nil]forCellReuseIdentifier:@"SongCell"];
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell"];
    
    cell.lbl_songTitle.text = song.title;
    cell.lbl_playbackDuration.text = song.duration;
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    // First, determine which page is currently visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Update the page control
    pageControl.currentPage = page;
}

@end
