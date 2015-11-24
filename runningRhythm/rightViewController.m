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
        textview.text = @"1.通过itunes导入音乐\n2.导入图片(750x1334)作为随机背景图片\n3.沙漏按钮开始,圆圈按钮重置\n4.建议或意见:\nsaintPN@foxmail.com";
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
