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
#import "traceViewController.h"


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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
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

#pragma mark - 按钮事件

- (IBAction)deleteData:(UIBarButtonItem *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"totalTime"];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"确定清空所有数据?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
    
    __weak typeof (self) wSelf = self;
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction * action) {
                                                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                                        wSelf.managedObjectContext = [appDelegate managedObjectContext];
                                                        wSelf.managedObjectModel = [appDelegate managedObjectModel];
                                                        
                                                        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
                                                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Run" inManagedObjectContext:wSelf.managedObjectContext];
                                                        fetch.includesPropertyValues = NO;
                                                        fetch.entity = entity;
                                                        
                                                        NSError *error = nil;
                                                        NSArray *datas = [wSelf.managedObjectContext executeFetchRequest:fetch error:&error];
                                                        if (!error && datas && [datas count]) {
                                                            for (NSManagedObject *obj in datas) {
                                                                [wSelf.managedObjectContext deleteObject:obj];
                                                            }
                                                            if (![wSelf.managedObjectContext save:&error]) {
                                                                NSLog(@"出现错误:%@", error);
                                                            }
                                                        }
                                                        [wSelf.tableView reloadData];
                                                        [wSelf.navigationController popViewControllerAnimated:YES];
                                                        
                                                    }];
    [alert addAction:action1];
    [alert addAction:action2];

    [self presentViewController:alert animated:YES completion:nil];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, 22)];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"奔跑时长";
        [view addSubview:label];
        return view;
    } else  if (section == 1){
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, 22)];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"最佳记录";
        [view addSubview:label];
        return view;
    } else {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, 22)];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"历史记录";
        [view addSubview:label];
        return view;
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
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld分%ld秒", [run.duration integerValue]/60,[run.duration integerValue]%60];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        [self performSegueWithIdentifier:@"detailSegue" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"statisticsSegue" sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[traceViewController class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RUN *run = self.runArray[indexPath.row];
        [(traceViewController *)[segue destinationViewController] setRun:run];
    }
}


















@end
