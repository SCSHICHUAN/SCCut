//
//  Cache.m
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#import "Cache.h"

@implementation Cache

#pragma mark ---- 将图片保存到缓存路径中
+(void)SaveImageData:(NSData *)imageData toCachePath:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:PHOTOCACHEPATH]) {
        [fileManager createDirectoryAtPath:PHOTOCACHEPATH
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    [imageData writeToFile:path atomically:YES];
}


#pragma mark ---- 将视频保存到缓存路径中
+(void)SaveVideoFromPath:(NSString *)videoPath toCachePath:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:VIDEOCACHEPATH]) {
        [fileManager createDirectoryAtPath:VIDEOCACHEPATH
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    
    videoPath = [videoPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    
    NSError *error;
    [fileManager copyItemAtPath:videoPath toPath:path error:&error];
    
    if (error) {
        NSLog(@"转存video保存失败");
    }
}

#pragma mark - 获取文件的大小
+ (long long)GetFileSizeAtPath:(NSString *)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}


@end
