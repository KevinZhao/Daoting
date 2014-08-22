//
//  NewStoreViewController.m
//  Daoting
//
//  Created by Kevin on 14/8/21.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "NewStoreViewController.h"

@interface NewStoreViewController ()

@end

@implementation NewStoreViewController

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
    
    _appData = [AppData sharedAppData];
    _appDelegate = [UIApplication sharedApplication].delegate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CurrentCoinCell" forIndexPath:indexPath];
        
        _lbl_currentCoins = [[UILabel alloc]init];
        [_lbl_currentCoins setBounds:CGRectMake(0, 0, 80, 20)];
        [_lbl_currentCoins setFrame:CGRectMake(214, 11, 86, 21)];
        [_lbl_currentCoins setTextAlignment:NSTextAlignmentRight];
        _lbl_currentCoins.text =[ NSString stringWithFormat:@"%d", _appData.coins];
        
        [cell addSubview:_lbl_currentCoins];
    }
    
    if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ShareCell" forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            
        }
        if (indexPath.row == 1) {
            
        }
    }
    
    if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"PurchaseCoinCell" forIndexPath:indexPath];
        
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark IAP Notification Handler

- (void) handlePurchaseCompleted: (NSNotification *)notification;
{
    /*NSString *productIdentifier = notification.object;
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
    
    [self showNotification:reminder];*/
    
}

- (void)onLoadedProducts
{
    [_spinner stopAnimating];
}


@end
