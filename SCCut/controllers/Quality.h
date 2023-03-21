//
//  Quality.h
//  SCCut
//
//  Created by Stan on 2023/3/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class AVURLAsset;
@interface Quality : NSObject

+(void)QualitychangeInput:(AVURLAsset *)videoAsset witchIndex:(NSInteger)index;
+(void)GetFramesMetal:(AVURLAsset *)videoAsset witchIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
