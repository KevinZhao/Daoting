//
//  NewStoreViewController.m
//  Daoting
//
//  Created by Kevin on 14/8/21.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "NewStoreViewController.h"

@implementation NewStoreViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.view.backgroundColor = _appDelegate.defaultBackgroundColor;
    
    //Register observer for IAP helper notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePurchaseCompleted:) name:IAPHelperProductPurchasedNotification object:nil];
    
    [self setupTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_timer invalidate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appData = [AppData sharedAppData];
    _appDelegate = [UIApplication sharedApplication].delegate;
}

-(void)setupTimer
{
    [_timer invalidate];
    
    _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)tick
{
    CurrentCoinCell* currentCoinCell = (CurrentCoinCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    currentCoinCell.lbl_currentCoins.text = [NSString stringWithFormat:@"%ld 枚", (long)_appData.coins];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buy:(NSInteger) tag
{
    //self.tableView.allowsSelection = NO;
    
    //Check if IAP items had been loaded
    if (_appDelegate.products != nil) {
        
        _products = _appDelegate.products;
        
        //sort by price
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sorter count:1];
        NSArray *sortedArray = [_products sortedArrayUsingDescriptors:sortDescriptors];
        
        _products = sortedArray;
        
        //purchase based on user selection
        CoinIAPHelper *helper = [CoinIAPHelper sharedInstance];
        helper.delegate = self;
        [helper buyProduct:_products[tag]];
        
        _spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        _spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _spinner.color = _appDelegate.defaultColor_light;
        
        [_spinner startAnimating];
        [self.view addSubview:_spinner];
        
    }else{
        
        //self.tableView.allowsSelection = YES;
        
        //indicate the iTunes Store can not been connected
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"无法连接iTunes Store，请重试" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        [alert show];
    }
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSString *sectionTitle = @"";
    
    switch (section) {
        case 0:
            sectionTitle = @"剩余金币";
            break;
        case 1:
            sectionTitle = @"获取金币";
            break;
        case 2:
            sectionTitle = @"购买金币";
            break;
        default:
            break;
    }
    
    
    return sectionTitle;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    //1. Current Coin
    if (indexPath.section == 0) {
        
        CurrentCoinCell *currentCoinCell = [tableView dequeueReusableCellWithIdentifier:@"CurrentCoinCell" forIndexPath:indexPath];
        
        currentCoinCell.lbl_currentCoins.text = [NSString stringWithFormat:@"%ld 枚", (long)_appData.coins];
        
        cell = currentCoinCell;
    }
    
    //2. Share and Checkin
    if (indexPath.section == 1) {
        
        ShareCell *shareCell = [tableView dequeueReusableCellWithIdentifier:@"ShareCell" forIndexPath:indexPath];
        
        //Check in
        if (indexPath.row == 0) {
            [shareCell.btn_cellButton setImage:[UIImage imageNamed:@"btn_checkin@2x.png"] forState:UIControlStateNormal];
            [shareCell.btn_cellButton addTarget:self action:@selector(dailyCheckin) forControlEvents:UIControlEventTouchUpInside];

            shareCell.lbl_cellDescription.text = @"签到";
            
        }
        //Share
        if (indexPath.row == 1) {
            [shareCell.btn_cellButton setImage:[UIImage imageNamed:@"btn_share@2x.png"] forState:UIControlStateNormal];
            [shareCell.btn_cellButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
            
            shareCell.lbl_cellDescription.text = @"分享";
        }
        
        cell = shareCell;
    }
    
    if (indexPath.section == 2) {
        
        PurchaseCoinCell *purchaseCoinCell = [tableView dequeueReusableCellWithIdentifier:@"PurchaseCoinCell" forIndexPath:indexPath];
        
        switch (indexPath.row) {
            case 0:
                
                if (_appData.purchaseTimes == 0) {
                    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake (purchaseCoinCell.bounds.origin.x + 180, purchaseCoinCell.bounds.origin.y, purchaseCoinCell.bounds.size.width, purchaseCoinCell.bounds.size.height)];
                    
                    [purchaseCoinCell addSubview:shimmeringView];
                    
                    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
                    loadingLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];
                    loadingLabel.textColor = [UIColor redColor];
                    loadingLabel.text = NSLocalizedString(@"首充双倍", nil);
                    shimmeringView.contentView = loadingLabel;
                    
                    // Start shimmering.
                    shimmeringView.shimmering = YES;
                    shimmeringView.shimmeringBeginFadeDuration = 0.0;
                    shimmeringView.shimmeringOpacity = 0.5;
                    shimmeringView.shimmeringSpeed = 100;
                    shimmeringView.shimmeringPauseDuration = 0.0;
                    shimmeringView.shimmeringEndFadeDuration = 0.0;
                }
                
                purchaseCoinCell.lbl_coins.text = @"500 金币";
                [purchaseCoinCell.btn_purchase setTitle:@"￥6.00" forState:UIControlStateNormal];
                purchaseCoinCell.img_sale.hidden = YES;
                
                break;
            case 1:
                if (_appData.purchaseTimes == 0) {
                    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake (purchaseCoinCell.bounds.origin.x + 180, purchaseCoinCell.bounds.origin.y, purchaseCoinCell.bounds.size.width, purchaseCoinCell.bounds.size.height)];
                    
                    [purchaseCoinCell addSubview:shimmeringView];
                    
                    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
                    loadingLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];
                    loadingLabel.textColor = [UIColor redColor];
                    loadingLabel.text = NSLocalizedString(@"首充双倍", nil);
                    shimmeringView.contentView = loadingLabel;
                    
                    // Start shimmering.
                    shimmeringView.shimmering = YES;
                    shimmeringView.shimmeringBeginFadeDuration = 0.0;
                    shimmeringView.shimmeringOpacity = 0.5;
                    shimmeringView.shimmeringSpeed = 100;
                    shimmeringView.shimmeringPauseDuration = 0.0;
                    shimmeringView.shimmeringEndFadeDuration = 0.0;
                }
                
                purchaseCoinCell.lbl_coins.text = @"1000 金币";
                [purchaseCoinCell.btn_purchase setTitle:@"￥12.00" forState:UIControlStateNormal];
                purchaseCoinCell.img_sale.hidden = YES;
                break;
            case 2:
                purchaseCoinCell.lbl_coins.text = @"2500 金币";
                [purchaseCoinCell.btn_purchase setTitle:@"￥25.00" forState:UIControlStateNormal];
                break;
            case 3:
                purchaseCoinCell.lbl_coins.text = @"5000 金币";
                [purchaseCoinCell.btn_purchase setTitle:@"￥50.00" forState:UIControlStateNormal];
                break;
            case 4:
                purchaseCoinCell.lbl_coins.text = @"10000 金币";
                [purchaseCoinCell.btn_purchase setTitle:@"￥98.00" forState:UIControlStateNormal];
                
                break;
            case 5:
                purchaseCoinCell.lbl_coins.text = @"25000 金币";
                [purchaseCoinCell.btn_purchase setTitle:@"￥238.00" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        
        cell = purchaseCoinCell;

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"enter select row at indexPath");
    
    //2. Share and Checkin
    if (indexPath.section == 1) {
        //Check in
        if (indexPath.row == 0) {
            [self dailyCheckin];
        }
        //Share
        if (indexPath.row == 1) {
            [self share];
        }
        
    }
    //3. Purchase
    if (indexPath.section == 2) {
        
            [self buy:indexPath.row];
        
        }
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
        if (_appData.purchaseTimes == 0) {
            purchasedCoins = 1000;
            _appData.purchaseTimes ++;
            [self.tableView reloadData];
        }else{
            purchasedCoins = 500;
        }
    }
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.25000coins_new"]) {
        purchasedCoins = 25000;
    }
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.1000coins"]) {        
        if (_appData.purchaseTimes == 0) {
            purchasedCoins = 2000;
            _appData.purchaseTimes ++;
            [self.tableView reloadData];
        }else{
            purchasedCoins = 1000;
        }
    }
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.2500coins"]) {
        purchasedCoins = 2500;
    }
    
    if ([productIdentifier isEqualToString:@"DSoft.com.Daoting.5000coins"]) {
        purchasedCoins = 5000;
    }
    
    _appData.coins = _appData.coins + purchasedCoins;
    
    //record purchase coins activity to database
    [[PurchaseRecordsHelper sharedInstance] purchaseCoins:purchasedCoins];
    
    [_appData save];
    [_appData saveToiCloud];

    [TSMessage showNotificationWithTitle:[NSString stringWithFormat:@"成功购买金币 %d 枚", purchasedCoins] type:TSMessageNotificationTypeSuccess];
    
    //self.tableView.allowsSelection = YES;
}

