//
//  ViewController.m
//  runningRhythm
//
//  Created by saintPN on 15/8/6.
//  Copyright (c) 2015年 saintPN. All rights reserved.
//

#import "saintPNViewController.h"
#import "saintPNTableViewController.h"


@implementation saintPNViewController

#pragma mark - 视图生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self doInit];
    [self settingPickerView];
    [self.dataModel getiPODMusic];
    [self.dataModel getSandBoxMusic];
    [self.dataModel getSandBoxImage];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showingTime) userInfo:nil repeats:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults integerForKey:@"row"] >= 0) {
        [self.timePickerView selectRow:[defaults integerForKey:@"row"] inComponent:0 animated:YES];
    } else {
        [self.timePickerView selectRow:2 inComponent:0 animated:YES];
    }
    
    if (self.dataModel.imageURLArray.count) {
        [self userBackGroundImage];
    } else {
        [self randomBackGroundImage];
    }
    if ([defaults integerForKey:@"totalTime"]) {
        self.totalTime = [defaults integerForKey:@"totalTime"];
    }
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
    NSInteger i = arc4random() % 5 + 1;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"Image%ld", (long)i]];
    self.imageView.image = image;
 
    [self.view insertSubview:self.imageView atIndex:0];
}

- (void)userBackGroundImage {
    //随机使用用户导入图片设为背景
    NSInteger i = arc4random() % self.dataModel.imageURLArray.count;
    UIImage *image = [UIImage imageWithContentsOfFile:self.dataModel.imageURLArray[i]];
    self.imageView.image = image;
    
    [self.view insertSubview:self.imageView atIndex:0];
}

#pragma mark - PickerView

- (void)settingPickerView {
    self.timePickerView.dataSource =self;
    self.timePickerView.delegate = self;
    NSArray *array1 = [[NSArray alloc] initWithObjects:@"10分钟", @"20分钟", @"30分钟", @"40分钟", @"50分钟", @"60分钟", nil];
    self.dataArray = array1;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.dataArray count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 58, 58)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = [self.dataArray objectAtIndex:row];
    
    return label;
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
    
    if (self.timer) {
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"countdownTime"];
    
    [defaults setInteger:[self.timePickerView selectedRowInComponent:0] forKey:@"row"];
    NSString *string1 = [[NSString alloc]initWithString:[self.dataArray objectAtIndex:[self.timePickerView selectedRowInComponent:0]]];
    NSString *string2 = [string1 substringWithRange:NSMakeRange(0, 2)];
    self.countdownTime = [string2 integerValue] * 60;
    self.runTime = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(self.timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        if(weakSelf.countdownTime == 0){
            [weakSelf saveRun];
            [defaults removeObjectForKey:@"countdownTime"];
            dispatch_source_cancel(weakSelf.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.countdownLabel.text = @"完成目标!";
                weakSelf.timer = nil;
                [weakSelf.player pause];
            });
        }else{
            weakSelf.countdownTime--;
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
            });
            weakSelf.runTime++;
        }
    });
    dispatch_resume(weakSelf.timer);

}

- (void)countdownWithTime:(NSInteger)time {
    __weak __typeof (self) weakSelf = self;
    self.countdownTime = time;
    if (self.timer) {
        
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"countdownTime"];
    self.runTime = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(self.timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        if(weakSelf.countdownTime == 0){
            [weakSelf saveRun];
            [defaults removeObjectForKey:@"countdownTime"];
            dispatch_source_cancel(weakSelf.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.countdownLabel.text = @"完成目标!";
                weakSelf.timer = nil;
                [weakSelf.player pause];
            });
        }else{
            weakSelf.countdownTime--;
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
            });
            weakSelf.runTime++;
        }
    });
    dispatch_resume(weakSelf.timer);
}

- (IBAction)reset:(UIButton *)sender {
    [self saveRun];
    self.timer = nil;
    self.countdownTime = 0;
    self.countdownLabel.text = @"00:00";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"countdownTime"];
    self.totalTime = [defaults integerForKey:@"totalTime"];
    
    self.onceLabel.text = [NSString stringWithFormat:@"本次奔跑:%ld分%ld秒", self.runTime / 60, self.runTime % 60];
    self.totalLabel.text = [NSString stringWithFormat:@"累计奔跑:%ld分%ld秒", self.totalTime / 60, self.totalTime % 60];
    
}

#pragma mark - 保存记录

- (void)saveRun {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    self.managedObjectModel = [appDelegate managedObjectModel];
    
    RUN *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"RUN" inManagedObjectContext:self.managedObjectContext];
    newRun.duration = [NSNumber numberWithInteger:self.runTime];
    newRun.date = [NSDate date];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"出现错误:%@, %@", error, [error userInfo]);
        abort();
    }
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

#pragma mark - 远程控制

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

@end
