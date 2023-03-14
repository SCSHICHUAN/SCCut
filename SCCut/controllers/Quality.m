//
//  Quality.m
//  SCCut
//
//  Created by Stan on 2023/3/8.
//

#import "Quality.h"
#import <AVKit/AVKit.h>
#import "QualityModel.h"



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


@end
