//
//  StoreTableViewController.m
//  Daoting
//
//  Created by Kevin on 14/6/8.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "StoreTableViewController.h"

@interface StoreTableViewController ()

@end

@implementation StoreTableViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    _products = appDelegate.products;
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sorter count:1];
    NSArray *sortedArray = [_products sortedArrayUsingDescriptors:sortDescriptors];
    
    _products = sortedArray;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return _products.count+1;
}


/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StoreCell" forIndexPath:indexPath];
    
    if (indexPath.row == _products.count) {
        cell.lbl_STKProductTitle.text = [NSString stringWithFormat:@"现有金币 %d枚", [AppData sharedAppData].coins];
    }
    else
    {
    

    
    SKProduct *product = _products[indexPath.row];
    
    cell.lbl_STKProductTitle.text = product.localizedDescription;
    cell.lbl_STKProductPrice.text = [NSString stringWithFormat:@"%@", product.price];
    cell.lbl_STKProductTitle.text = product.localizedTitle;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
             CoinIAPHelper *helper = [CoinIAPHelper sharedInstance];
            
             [helper buyProduct:_products[0]];
            
        }
            break;
        case 1:
        {
            CoinIAPHelper *helper = [CoinIAPHelper sharedInstance];
            
            
            [helper buyProduct:_products[1]];
            
        }
            break;
        case 2:
        {
            CoinIAPHelper *helper = [CoinIAPHelper sharedInstance];
            
            
            [helper buyProduct:_products[2]];
            
        }
            break;
        case 3:
        {
            CoinIAPHelper *helper = [CoinIAPHelper sharedInstance];
            
            [helper buyProduct:_products[3]];
        }
            break;
        case 4:
        {
            CoinIAPHelper *helper = [CoinIAPHelper sharedInstance];
            
            [helper buyProduct:_products[4]];
        }
            break;
            
        default:
            break;
    }
}*/


@end
