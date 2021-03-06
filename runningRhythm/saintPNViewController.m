//
//  ViewController.m
//  runningRhythm
//
//  Created by saintPN on 15/8/6.
//  Copyright (c) 2015年 saintPN. All rights reserved.
//

#import "saintPNViewController.h"
#import "saintPNTableViewController.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@implementation saintPNViewController

#pragma mark - 视图生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self doInit];
    [self.dataModel getiPODMusic];
    [self.dataModel getSandBoxMusic];
    [self.dataModel getSandBoxImage];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showingTime) userInfo:nil repeats:YES];
    if (self.dataModel.imageURLArray.count) {
        [self userBackGroundImage];
    } else {
        [self randomBackGroundImage];
    }

    self.speedLabel.text = @"速度:0.0米/秒";
    self.distanceLabel.text = @"距离:0.0公里";
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults integerForKey:@"songNumber"]) {
        self.playingNumber = [defaults integerForKey:@"songNumber"];
        [self.player pause];
        [self playerReload];
        self.nameLabel.text = [NSString stringWithFormat:@"当前歌曲:%@", self.dataModel.songNamesArray[self.playingNumber]];
        [defaults removeObjectForKey:@"songNumber"];
    }
    if ([defaults integerForKey:@"countdownTime"]) {
        [self countdownWithTime:[defaults integerForKey:@"countdownTime"]];
    }
    [self configPlayingInfo];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    [self.player pause];
    self.timer = nil;
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - 初始化

- (void)doInit {
    //统一初始化,以免遗漏
    self.dataArray = [[NSArray alloc] init];
    self.dataModel = [[saintPNDataModel alloc] init];
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.locationsArray = [[NSMutableArray alloc] init];

}

- (void)ifMusicExit {
    //判断是否存在音乐文件,如果没有弹出提示窗口
    if (!self.dataModel.songURLArray.count) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"未发现音乐文件,请通过iTunes添加音乐!"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    self.playingNumber = arc4random() % self.dataModel.songURLArray.count;
    [self playerReload];
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

#pragma mark - 按钮事件

- (IBAction)helpInfo:(UIBarButtonItem *)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"帮助"
                                                                   message:@"向右滑动查看音乐,向左滑动查看说明"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"明白" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction)countDown:(UIButton *)sender {
    __weak __typeof (self) weakSelf = self;
    [self startLocating];
    if (self.timer) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"countdownTime"];
    if (![defaults objectForKey:@"firstRunDate"]) {
        [defaults setObject:[NSDate date] forKey:@"firstRunDate"];
    }
    self.totalTime = [defaults integerForKey:@"totalTime"];
    self.countdownTime = 0;
    self.runTime = 0;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(self.timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        weakSelf.countdownTime++;
        [defaults setInteger:weakSelf.countdownTime forKey:@"countdownTime"];
        weakSelf.totalTime ++;
        [defaults setInteger:weakSelf.totalTime forKey:@"totalTime"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger min = weakSelf.countdownTime / 60;
            NSInteger sec = weakSelf.countdownTime % 60;
            if (sec < 10) {
                weakSelf.countdownLabel.text = [NSString stringWithFormat:@"%ld:0%ld", (long)min,(long)sec];
            } else {
                weakSelf.countdownLabel.text = [NSString stringWithFormat:@"%ld:%ld", (long)min,(long)sec];
            }
            weakSelf.speedLabel.text = [NSString stringWithFormat:@"速度:%0.1f米/秒", weakSelf.distance/weakSelf.countdownTime];
            weakSelf.distanceLabel.text = [NSString stringWithFormat:@"距离:%0.1f公里", self.distance/1000];

        });
        weakSelf.runTime++;
    });
    dispatch_resume(weakSelf.timer);
}

- (void)countdownWithTime:(NSInteger)time {
    __weak __typeof (self) weakSelf = self;
    self.countdownTime = time;
    [self startLocating];
    if (self.timer) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"countdownTime"];
    self.totalTime = [defaults integerForKey:@"totalTime"];
    self.runTime = 0;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(self.timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        weakSelf.countdownTime++;
        [defaults setInteger:weakSelf.countdownTime forKey:@"countdownTime"];
        weakSelf.totalTime ++;
        [defaults setInteger:weakSelf.totalTime forKey:@"totalTime"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger min = weakSelf.countdownTime / 60;
            NSInteger sec = weakSelf.countdownTime % 60;
            if (sec < 10) {
                weakSelf.countdownLabel.text = [NSString stringWithFormat:@"%ld:0%ld", (long)min,(long)sec];
            } else {
                weakSelf.countdownLabel.text = [NSString stringWithFormat:@"%ld:%ld", (long)min,(long)sec];
            }
            weakSelf.speedLabel.text = [NSString stringWithFormat:@"速度:%0.1f米/秒", weakSelf.distance/60];
            weakSelf.distanceLabel.text = [NSString stringWithFormat:@"距离:%0.1f公里", weakSelf.distance/1000];
        });
        weakSelf.runTime++;
    });
    dispatch_resume(weakSelf.timer);
}

