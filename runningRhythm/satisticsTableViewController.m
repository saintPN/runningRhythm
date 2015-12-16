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
#import "saintPNDataModel.h"


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

@property (strong, nonatomic) saintPNDataModel *dataModel;

@property (strong, nonatomic) UIImageView *imageView;

@end


@implementation satisticsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    if (self.dataModel.imageURLArray.count) {
        [self userBackGroundImage];
    } else {
        [self randomBackGroundImage];
    }

    
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

- (IBAction)shareToWeixin:(UIBarButtonItem *)sender {
    if ([WXApi isWXAppInstalled]) {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [app.window.layer renderInContext:context];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"分享到微信朋友圈?"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* defaultAction1 = [UIAlertAction actionWithTitle:@"分享"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   WXImageObject *imageObject = [WXImageObject object];
                                                                   imageObject.imageData = UIImageJPEGRepresentation(image, 1);
                                                                   WXMediaMessage *mediaMessage = [WXMediaMessage message];
                                                                   mediaMessage.mediaObject = imageObject;
                                                                   SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
                                                                   request.bText = NO;
                                                                   request.message = mediaMessage;
                                                                   request.scene = WXSceneTimeline;
                                                                   [WXApi sendReq:request];
                                                               }];
        UIAlertAction* defaultAction2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                               handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction1];
        [alert addAction:defaultAction2];
        
        [self presentViewController:alert animated:YES completion:nil];

    } else {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"错误"
                                                                       message:@"未安装微信!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel
                                                               handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction1];
    }
}

#pragma mark - 设置背景图片

- (void)randomBackGroundImage {
    //随机使用自带图片设为背景
    NSInteger i = arc4random() % 9 + 1;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"Image%ld", (long)i]];
    self.imageView.image = image;
    
    [self.view insertSubview:self.imageView atIndex:0];
}

- (void)userBackGroundImage {
    //随机使用用户导入图片设为背景
    NSInteger i = arc4random() % self.dataModel.imageURLArray.count + 1;
    UIImage *image = [UIImage imageWithContentsOfFile:self.dataModel.imageURLArray[i]];
    self.imageView.image = image;
    
    [self.view insertSubview:self.imageView atIndex:0];
}

@end