- (void)onLoadedProducts
{
    [_spinner stopAnimating];
}

- (void)onTransactionFailed
{
    [TSMessage showNotificationInViewController:self title:nil subtitle:@"无法连接App Store, 请检查网络" type:TSMessageNotificationTypeSuccess duration:2.0];
    [_spinner stopAnimating];
    
    //self.tableView.allowsSelection = YES;
}

- (void)dailyCheckin
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
        
        _appData.coins += 10;
        [_appData save];
        [_appData saveToiCloud];
        
        CurrentCoinCell* currentCoinCell = (CurrentCoinCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        currentCoinCell.lbl_currentCoins.text = [NSString stringWithFormat:@"%ld 枚", (long)_appData.coins];
        
        NSString *notification = @"您获得了 10金币";
        [TSMessage showNotificationInViewController:self title:notification subtitle:nil type:TSMessageNotificationTypeSuccess];
    }
    else
    {
        NSString *notification = @"您今日已经签到了，请明日再试";
        [TSMessage showNotificationInViewController:self title:notification subtitle:nil type:TSMessageNotificationTypeWarning];
    }
}

- (void)share
{
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"AppIcon@2x" ofType:@"png"];
    
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
                                     _appData.coins = _appData.coins + 10;
                                     NSString *notification = @"您获得了 10金币";
                                     [_appData save];
                                     [_appData saveToiCloud];
                                     
                                     CurrentCoinCell* currentCoinCell = (CurrentCoinCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                                     currentCoinCell.lbl_currentCoins.text = [NSString stringWithFormat:@"%ld 枚", (long)_appData.coins];
                                     
                                     [TSMessage showNotificationInViewController:self title:notification subtitle:nil type:TSMessageNotificationTypeSuccess];
                                 }
                                 else if (state == SSResponseStateFail)
                                 {
                                     NSLog(@"分享失败,错误码:%ld,错误描述:%@", (long)[error errorCode], [error errorDescription]);
                                 }
                             }];
}

@end
