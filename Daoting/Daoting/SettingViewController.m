//
//  SettingViewController.m
//  Daoting
//
//  Created by Kevin on 14/6/27.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rowcount = 0;
    
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
    }
    
    if (section == 1) {
        return 2;
    }

    return rowcount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCellSwitch" forIndexPath:indexPath];
        
        SettingCellSwitch *switchCell = (SettingCellSwitch*)cell;
        switchCell.lbl_Title.text = @"自动购买";
        
        switchCell.sw_option.on = _appData.isAutoPurchase;
        [switchCell.sw_option addTarget:self action:@selector(onSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    if ((indexPath.section == 0) && (indexPath.row == 1)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCellDisclosure" forIndexPath:indexPath];
        
        SettingCellDisclosure *disclosureCell = (SettingCellDisclosure *)cell;
        disclosureCell.lbl_Title.text = @"已购买曲目";
    }
    
    if ((indexPath.section == 1) && (indexPath.row == 0))
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCellDisclosure" forIndexPath:indexPath];
        
        SettingCellDisclosure *disclosureCell = (SettingCellDisclosure *)cell;
        disclosureCell.lbl_Title.text = @"清空缓存";
    }
    
    if ((indexPath.section == 1) && (indexPath.row == 1))
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCellDisclosure" forIndexPath:indexPath];
        
        SettingCellDisclosure *disclosureCell = (SettingCellDisclosure *)cell;
        disclosureCell.lbl_Title.text = @"测试";
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0))
    {

    }
    
    if ((indexPath.section == 0) && (indexPath.row == 1))
    {

    }
    
    if ((indexPath.section == 1) && (indexPath.row == 0))
    {
        [self performSegueWithIdentifier:@"showClearCache" sender:nil];
    }
    
    if ((indexPath.section == 1) && (indexPath.row == 1))
    {
        
    }

}

#pragma mark UI Operation

- (void)onSwitchValueChanged:(UISwitch *)sender
{
    _appData.isAutoPurchase = sender.isOn;
    [_appData save];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPurchasedList"] ) {
        //UIViewController *viewController = segue.destinationViewController;
        //viewController.yourVariable = yourData;
    }
    
    if ([segue.identifier isEqualToString:@"showClearCache"] ) {
        ClearCacheViewController *viewController = segue.destinationViewController;
    }
}


@end
