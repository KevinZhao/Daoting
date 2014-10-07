//
//  CategoryTableViewController.m
//  Daoting
//
//  Created by Kevin on 14/9/5.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "CategoryTableViewController.h"

@implementation CategoryTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appdelegate = [[UIApplication sharedApplication]delegate];
    
    self.view.backgroundColor = _appdelegate.defaultBackgroundColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    _categoryArray = [CategoryManager sharedManager].categoryArray;
    [CategoryManager sharedManager].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [CategoryManager sharedManager].delegate = nil;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _categoryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AudioCategory *category = [_categoryArray objectAtIndex:indexPath.row];
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
    
    cell.img_categoryNewIndicator.hidden = YES;
    
    //Configure Cell
    cell.lbl_categoryTitle.text = category.title;
    cell.lbl_categoryDescription.text = category.description;
    if ([category.updatedCategory isEqualToString:@"YES"]) {
        
        cell.img_categoryNewIndicator.hidden = NO;
    }
    
    //Updating Cell Image
    NSURLRequest *request = [NSURLRequest requestWithURL:category.imageUrl];
    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
    
    __weak CategoryCell *weakCell = cell;
    
    [cell.img_categoryImage setImageWithURLRequest:request
                               placeholderImage:placeholderImage
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         [weakCell.img_categoryImage setImage:image];
         [weakCell setNeedsLayout];
         
     } failure:nil];
    
    cell.backgroundColor = [UIColor clearColor];
    
    //selection
    UIImageView *imageView_playing = [[UIImageView alloc] initWithFrame:CGRectMake(0, 16, 5, 48)];
    imageView_playing.image = [UIImage imageNamed:@"playingsong.png"];
    
    [cell.selectedBackgroundView addSubview:imageView_playing];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if ([segue.identifier isEqualToString:@"showAlbumList"]) {
        
        NSIndexPath *indexpath = [self.tableView indexPathForSelectedRow];
        
        AlbumTableViewController *destinationViewController = [segue destinationViewController];
        
        AudioCategory *category = [_categoryArray objectAtIndex:indexpath.row];
        
        if ([category.updatedCategory isEqualToString:@"YES"]) {
            
            category.updatedCategory = @"NO";
            //todo
            //[[AlbumManager sharedManager] writeBacktoPlist];
        }
        
        [destinationViewController setDetailItem:category];
                
        //remove title of back button
        UIBarButtonItem *temporaryBarButtonItem=[[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title=@"";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    }
}


- (void)onCategoryUpdated
{
    [self.tableView reloadData];
}

-(void)onAlbumUpdated
{
    
}

-(void)onSongUpdated
{
    
}

@end