- (IBAction)reset:(UIButton *)sender {
    __weak __typeof (self) weakSelf = self;
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"保存"
                                                                   message:@"保存本次数据?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction1 = [UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleCancel
                                                                        handler:^(UIAlertAction * action) {
                                                                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                                            if ([defaults integerForKey:@"countdownTime"]) {
                                                                                [defaults removeObjectForKey:@"countdownTime"];
                                                                            }
                                                                            if (weakSelf.locationManager) {
                                                                                [weakSelf.locationManager stopUpdatingLocation];
                                                                              }
                                                                            weakSelf.timer = nil;
                                                                            weakSelf.distance = 0;
                                                                            weakSelf.countdownTime = 0;
                                                                            weakSelf.countdownLabel.text = @"00:00";
                                                                            weakSelf.speedLabel.text = @"速度:0.0米/秒";
                                                                            weakSelf.distanceLabel.text = @"距离:0.0公里";
                                                                          }];
    UIAlertAction* defaultAction2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * action) {
                                                                   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                                   if ([defaults integerForKey:@"countdownTime"]) {
                                                                       [defaults removeObjectForKey:@"countdownTime"];
                                                                   }
                                                                   if (weakSelf.locationManager) {
                                                                       [weakSelf.locationManager stopUpdatingLocation];
                                                                   }
                                                                   [weakSelf saveRun];
                                                                   [weakSelf saveAnimation];
                                                                   weakSelf.timer = nil;
                                                                   weakSelf.distance = 0;
                                                                   weakSelf.countdownTime = 0;
                                                                   weakSelf.countdownLabel.text = @"00:00";
                                                                   weakSelf.speedLabel.text = @"速度:0.0米/秒";
                                                                   weakSelf.distanceLabel.text = @"距离:0.0公里";
                                                               }];
        
    [alert addAction:defaultAction1];
    [alert addAction:defaultAction2];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - 保存记录

- (void)saveRun {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    self.managedObjectModel = [appDelegate managedObjectModel];
    
    RUN *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run" inManagedObjectContext:self.managedObjectContext];
    newRun.duration = [NSNumber numberWithInteger:self.runTime];
    newRun.distance = [NSNumber numberWithFloat:self.distance];
    newRun.date = [NSDate date];
    
    NSMutableArray *array = [NSMutableArray array];
    for (CLLocation *location in self.locationsArray) {
        Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        locationObject.date = location.timestamp;
        locationObject.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        locationObject.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        [array addObject:locationObject];
    }
    newRun.locations = [NSOrderedSet orderedSetWithArray:array];
    self.run = newRun;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"出现错误:%@, %@", error, [error userInfo]);
        abort();
    }
}

//保存动画
- (void)saveAnimation {
    self.layer = [CALayer layer];
    self.layer.frame = CGRectMake(16, 575, 51, 50);
    self.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"run"].CGImage);
    self.layer.cornerRadius = CGRectGetHeight(self.layer.bounds)/2;
    self.layer.masksToBounds = YES;
    [self.view.layer addSublayer:self.layer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.layer.position];
    [path addQuadCurveToPoint:CGPointMake(SCREEN_WIDTH-40, SCREEN_HEIGHT/9) controlPoint:CGPointMake(SCREEN_WIDTH/5, SCREEN_HEIGHT/3)];
    
    CAKeyframeAnimation *a1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    a1.path = path.CGPath;
    a1.rotationMode = kCAAnimationRotateAuto;
    
    CABasicAnimation *a2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    a2.duration = 0.5f;
    a2.fromValue = [NSNumber numberWithFloat:1];
    a2.toValue = [NSNumber numberWithFloat:3];
    a2.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *a3 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    a3.beginTime = 0.5;
    a3.fromValue = [NSNumber numberWithFloat:3];
    a3.duration = 1.5f;
    a3.toValue = [NSNumber numberWithFloat:1];
    a3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[a1, a2, a3];
    group.duration = 2;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.delegate = self;
    
    [self.layer addAnimation:group forKey:@"group"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.layer removeFromSuperlayer];
}

