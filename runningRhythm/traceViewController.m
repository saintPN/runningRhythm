//
//  traceViewController.m
//  runningRhythm
//
//  Created by saintPN on 15/11/14.
//  Copyright © 2015年 saintPN. All rights reserved.
//

#import "traceViewController.h"
#import <MapKit/MapKit.h>
#import "Location.h"


@interface traceViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@end


@implementation traceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self settingUI];
    [self mapRegion];
    [self drawLine];
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
        aRenderer.strokeColor = [UIColor blueColor];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    
    return nil;
}

@end
