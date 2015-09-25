//
//  rightViewController.m
//  runningRhythm
//
//  Created by saintPN on 15/9/3.
//  Copyright (c) 2015年 saintPN. All rights reserved.
//

#import "rightViewController.h"

@interface rightViewController ()

@property (strong, nonatomic) UITextView *textview;

@property (strong, nonatomic) UILabel *label;

@end

@implementation rightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textview = ({
        UITextView *textview = [[UITextView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 210, self.view.frame.size.height - 54 * 8.5, 200, 400)];
        textview.backgroundColor = [UIColor clearColor];
        textview.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        textview.textColor = [UIColor whiteColor];
        textview.textAlignment = NSTextAlignmentLeft;
        textview.text = @"1.通过itunes导入你喜欢的音乐.\n2.导入你喜欢的图片(750x1334),作为随机背景图片.\n3.选择好时间,沙漏按钮开始倒计时,圆圈按钮重置.\n4.重置会显示本次时间以及累计时间.";
        textview;
    });
    [self.view addSubview:self.textview];
    
    self.label = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 160, self.view.frame.size.height - 54 * 9, 100, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor cyanColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"App简介";
        label;
    });
    [self.view addSubview:self.label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
