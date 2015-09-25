//
//  dataModel.h
//  runningRhythm
//
//  Created by saintPN on 15/8/28.
//  Copyright (c) 2015年 saintPN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>


@interface saintPNDataModel : NSObject

@property (strong, nonatomic) NSMutableArray *songURLArray;

@property (strong, nonatomic) NSMutableArray *songNamesArray;

@property (strong, nonatomic) NSMutableArray *imageURLArray;

- (void)getiPODMusic;

- (void)getSandBoxMusic;

- (void)getSandBoxImage;

@end
