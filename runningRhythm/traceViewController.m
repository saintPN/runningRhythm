//
//  traceViewController.m
//  runningRhythm
//
//  Created by saintPN on 15/11/14.
//  Copyright © 2015年 saintPN. All rights reserved.
//

#import "traceViewController.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>
#import "Location.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "saintPNDataModel.h"


@interface traceViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@property (strong, nonatomic) saintPNDataModel *dataModel;

@property (strong, nonatomic) UIImageView *imageView;

@end


@implementation traceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self settingUI];
    [self mapRegion];
    [self drawLine];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    if (self.dataModel.imageURLArray.count) {
        [self userBackGroundImage];
    } else {
        [self randomBackGroundImage];
    }
}

- (void)settingUI {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateIntervalFormatterLongStyle;
    formatter.timeStyle = NSDateIntervalFormatterShortStyle;
    self.dateLabel.text = [formatter stringFromDate:self.run.date];
    
    if ([self.run.distance floatValue] > 1000) {
        self.distanceLabel.text = [NSString stringWithFormat:@"奔跑距离:%0.3f公里", [self.run.distance floatValue]/1000];
    } else {
        self.distanceLabel.text = [NSString stringWithFormat:@"奔跑距离:%0.0f米", [self.run.distance floatValue]];
        
    }
    self.durationLabel.text = [NSString stringWithFormat:@"奔跑时间:%ld分%ld秒", [self.run.duration integerValue]/60,[self.run.duration integerValue]%60];
    self.speedLabel.text = [NSString stringWithFormat:@"奔跑速度:%ld米/秒", [self.run.distance integerValue]/[self.run.duration integerValue]];
}

- (void)drawLine {
    int i;
    CLLocationCoordinate2D locationArray[[self.run.locations count]];
    for (i=0; i<[self.run.locations count]; i++) {
        locationArray[i] = CLLocationCoordinate2DMake([self.run.locations[i].latitude doubleValue], [self.run.locations[i].longitude doubleValue]);
    }
    [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:locationArray count:[self.run.locations count]]];
}

- (void)mapRegion {
    MKCoordinateRegion region;
    Location *initialLoc = self.run.locations.firstObject;
    
    float minLat = initialLoc.latitude.floatValue;
    float minLng = initialLoc.longitude.floatValue;
    float maxLat = initialLoc.latitude.floatValue;
    float maxLng = initialLoc.longitude.floatValue;
    
    for (Location *location in self.run.locations) {
        if (location.latitude.floatValue < minLat) {
            minLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue < minLng) {
            minLng = location.longitude.floatValue;
        }
        if (location.latitude.floatValue > maxLat) {
            maxLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue > maxLng) {
            maxLng = location.longitude.floatValue;
        }
    }
    
    region.center.latitude = (minLat + maxLat) / 2.0f;
    region.center.longitude = (minLng + maxLng) / 2.0f;
    
    region.span.latitudeDelta = (maxLat - minLat) * 1.2;
    region.span.longitudeDelta = (maxLng - minLng) * 1.2 ;
    
    self.mapView.region = region;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = [UIColor redColor];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    
    return nil;
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
                                                                   imageObject.imageData = UIImagePNGRepresentation(image);
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
