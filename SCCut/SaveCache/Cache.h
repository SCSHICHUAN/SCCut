//
//  Cache.h
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Cache : NSObject
+(void)SaveImageData:(NSData *)imageData toCachePath:(NSString *)path;
+(void)SaveVideoFromPath:(NSString *)videoPath toCachePath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
