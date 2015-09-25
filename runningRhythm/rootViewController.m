//
//  rootViewController.m
//  runningRhythm
//
//  Created by saintPN on 15/8/29.
//  Copyright (c) 2015年 saintPN. All rights reserved.
//

#import "rootViewController.h"


@interface rootViewController ()

@end

@implementation rootViewController

- (void)awakeFromNib {
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftViewController"];
    self.rightMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"rightViewController"];
    self.backgroundImage = [UIImage imageNamed:@"guideViewImage"];
    self.delegate = self;
}

#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController {
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController {
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController {
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController {
}


@end
