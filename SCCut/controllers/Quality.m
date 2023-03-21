//
//  Quality.m
//  SCCut
//
//  Created by Stan on 2023/3/8.
//

#import "Quality.h"
#import <AVKit/AVKit.h>
#import "QualityModel.h"
#import <MetalKit/MetalKit.h>


@implementation Quality


+(void)QualitychangeInput:(AVURLAsset *)videoAsset witchIndex:(NSInteger)index{
    
    
    
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:videoAsset];
//    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.maximumSize = CGSizeMake(200, 200);
    
    CMTime duration = videoAsset.duration;
    NSMutableArray *times = [NSMutableArray array];
    CMTimeValue increment =  duration.timescale/4;
    CMTimeValue currentValue = 0;
   
    while (currentValue <= duration.value) {
        CMTime time = CMTimeMake(currentValue, duration.timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
        currentValue += increment;
    }
    
    __block NSUInteger imageCount = times.count;
    AVAssetImageGeneratorCompletionHandler handler;
    __block NSInteger item_index = index;
    handler = ^(CMTime requestedTime,
                CGImageRef imageRef,
                CMTime actualTime,
                AVAssetImageGeneratorResult result,
                NSError *error) {
        
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            
            
            QualityModel *model = [[QualityModel alloc] init];
            model.gorup_index = index;
            model.index = item_index;
            model.img = image;
            model.value = duration.value;
            NSLog(@"完成：%ld",(long)item_index++);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"video_frame_image" object:model];
            });
        } else {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        
        if (--imageCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //获取完毕， 作出相应的操作
            });
        }
    };
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                         completionHandler:handler];
    
    
    
    
    
    //    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:videoAsset];
    //    imageGenerator.maximumSize = CGSizeMake(60, 60);
    //    __block CMTime actualTime;
    //    __block CGImageRef cgImage;
    //    CMTime cmTime = videoAsset.duration;
    //
    //    int64_t seconds =  cmTime.value/cmTime.timescale;
    //
    //
    //    __block UIImage *image;
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //        for(int i = 0;i<seconds;i++){
    //            cgImage = [imageGenerator copyCGImageAtTime:CMTimeMake(i, 1) actualTime:&actualTime error:nil];
    //            image = [UIImage imageWithCGImage:cgImage];
    //            NSLog(@"完成：%d",i);
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                [[NSNotificationCenter defaultCenter] postNotificationName:@"video_frame_image" object:image];
    //            });
    //        }
    //    });
}

+(void)GetFramesMetal:(AVURLAsset *)videoAsset witchIndex:(NSInteger)index {
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 创建 MTKView 对象，用于渲染视频帧
//        MTKView *mtkView = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
//        mtkView.device = MTLCreateSystemDefaultDevice();
        
        // 创建 AVAssetReaderTrackOutput 对象，用于读取视频帧
        AVURLAsset *asset = videoAsset;
        AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        NSDictionary *outputSettings = @{
            (NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_24RGB)
        };
        AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:outputSettings];
        AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:nil];
        [reader addOutput:output];
        
        // 开始读取视频帧
        [reader startReading];
        
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

      
        __block NSInteger item_index = index;
        // 读取视频帧并转换为 UIImage
        while (reader.status == AVAssetReaderStatusReading) {
            
            
            CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
            if (sampleBuffer) {
//                CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//                CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer];
                
                // 创建 CIContext 对象，用于将 CIImage 转换为 UIImage
//                CIContext *context = [CIContext contextWithOptions:nil];
//                CGImageRef cgImage = [context createCGImage:ciImage fromRect:ciImage.extent];
//                UIImage *image = [UIImage imageWithCGImage:cgImage];
//                CGImageRelease(cgImage);
                
   
//
//                QualityModel *model = [[QualityModel alloc] init];
//                model.gorup_index = index;
//                model.index = item_index;
//                model.ciimg = ciImage;
//                model.buff = pixelBuffer;
                NSLog(@"Metal完成：%ld",(long)item_index++);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"video_frame_image" object:model];
//                });
                
                CFRelease(sampleBuffer);
//                CFRelease(pixelBuffer);
            }
        }
        
        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime executionTime = endTime - startTime;
        NSLog(@"Execution time: %f seconds", executionTime);
        
    });
    
}

@end
