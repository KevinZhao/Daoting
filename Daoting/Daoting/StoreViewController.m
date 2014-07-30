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
    
    _lbl_120yuan.isWithStrikeThrough = true;
    _lbl_300yuan.isWithStrikeThrough = true;
    _lbl_60yuan.isWithStrikeThrough = true;
    _lbl_30yuan.isWithStrikeThrough = true;
    
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
    
    _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

#pragma mark

- (void)setupNotificationView
{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"NotificationView_iphone" owner:self options:nil];
    
    _notificationView = [nibViews objectAtIndex:0];
    _notificationView.center = self.view.center;
    [self.view addSubview:_notificationView];
    
    [_notificationView.layer setMasksToBounds:YES];
    [_notificationView.layer setCornerRadius:10.0];
    [_notificationView.layer setBorderWidth:5.0];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 0, 0, 1, 0.2 });
    [_notificationView.layer setBorderColor:colorref];//边框颜色
    
    _notificationView.alpha = 0.0;
}

-(void)showNotification:(NSString *)notification;
{
    _notificationView.alpha = 1.0;
    
    _notificationView.lbl_coins.text = [NSString stringWithFormat:@"%d", _appData.coins];
    _notificationView.lbl_notification.text = notification;
    
    //show notification view
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.5];
    [UIView setAnimationDelay:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    _notificationView.alpha = 0.0;
    [UIView commitAnimations];
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
    
    _lbl_coins.text = [NSString stringWithFormat:@"%d", _appData.coins];
    
    NSString *reminder = [NSString stringWithFormat:@"成功购买金币 %d 枚", purchasedCoins];
    
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
        helper.delegate = self;
        [helper buyProduct:_products[tag]];
        
        _spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 320, 460)];
        
        _spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _spinner.color = [UIColor greenColor];
        
        [_spinner startAnimating];
        [self.view addSubview:_spinner];
        
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
        
        _appData.coins += 20;
        
        self.lbl_coins.text = [NSString stringWithFormat:@"%d", _appData.coins];
        
        [_appData save];
        
        NSString *notification = @"您获得了 20金币";
        
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
    
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"这个app不错，评书、有声书都有，严重推荐! %@", _appDelegate.appUrlinAws]
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imgPath]
                                                title:[NSString stringWithFormat:@"这个app不错，评书、有声书都有，严重推荐! %@", _appDelegate.appUrlinAws]
                                                  url:_appDelegate.appUrlinAws
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
            _appData.coins = _appData.coins + 20;
            NSString *notification = @"您获得了 20金币";
            
            [self showNotification:notification];
        }
        else if (state == SSResponseStateFail)
        {
            NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
        }
    }];
}

- (void)onLoadedProducts
{
    [_spinner stopAnimating];
}

@end
