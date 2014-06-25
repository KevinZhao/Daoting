//
//  StoreTableViewController.m
//  Daoting
//
//  Created by Kevin on 14/6/8.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "StoreViewController.h"


@implementation StoreViewController

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
    
    _appData = [AppData sharedAppData];
    
    _lbl_100yuan.isWithStrikeThrough = true;
    _lbl_250yuan.isWithStrikeThrough = true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePurchase:) name:IAPHelperProductPurchasedNotification object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buy:(UIButton *)sender
{
    NSInteger tag = (NSInteger)sender.tag;
    
    CoinIAPHelper *helper = [CoinIAPHelper sharedInstance];
    
    [helper buyProduct:_products[tag]];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.lbl_coins.text = [NSString stringWithFormat:@"%d", _appData.coins];
    [self setupNotificationView];
}

- (void)setupNotificationView
{
    //need to make it beautiful
    _notificationView = [[UIView alloc]init];
    _notificationView.frame = CGRectMake(60, 400, 200, 50);
    _notificationView.backgroundColor = [UIColor grayColor];
    
    [self.view addSubview:_notificationView];
    
    _notificationView.alpha = 0.0;
}

-(void)showNotification:(NSString *)notification;
{
    //todo show beatiful notification view
    
    //configure notification view
    UILabel *lbl_description = [[UILabel alloc]init];
    lbl_description.frame = CGRectMake(10, 10, 180, 40);
    lbl_description.text = notification;
    [_notificationView addSubview:lbl_description];
    _notificationView.alpha = 1.0;
    
    //show notification view
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelay:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    _notificationView.alpha = 0.0;
    
    [UIView commitAnimations];
}

- (void) handlePurchase: (NSNotification *)notification;
{
    NSString *productIdentifier = notification.object;
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.10000coins"]) {
        _appData.coins = _appData.coins + 10000;
    }
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.500coins"]) {
        _appData.coins = _appData.coins + 500;
    }
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.25000coins"]) {
        _appData.coins = _appData.coins + 25000;
    }
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.1000coins"]) {
        _appData.coins = _appData.coins + 1000;
    }
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.2500coins"]) {
        _appData.coins = _appData.coins + 2500;
    }
    
    [_appData save];
    
    _lbl_coins.text = [NSString stringWithFormat:@"%d", _appData.coins];
    
    NSString *reminder = @"成功购买金币";
    [self showNotification:reminder];
    
}


@end
