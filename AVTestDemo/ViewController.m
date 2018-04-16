//
//  ViewController.m
//  AVTestDemo
//
//  Created by shiguang on 2018/4/16.
//  Copyright © 2018年 shiguang. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WeChatSight" ofType:@"mp4"];
    
    //1.将素材拖入到素材库中
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    //素材的视频轨
    AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];
    //素材的音频轨
    AVAssetTrack *audioAssertTrack = [[asset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
    
    //2.将素材的视频插入视频轨，音频插入音频轨
    //这是工程文件
    AVMutableComposition *composition = [AVMutableComposition composition];
    //视频轨道
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    //在视频轨道插入一个时间段的视频
    BOOL isSuc = [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    //音频轨道
    AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    //插入音频数据，否则没有声音
    [audioCompositionTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:audioAssertTrack atTime:kCMTimeZero error:nil];
    
    
    //3.裁剪视频，就是要将所有视频轨进行裁剪，就需要得到所有的视频轨，而得到一个视频轨就需要得到它上面所有的视频素材
    AVMutableVideoCompositionLayerInstruction *videoCompositionLayerIns = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoAssetTrack];[videoCompositionLayerIns setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    //得到视频素材（这个例子中只有一个视频）
    AVMutableVideoCompositionInstruction *videoCompositionIns = [AVMutableVideoCompositionInstruction videoCompositionInstruction];[videoCompositionIns setTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)];
    //得到视频轨道（这个例子中只有一个轨道）
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];videoComposition.instructions = @[videoCompositionIns];
    videoComposition.renderSize = CGSizeMake(960, 544);
    //裁剪出对应的大小
    videoComposition.frameDuration = CMTimeMake(7, 1);
    
    
    NSString *outputFileDir = [NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
    BOOL isDir;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:outputFileDir isDirectory:&isDir];
    if (!isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:outputFileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (isExist) {
        [[NSFileManager defaultManager] removeItemAtPath:outputFileDir error:nil];
    }
    NSString *outputFilePath = [NSString stringWithFormat:@"%@/TestVideo.mp4",outputFileDir];
    //4.导出
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = videoComposition;exporter.outputURL = [NSURL fileURLWithPath:outputFilePath isDirectory:YES];
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (exporter.error) {
            //...
            NSLog(@"error: %@",exporter.error);
        }else{
            //...
            NSLog(@"success");
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
