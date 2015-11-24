//
//  satisticsTableViewController.m
//  runningRhythm
//
//  Created by saintPN on 15/11/15.
//  Copyright © 2015年 saintPN. All rights reserved.
//

#import "satisticsTableViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "RUN.h"


@interface satisticsTableViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) NSArray *runArray;

@property (strong, nonatomic) NSMutableArray *durationArray;

@property (strong, nonatomic) NSMutableArray *distanceArray;

@property float distance;

@property NSInteger totalTime;

@property (strong, nonatomic) NSNumber *bestDuration;

@property (strong, nonatomic) NSNumber *bestDistance;

@property (strong, nonatomic) NSDate *firstRunDate;

@end


@implementation satisticsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    //历史记录
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    self.managedObjectModel = [appDelegate managedObjectModel];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    fetch.entity = entity;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    fetch.sortDescriptors = @[sortDescriptor];
    self.runArray = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    
    //最佳时间和最佳距离
    RUN *initialRun = self.runArray.firstObject;
    for (RUN *run in self.runArray) {
        if (initialRun.duration < run.duration) {
            initialRun.duration = run.duration;
        }
        if (initialRun.distance < run.distance) {
            initialRun.distance = run.distance;
        }
        
        //奔跑距离
        self.distance += [run.distance floatValue];
        self.bestDuration = initialRun.duration;
        self.bestDistance = initialRun.distance;
    }
    
    //开跑日期
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.firstRunDate = [defaults objectForKey:@"firstRunDate"];
    self.totalTime = [defaults integerForKey:@"totalTime"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"statisticsCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateIntervalFormatterLongStyle;
        formatter.timeStyle = NSDateIntervalFormatterShortStyle;
        cell.detailTextLabel.text = [formatter stringFromDate:self.firstRunDate];
        cell.textLabel.text = @"开跑日期";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"奔跑距离";
        if (self.distance > 1000) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f公里", self.distance/1000];
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.0f米", self.distance];
        }
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"奔跑时长";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld分%ld秒", self.totalTime/60,self.totalTime%60];
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"最佳时间";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld分%ld秒", [self.bestDuration integerValue]/60, [self.bestDuration integerValue]%60];
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"最佳距离";
        if ([self.bestDistance floatValue]> 1000) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.3f公里", [self.bestDistance floatValue]/1000];
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.0f米", [self.bestDistance floatValue]];

        }
    }
    
    return cell;
}




















@end
