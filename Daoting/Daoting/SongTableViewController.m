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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageControl.currentPage = 1;
    pageControl.numberOfPages = 2;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    scrollView.contentSize = CGSizeMake(640, 406);
    
    
    scrollView.delegate = self;
    
    _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 406) style:UITableViewStylePlain];
    _tableview.backgroundColor = [UIColor blackColor];
    _tableview.delegate = self;
    _tableview.dataSource = self;

    [scrollView addSubview:_tableview];
    
    UIImageView *test = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wangyuebo.jpg"]];
    
    test.frame = CGRectMake(320, 0, 320, 406);
    [scrollView addSubview:test];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*-(IBAction)clickPageControl:(id)sender
{
    int page = pageControl.currentPage;
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width=page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
}*/


#pragma mark - Internal business logic

- (void)initializeSongs
{
    _songs = [[NSMutableArray alloc]init];
    
    /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
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
        
        [_songs addObject:album];
    }*/
}


- (void)setDetailItem:(Album *)Album
{
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SongTableViewCell *cell;
    
    [tableView registerNib:[UINib nibWithNibName:@"SongTableViewCell" bundle:nil]forCellReuseIdentifier:@"SongTableViewCell"];
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"SongTableViewCell"];
    
    cell.lbl_songTitle.text = @"test";
    
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