#pragma mark - 播放器逻辑

- (IBAction)play:(UIButton *)sender {
    if (!self.dataModel.songURLArray.count) {
        [self ifMusicExit];
        return;
    }
    if (!self.player) {
        self.playingNumber = arc4random() % self.dataModel.songURLArray.count;
        [self playerReload];
        self.nameLabel.text = [NSString stringWithFormat:@"当前歌曲:%@", self.dataModel.songNamesArray[self.playingNumber]];
        return;
    }
    if (!self.isPlaying) {
        [self.player play];
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        self.isPlaying = YES;
    } else {
        [self.player pause];
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        self.isPlaying = NO;
    }
    self.nameLabel.text = [NSString stringWithFormat:@"当前歌曲:%@", self.dataModel.songNamesArray[self.playingNumber]];
}

- (IBAction)next:(UIButton *)sender {
    if (!self.dataModel.songURLArray.count) {
        return;
    }
    
    if (self.playingNumber == self.dataModel.songURLArray.count - 1) {
        self.playingNumber = 0;
    } else {
        self.playingNumber ++;
    }
    [self playerReload];
    self.nameLabel.text = [NSString stringWithFormat:@"当前歌曲:%@", self.dataModel.songNamesArray[self.playingNumber]];
}

- (IBAction)previous:(UIButton *)sender {
    if (!self.dataModel.songURLArray.count) {
        return;
    }
    
    if (self.playingNumber == 0) {
        self.playingNumber = self.dataModel.songURLArray.count - 1;
    } else {
        self.playingNumber --;
    }
    [self playerReload];
    self.nameLabel.text = [NSString stringWithFormat:@"当前歌曲:%@", self.dataModel.songNamesArray[self.playingNumber]];
}

- (IBAction)timeChange:(UISlider *)sender {
    self.player.currentTime = self.timeSlider.value * self.player.duration;
}

- (void)playerReload {
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[self.dataModel.songURLArray objectAtIndex:self.playingNumber] error:nil];
    [self.player play];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    self.isPlaying = YES;
}

- (void)showingTime {
    self.timeSlider.value = self.player.currentTime / self.player.duration;
    
    if (self.timeSlider.value > 0.99) {
        [self goNext];
    }
}

#pragma mark - 锁屏控制

- (void)configPlayingInfo {
    if (NSClassFromString(@"MPNoewPlayingInfoCenter")) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:self.dataModel.songNamesArray[self.playingNumber] forKey:MPMediaItemPropertyTitle];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self goPlay];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self goNext];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self backPrevious];
                break;
            default:
                break;
        }
    }
}

- (void)goPlay {
    if (!self.isPlaying) {
        [self.player play];
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        self.isPlaying = YES;
    } else {
        [self.player pause];
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        self.isPlaying = NO;
    }
}

- (void)goNext {
    if (self.playingNumber == self.dataModel.songURLArray.count - 1) {
        self.playingNumber = 0;
    } else {
        self.playingNumber ++;
    }
    [self playerReload];
}

- (void)backPrevious {
    if (self.playingNumber == 0) {
        self.playingNumber = self.dataModel.songURLArray.count;
    } else {
        self.playingNumber --;
    }
    [self playerReload];
}

#pragma mark - CLLocationManagerDelegate

- (void)startLocating {
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.distanceFilter = 3;
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    for (CLLocation *newLocation in locations) {
        NSDate *date = newLocation.timestamp;
        NSTimeInterval timeInterval = [date timeIntervalSinceNow];
        
        if (fabs(timeInterval)<10 && newLocation.horizontalAccuracy<12) {
            
            if (self.locationsArray.count > 0) {
                self.distance += [newLocation distanceFromLocation:self.locationsArray.lastObject];
                CLLocationCoordinate2D coordinates[2];
                coordinates[0] = ((CLLocation *)self.locationsArray.lastObject).coordinate;
                coordinates[1] = newLocation.coordinate;
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 100, 100);
                [self.mapView setRegion:region animated:YES];
                [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coordinates count:2]];
            }
            [self.locationsArray addObject:newLocation];
        }
    }
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        renderer.strokeColor = [UIColor redColor];
        renderer.lineWidth = 3;
        
        return renderer;
    }
    return nil;
}

@end
