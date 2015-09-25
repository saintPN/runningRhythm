//
//  dataModel.m
//  runningRhythm
//
//  Created by saintPN on 15/8/28.
//  Copyright (c) 2015年 saintPN. All rights reserved.
//

#import "saintPNDataModel.h"

@implementation saintPNDataModel

#pragma mark - 获取音乐

- (instancetype) init {
    self = [super init];
    if (self) {
        //存放音歌曲URL
        self.songURLArray = [[NSMutableArray alloc] init];
        //存放歌曲名
        self.songNamesArray = [[NSMutableArray alloc] init];
        //存放图片文件URL
        self.imageURLArray = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)getiPODMusic {
    //获取iPod音乐
    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
    NSArray *songsList = [songsQuery items];
    for (MPMediaItem *item in songsList) {
        NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
        [self.songURLArray addObject:url];
        NSString *string = [item valueForProperty:MPMediaItemPropertyTitle];
        [self.songNamesArray addObject:string];
    }
}

- (void)getSandBoxMusic {
    //获取document目录音乐
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *docuArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docustring = [docuArray firstObject];
    NSArray *array = [[NSArray alloc] init];
    array = [manager contentsOfDirectoryAtPath:docustring error:nil];
    if (array) {
        for (int i=0; i<array.count; i++ ) {
            NSString *string = [[NSString alloc] init];
            string = array[i];
            if ([[string pathExtension] isEqualToString:@"mp3"]) {
                //获取歌曲URL
                NSString *path = [[NSString alloc] initWithFormat:@"%@/%@", docustring,string];
                NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
                [self.songURLArray addObject:url];
                //获取歌曲名
                NSInteger l = string.length - 4;
                NSRange range = {0, l};
                string = [string substringWithRange:range];
                [self.songNamesArray addObject:string];
            }
        }
    }
}

#pragma mark - 获取图片

- (void)getSandBoxImage {
    //获取document目录图片
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *docuArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docustring = [docuArray firstObject];
    NSArray *array = [[NSArray alloc] init];
    array = [manager contentsOfDirectoryAtPath:docustring error:nil];
    if (array) {
        for (int i=0; i<array.count; i++ ) {
            NSString *string = [[NSString alloc] init];
            string = array[i];
            if ( [[string pathExtension] isEqualToString:@"jpg"] || [[string pathExtension] isEqualToString:@"png"]) {
                //获取图片路径
                NSString *imagePath = [[NSString alloc] initWithFormat:@"%@/%@", docustring, string];
                [self.imageURLArray addObject:imagePath];
            }
        }
    }
}

@end
