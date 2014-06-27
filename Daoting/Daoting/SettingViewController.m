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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    // Return the number of rows in the section.
    return 2;
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
        disclosureCell.lbl_Title.text = @"已购买歌曲";
    }
    
    if (indexPath.section == 1)
    {
    cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCellDisclosure" forIndexPath:indexPath];
    }
    return cell;
}

- (void)onSwitchValueChanged:(UISwitch *)sender
{
    _appData.isAutoPurchase = sender.isOn;
    [_appData save];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
