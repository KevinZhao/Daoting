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
    
    _lbl_100yuan.isWithStrikeThrough = true;
    _lbl_250yuan.isWithStrikeThrough = true;

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
    self.lbl_coins.text = [NSString stringWithFormat:@"%d", [AppData sharedAppData].coins];
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



@end
