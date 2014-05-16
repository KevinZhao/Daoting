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
#import "AlbumCellTableViewCell.h"
#import "UIImageView+AFNetworking.h"

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
    
    [self copyFromResourcetoDocumentDirectory:@"AlbumList.plist"];
    
    [self initializeAlbums];
    
    //enable IAP
    [[CoinIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Internal Business Logic

- (void)initializeAlbums
{
    _albums = [[NSMutableArray alloc]init];
    
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
        
        NSString *url = [AlbumDic objectForKey:@"ImageURL"];
        album.imageUrl = [[NSURL alloc]initWithString:url];
        
        [_albums addObject:album];
    }
}

- (void)copyFromResourcetoDocumentDirectory:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *bundleDocumentDirectoryPath = [paths objectAtIndex:0];
    
    NSString *writableDBPath= [bundleDocumentDirectoryPath stringByAppendingPathComponent:fileName];
    BOOL success = [fileManager fileExistsAtPath:writableDBPath];
    if (!success)
    {
        //Copy file from Resource to Document Directory
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
        [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Album *album = [_albums objectAtIndex:indexPath.row];
    AlbumCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell" forIndexPath:indexPath];
    
    cell.lbl_albumTitle.text = album.title;
    cell.lbl_albumDescription.text = album.description;
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:album.imageUrl];
    
    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
    
    __weak AlbumCellTableViewCell *weakCell = cell;
    [cell.imageView setImageWithURLRequest:request
                          placeholderImage:placeholderImage
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       
                                       [weakCell.img_albumImage setImage:image];
                                       [weakCell setNeedsLayout];
                                       
                                   } failure:nil];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKProduct *product = _products[0];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[CoinIAPHelper sharedInstance] buyProduct:product];
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
