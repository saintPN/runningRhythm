//
//  guideView.h
//  runningRhythm
//
//  Created by saintPN on 15/8/28.
//  Copyright (c) 2015年 saintPN. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol saintPNGuideViewDelegate <NSObject>

- (void)didPressedSkipButton;

@end


@interface saintPNGuideView : UIView

@property id<saintPNGuideViewDelegate> delegate;

@end
