//
//  PurchasedSongViewController.m
//  Daoting
//
//  Created by Kevin on 14/7/4.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "PurchasedAlbumViewController.h"

@interface PurchasedAlbumViewController ()

@end

@implementation PurchasedAlbumViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _appData = [AppData sharedAppData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _appData.purchasedQueue.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PurchasedAlbumCell *cell = (PurchasedAlbumCell*)[tableView dequeueReusableCellWithIdentifier:@"PurchasedAlbumCell" forIndexPath:indexPath];
    
    NSString* albumShortName = _appData.purchasedQueue.allKeys[indexPath.row];

    Album *album = [[CategoryManager sharedManager] searchAlbumByShortName: albumShortName];
    
    if (album != nil) {
        
        //1. show album title
        cell.lbl_albumTitle.text = album.title;
        
        //2. icon
        NSURLRequest *request = [NSURLRequest requestWithURL:album.imageUrl];
        UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
        
        __weak PurchasedAlbumCell *weakCell = cell;
        
        // 3. cell.img_album setimage
        [cell.img_album setImageWithURLRequest:request
                              placeholderImage:placeholderImage
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             [weakCell.img_album setImage:image];
             [weakCell setNeedsLayout];
             
         } failure:nil];
    }

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PurchasedSongViewController *viewController = (PurchasedSongViewController *)[segue destinationViewController];
    
    PurchasedAlbumCell* cell =(PurchasedAlbumCell *)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *key = _appData.purchasedQueue.allKeys[indexPath.row];
    
    viewController.songsArray = [_appData.purchasedQueue objectForKey:key];
    viewController.album = [[CategoryManager sharedManager] searchAlbumByShortName:key];
}

@end
