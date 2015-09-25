//
//  musicPlayer.h
//  runningRhythm
//
//  Created by saintPN on 15/8/28.
//  Copyright (c) 2015年 saintPN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dataModel.h"


@interface musicPlayer : NSObject

@property (strong, nonatomic) AVAudioPlayer *player;

@property NSInteger playingNumber;

@property BOOL isPlaying;

- (void)play;

- (void)next;

- (void)previous;

@end
