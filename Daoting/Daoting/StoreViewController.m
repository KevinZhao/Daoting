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
    
    _appData = [AppData sharedAppData];
    
    _lbl_100yuan.isWithStrikeThrough = true;
    _lbl_250yuan.isWithStrikeThrough = true;
    
    //Register observer for IAP helper notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePurchaseCompleted:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.lbl_coins.text = [NSString stringWithFormat:@"%d", _appData.coins];
    [self setupNotificationView];
}

#pragma mark

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

#pragma mark IAP Notification Handler

- (void) handlePurchaseCompleted: (NSNotification *)notification;
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
        [helper buyProduct:_products[tag]];
    }else{
        
        //indicate the iTunes Store can not been connected
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法连接iTunes Store，请重试" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        [alert show];
    }
}

- (IBAction)dailyCheckin:(UIButton *)sender
{
    NSString* date;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    date = [formatter stringFromDate:[NSDate date]];
    
    if ([_appData.dailyCheckinQueue objectForKey:date] == nil)
    {
        //check in
        NSString *yes = @"yes";
        
        [_appData.dailyCheckinQueue setObject:yes forKey:date];
        
        _appData.coins += 30;
        
        self.lbl_coins.text = [NSString stringWithFormat:@"%d", _appData.coins];
        
        [_appData save];
        
        NSString *notification = @"您获得了 30金币";
        
        [self showNotification:notification];
    }
    else
    {
        NSString *notification = @"您今日已经签到了，请明日再试";
        [self showNotification:notification];
    }
}

- (IBAction)share:(id)sender
{
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"AppIcon76x76@2x" ofType:@"png"];
    
    id<ISSContent> publishContent = [ShareSDK content:@"我正在听王玥波的评书《聊斋》，收集整理的好全，严重推荐! http://t.cn/RvTAdqk"
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imgPath]
                                                title:@"我正在听王玥波的评书《聊斋》，收集整理的好全，严重推荐！http://t.cn/RvTAdqk"
                                                  url:@"http://t.cn/RvTAdqk"
                                          description:@""
                                            mediaType:SSPublishContentMediaTypeNews];
    
    
    [ShareSDK showShareViewWithType:ShareTypeWeixiTimeline
                          container:nil
                            content:publishContent
                      statusBarTips:NO authOptions:nil
                       shareOptions:nil
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
        
        if (state == SSResponseStateSuccess)
        {
            //share
            _appData.coins = _appData.coins + 50;
            NSString *notification = @"您获得了 50金币";
            
            [self showNotification:notification];
        }
        else if (state == SSResponseStateFail)
        {
            NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
        }
    }];
}

@end
