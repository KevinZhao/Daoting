//
//  SettingViewController.m
//  Daoting
//
//  Created by Kevin on 14/6/27.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "SettingViewController.h"

#define Number_Of_Section 3

#define Section_User    0
//#define Section_PlayHistory 1
#define Section_Setting 1
#define Section_Clear   2

@implementation SettingViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    _appData = [AppData sharedAppData];
    _appdelegate = [[UIApplication sharedApplication] delegate];
    
    //QQ login
    _sharedUserManagement = [UserManagement sharedManager];
    _sharedUserManagement.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    _appData = nil;
    _appdelegate = nil;
    
    _sharedUserManagement.delegate = nil;
    _sharedUserManagement = nil;
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
    return Number_Of_Section;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (section == Section_User) {
        return 1;
    }
    
    if (section == Section_Setting) {
        return 2;
    }
    
    if (section == Section_Clear) {
        return 1;
    }

    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ((indexPath.section == Section_Setting) && (indexPath.row == 0)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCellSwitch" forIndexPath:indexPath];
        
        SettingCellSwitch *switchCell = (SettingCellSwitch*)cell;
        switchCell.lbl_Title.text = @"自动购买";
        
        [switchCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        switchCell.sw_option.on = _appData.isAutoPurchase;
        [switchCell.sw_option setTintColor:_appdelegate.defaultColor_dark];
        
        [switchCell.sw_option addTarget:self action:@selector(onSwitchValueChanged1:) forControlEvents:UIControlEventValueChanged];
    }
    
    if ((indexPath.section == Section_Setting) && (indexPath.row == 1)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCellSwitch" forIndexPath:indexPath];
        
        SettingCellSwitch *switchCell = (SettingCellSwitch *)cell;
        switchCell.lbl_Title.text = @"开机自动播放";
        
        [switchCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        switchCell.sw_option.on = _appData.isAutoPlay;
        [switchCell.sw_option setTintColor:_appdelegate.defaultColor_dark];
        [switchCell.sw_option addTarget:self action:@selector(onSwitchValueChanged2:) forControlEvents:UIControlEventValueChanged];
    }
    
    /*if ((indexPath.section == Section_PlayHistory) && (indexPath.row == 0)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCellDisclosure" forIndexPath:indexPath];
        
        SettingCellSwitch *switchCell = (SettingCellSwitch*)cell;
        switchCell.lbl_Title.text = @"我正在听";
    }*/
    
    if ((indexPath.section == Section_Clear) && (indexPath.row == 0))
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCellDisclosure" forIndexPath:indexPath];
        
        SettingCellDisclosure *disclosureCell = (SettingCellDisclosure *)cell;
        disclosureCell.lbl_Title.text = @"清空缓存";
    }
    
    if ((indexPath.section == Section_User) && (indexPath.row == 0))
    {

        cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
        UserCell *userCell = (UserCell*)cell;
        
        //用户曾经登陆过
        if (_appData.WX_OpenId != nil) {
            
            userCell.lbl_UserName.text = _appData.WX_NickName;
            NSURLRequest *request = [NSURLRequest requestWithURL: _appData.WX_HeadImgUrl];
            
            UIImage *placeholderImage = [UIImage imageNamed:@"Icon-72.png"];
            __weak UserCell *weakCell = userCell;
            
            [userCell.img_User setImageWithURLRequest:request
                                     placeholderImage:placeholderImage
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 [weakCell.img_User setImage:[image roundedRectWith:32]];
                 [weakCell setNeedsLayout];
             }failure:nil];
        }
        //用户未登陆过
        else{
            
            userCell.img_User.image = [[UIImage imageNamed:@"Icon-72.png"] roundedRectWith:2];;
            userCell.lbl_UserName.text = @"使用微信登陆";
        }
        
        userCell.lbl_coins.text = [NSString stringWithFormat:@"%ld", (long)_appData.coins];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == Section_User) {
        return 100;
    }else{
        return tableView.rowHeight;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if ((indexPath.section == Section_User) && (indexPath.row == 0)){
        
        [_sharedUserManagement login:LoginTypeWeChat];
    }*/
    
    if ((indexPath.section == Section_Clear) && (indexPath.row == 0))
    {
        [self performSegueWithIdentifier:@"showClearCache" sender:nil];
    }
    
    /*if ((indexPath.section == Section_PlayHistory) && (indexPath.row == 0))
    {
        //[self performSegueWithIdentifier:@"showPurchasedSongs" sender:nil];
    }*/
}

#pragma mark UI Operation

- (void)onSwitchValueChanged1:(UISwitch *)sender
{
    _appData.isAutoPurchase = sender.isOn;
    [_appData save];
}

- (void)onSwitchValueChanged2:(UISwitch *)sender
{
    _appData.isAutoPlay = sender.isOn;
    [_appData save];
}


#pragma mark - Navigation

/*// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPurchasedList"] ) {
        //UIViewController *viewController = segue.destinationViewController;
        //viewController.yourVariable = yourData;
    }
    
    if ([segue.identifier isEqualToString:@"showClearCache"] ) {
        //ClearCacheViewController *viewController = segue.destinationViewController;
    }
}*/

-(void) onUserDidLogin
{
    //取得 UserCell
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:Section_User];
    UserCell* userCell = (UserCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    //更新用户昵称
    userCell.lbl_UserName.text = _sharedUserManagement.nickName;
     
    //更新用户头像
    NSURLRequest *request = [NSURLRequest requestWithURL: _sharedUserManagement.headerIconUrl];
    UIImage *placeholderImage = [UIImage imageNamed:@"Icon-72.png"];
    
    __weak UserCell *weakCell = userCell;
    
    [userCell.img_User setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
    {
        [weakCell.img_User setImage:image];
        [weakCell setNeedsLayout];
    
    }
        failure:nil];
}


@end
