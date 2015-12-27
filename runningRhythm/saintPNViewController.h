//
//  ViewController.h
//  runningRhythm
//
//  Created by saintPN on 15/8/6.
//  Copyright (c) 2015年 saintPN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "saintPNDataModel.h"
#import "AppDelegate.h"
#import "RUN.h"
#import "Location.h"


@interface saintPNViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) NSArray *dataArray;

@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;

@property (weak, nonatomic) IBOutlet UISlider *musicSlider;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSMutableArray *locationsArray;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (strong, nonatomic) RUN *run;

@property (strong, nonatomic) saintPNDataModel *dataModel;

@property (strong, nonatomic) AVAudioPlayer *player;

@property (strong, nonatomic) dispatch_source_t timer;

@property (weak, nonatomic) IBOutlet UISlider *timeSlider;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) CALayer *layer;

@property BOOL isPlaying;

@property __block NSInteger runTime;

@property __block NSInteger countdownTime;

@property __block NSInteger totalTime;

@property NSInteger playingNumber;

@property float distance;

@end

