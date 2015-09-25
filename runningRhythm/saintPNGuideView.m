//
//  guideView.m
//  runningRhythm
//
//  Created by saintPN on 15/8/28.
//  Copyright (c) 2015年 saintPN. All rights reserved.
//

#import "saintPNGuideView.h"


@interface saintPNGuideView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) UIButton *skipButton;

@end


@implementation saintPNGuideView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        UIImageView *bgIV = [[UIImageView alloc] initWithFrame:self.frame];
        bgIV.image = [UIImage imageNamed:@"guideViewImage"];
        [self addSubview:bgIV];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.contentSize = CGSizeMake(self.frame.size.width * 3, self.scrollView.frame.size.height);
        self.scrollView.contentOffset = CGPointMake(0, 0);
        [self addSubview:self.scrollView];
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height * 0.8, self.frame.size.width, 12)];
        self.pageControl.pageIndicatorTintColor = [UIColor blackColor];
        self.pageControl.currentPageIndicatorTintColor = [UIColor cyanColor];
        self.pageControl.numberOfPages = 3;
        [self addSubview:self.pageControl];
        
        self.skipButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width * 0.1, self.frame.size.height * 0.85, self.frame.size.width * 0.8, 50)];
        [self.skipButton addTarget:self action:@selector(pressedSkipButton:) forControlEvents:UIControlEventTouchUpInside];
        self.skipButton.tintColor = [UIColor whiteColor];
        [self.skipButton setTitle:@"开始奔跑" forState:UIControlStateNormal];
        self.skipButton.titleLabel.font = [UIFont systemFontOfSize:20];
        self.skipButton.backgroundColor = [UIColor purpleColor];
        self.skipButton.layer.borderColor = [UIColor purpleColor].CGColor;
        self.skipButton.layer.borderWidth = 0.5;
        self.skipButton.layer.cornerRadius = self.skipButton.bounds.size.height / 2;
        [self addSubview:self.skipButton];
        
        [self createGuideView1];
        [self createGuideView2];
        [self createGuideView3];
    }
    return self;
}

- (void)pressedSkipButton:(id)sender {
    [self.delegate didPressedSkipButton];
}

#pragma mark - scrollview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat page = self.scrollView.contentOffset.x / width;
    self.pageControl.currentPage = roundf(page);
}

#pragma mark - 创建引导页面

- (void)createGuideView1 {
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height * 0.15, self.frame.size.width, 60)];
    
    label.text = [NSString stringWithFormat:@"通过iTunes导入你喜欢的音乐"];
    label.font = [UIFont systemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    label.textAlignment =  NSTextAlignmentCenter;
    [view addSubview:label];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width * 0.1, self.frame.size.height * 0.1, self.frame.size.width * 0.5, self.frame.size.width * 0.5)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = [UIImage imageNamed:@"music"];
    imageview.center = self.center;
    [view addSubview:imageview];
    
    [self.scrollView addSubview:view];
}

- (void)createGuideView2 {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height * 0.15, self.frame.size.width, 60)];
    label.text = [NSString stringWithFormat:@"设定目标,开始倒计时"];
    label.font = [UIFont systemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    label.textAlignment =  NSTextAlignmentCenter;
    [view addSubview:label];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width * 0.1, self.frame.size.height * 0.1, self.frame.size.width * 0.5, self.frame.size.width * 0.5)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = [UIImage imageNamed:@"time"];
    imageview.center = self.center;
    [view addSubview:imageview];
    
    [self.scrollView addSubview:view];
}

- (void)createGuideView3 {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width * 2, 0, self.frame.size.width , self.frame.size.height)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height * 0.15, self.frame.size.width, 60)];
    label.text = [NSString stringWithFormat:@"戴起耳机,跟着音乐奔跑吧!"];
    label.font = [UIFont systemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    label.textAlignment =  NSTextAlignmentCenter;
    [view addSubview:label];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width * 0.1, self.frame.size.height * 0.1, self.frame.size.width * 0.5, self.frame.size.width * 0.5)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = [UIImage imageNamed:@"headphone"];
    imageview.center = self.center;
    [view addSubview:imageview];
    
    [self.scrollView addSubview:view];
}

@end
