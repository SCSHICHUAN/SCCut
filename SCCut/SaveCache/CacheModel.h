//
//  CacheModel.h
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, MediaType) {
    MediaType_video,
    MediaType_photo
};
@class AVURLAsset;
@interface CacheModel : NSObject

@property(nonatomic,copy)NSString *fileName;
@property(nonatomic,assign)MediaType mediaType;
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,copy)NSString *cachePath;
@property(nonatomic,strong)UIImage *image;
@property(nonatomic,assign)CGSize fileSize;
@property(nonatomic,strong)AVURLAsset *avAsset;
@property(nonatomic,assign)NSInteger index;

@end

NS_ASSUME_NONNULL_END
