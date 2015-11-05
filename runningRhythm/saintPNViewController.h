//
//  ViewController.h
//  runningRhythm
//
//  Created by saintPN on 15/8/6.
//  Copyright (c) 2015年 saintPN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "saintPNDataModel.h"
#import "AppDelegate.h"
#import "RUN.h"


@interface saintPNViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIPickerView *timePickerView;

@property (strong, nonatomic) NSArray *dataArray;

@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;

@property (weak, nonatomic) IBOutlet UISlider *musicSlider;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) saintPNDataModel *dataModel;

@property (strong, nonatomic) AVAudioPlayer *player;

@property (strong, nonatomic) dispatch_source_t timer;

@property (weak, nonatomic) IBOutlet UISlider *timeSlider;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *onceLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property BOOL isPlaying;

@property __block NSInteger runTime;

@property __block NSInteger countdownTime;

@property __block NSInteger totalTime;

@property NSInteger playingNumber;

@end

