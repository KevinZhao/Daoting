//
//  StoreTableViewController.m
//  Daoting
//
//  Created by Kevin on 14/6/8.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "StoreViewController.h"


@implementation StoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //_lbl_120yuan.isWithStrikeThrough = true;
    //_lbl_300yuan.isWithStrikeThrough = true;
    //_lbl_60yuan.isWithStrikeThrough = true;
    //_lbl_30yuan.isWithStrikeThrough = true;
    
}

#pragma mark IAP Notification Handler

- (void) handlePurchaseCompleted: (NSNotification *)notification;
{
    NSString *productIdentifier = notification.object;
    int purchasedCoins = 0;
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.10000coins_new"]) {
        purchasedCoins = 10000;
    }
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.500coins"]) {
        purchasedCoins = 500;
    }
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.25000coins_new"]) {
        purchasedCoins = 25000;
    }
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.1000coins"]) {
        purchasedCoins = 1000;
    }
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.2500coins"]) {
        purchasedCoins = 2500;
    }
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.5000coins"]) {
        purchasedCoins = 5000;
    }
    
    _appData.coins = _appData.coins + purchasedCoins;
    
    [_appData save];
    
    _lbl_currentCoins.text = [NSString stringWithFormat:@"%d", _appData.coins];
    
    NSString *reminder = [NSString stringWithFormat:@"成功购买金币 %d 枚", purchasedCoins];
    
    [self showNotification:reminder];
    
}

#pragma mark UITableviewDelegate

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rowNumber = 0;
    
    switch (section) {
        case 0:
            rowNumber = 1;
            break;
        case 1:
            rowNumber = 2;
            break;
        case 2:
            rowNumber = 6;
            break;
        default:
            break;
    }
    
    return rowNumber;
}

- (NSInteger)numberOfSections
{
    return 3;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CurrentCoinCell" forIndexPath:indexPath];
        
        [_lbl_currentCoins setFrame:CGRectMake(214, 11, 86, 21)];
        
        [cell addSubview:_lbl_currentCoins];
    }
    
    return cell;
}

#pragma mark UI operation

- (IBAction)buy:(UIButton *)sender
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //Check if IAP items had been loaded
    if (appDelegate.products != nil) {
        
        _products = appDelegate.products;
        
        //sort by price
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sorter count:1];
        NSArray *sortedArray = [_products sortedArrayUsingDescriptors:sortDescriptors];
        
        _products = sortedArray;
        
        //purchase based on user selection
        NSInteger tag = (NSInteger)sender.tag;
        CoinIAPHelper *helper = [CoinIAPHelper sharedInstance];
        helper.delegate = self;
        [helper buyProduct:_products[tag]];
        
        _spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 320, 460)];
        
        _spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _spinner.color = _appDelegate.defaultColor_light;
        
        [_spinner startAnimating];
        [self.view addSubview:_spinner];
        
    }else{
        //indicate the iTunes Store can not been connected
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法连接iTunes Store，请重试" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        [alert show];
    }
}





- (void)onLoadedProducts
{
    [_spinner stopAnimating];
}

@end
