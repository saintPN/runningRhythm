//
//  saintPNTableViewController.m
//  runningRhythm
//
//  Created by saintPN on 15/10/26.
//  Copyright © 2015年 saintPN. All rights reserved.
//

#import "saintPNTableViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "RUN.h"

@interface saintPNTableViewController ()

@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic)NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) NSArray *runArray;

@property (strong, nonatomic) NSMutableArray *durationArray;

@property (strong, nonatomic) NSNumber *bestRecord;

@property (strong, nonatomic) NSDate *bestRecordDate;

@end

@implementation saintPNTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self allInit];
    [self getRecordAndBestRecord];
}

#pragma mark - 统一初始化

- (void)allInit {
    self.runArray = [[NSArray alloc] init];
    self.durationArray = [[NSMutableArray alloc] init];
    self.bestRecord = [[NSNumber alloc] init];
    self.bestRecordDate = [[NSDate alloc] init];
}

#pragma mark - 获取数据

- (void)getRecordAndBestRecord {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    self.managedObjectModel = [appDelegate managedObjectModel];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RUN" inManagedObjectContext:self.managedObjectContext];
    fetch.entity = entity;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    fetch.sortDescriptors = @[sortDescriptor];
    self.runArray = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    
    for (RUN *run in self.runArray) {
        [self.durationArray addObject:run.duration];
    }
    self.bestRecord = [self.durationArray valueForKeyPath:@"@max.floatValue"];
    for (RUN *run in self.runArray) {
        if (run.duration == self.bestRecord) {
            self.bestRecordDate = run.date;
        }
    }
}

#pragma mark - 设置tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return self.runArray.count;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"奔跑时长";
    } else  if (section == 1){
        return @"最佳记录";
    } else {
        return @"历史记录";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recordCell" forIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateIntervalFormatterLongStyle;
    formatter.timeStyle = NSDateIntervalFormatterShortStyle;
    
    if (indexPath.section == 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        cell.textLabel.text = [NSString stringWithFormat:@"%ld分%ld秒", (long)[defaults integerForKey:@"totalTime"]/60, (long)[defaults integerForKey:@"totalTime"]%60];
        cell.detailTextLabel.text = @"";
    } else if (indexPath.section ==1){
        cell.textLabel.text = [formatter stringFromDate:self.bestRecordDate];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld分%ld秒", [self.bestRecord integerValue]/60,[self.bestRecord integerValue]%60];
    } else {
        RUN *run = self.runArray[indexPath.row];
        cell.textLabel.text = [formatter stringFromDate:run.date];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@分钟", run.duration];
    }
    return cell;
}

@end
