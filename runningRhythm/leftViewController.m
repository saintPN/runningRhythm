//
//  leftViewController.m
//  runningRhythm
//
//  Created by saintPN on 15/8/30.
//  Copyright (c) 2015年 saintPN. All rights reserved.
//

#import "leftViewController.h"
#import "saintPNDataModel.h"
#import "RESideMenu.h"


@interface leftViewController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) saintPNDataModel *dataModel;

@end

@implementation leftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getting];
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 54 * 6) / 2, self.view.frame.size.width, 54 * 6.65) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView.scrollsToTop = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
    self.label = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, (self.view.frame.size.height - 54 * 10), 100, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor cyanColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
        label.text = @"音乐列表";
        label;
    });
    [self.view addSubview:self.label];
    
}

- (void)getting {
    self.dataModel = [[saintPNDataModel alloc] init];
    [self.dataModel getiPODMusic];
    [self.dataModel getSandBoxMusic];
}

#pragma mark - TableView 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataModel.songNamesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"leftTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    }
    cell.textLabel.text = self.dataModel.songNamesArray[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:indexPath.row forKey:@"songNumber"];
    
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"saintPNViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.sideMenuViewController setContentViewController:nav animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}

@end
