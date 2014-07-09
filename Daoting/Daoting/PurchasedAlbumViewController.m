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
    
    // 1. show album title
    cell.lbl_albumTitle.text = [self searchforAlbumTitlebyShortName:albumShortName];
    
    // 2. show album icon
    //Updating Cell Image
    NSURL *url = [self searchforAblumIconUrlbyShortName:albumShortName];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
    
    __weak PurchasedAlbumCell *weakCell = cell;
    
    //cell.img_album setimage
    [cell.img_album setImageWithURLRequest:request
                        placeholderImage:placeholderImage
                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         [weakCell.img_album setImage:image];
         [weakCell setNeedsLayout];
         
     } failure:nil];
    
    return cell;
}

-(NSString *)searchforAlbumTitlebyShortName:(NSString *)shortName
{
    NSString *albumTitle = nil;
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    for (Album *album in appDelegate.albums) {
     
        if ([album.shortName isEqualToString: shortName]) {
            albumTitle = album.title;
            break;
        }
    }
    return albumTitle;
}

-(NSURL*)searchforAblumIconUrlbyShortName:(NSString *)shortName
{
    NSURL* albumIconUrl = nil;
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    for (Album *album in appDelegate.albums) {
        
        if ([album.shortName isEqualToString: shortName]) {
            albumIconUrl = album.imageUrl;
            break;
        }
    }
    return albumIconUrl;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PurchasedSongViewController *viewController = (PurchasedSongViewController *)[segue destinationViewController];
    
    PurchasedAlbumCell* cell =(PurchasedAlbumCell *)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *key = _appData.purchasedQueue.allKeys[indexPath.row];
    NSMutableDictionary *PurchasedSongArray = [_appData.purchasedQueue objectForKey:key];
    
    viewController.songsArray = PurchasedSongArray;
    viewController.albumTitle = key;
}



@end
