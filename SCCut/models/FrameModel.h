//
//  FrameModel.h
//  SCCut
//
//  Created by Stan on 2023/3/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FrameModel : NSObject

@property(nonatomic,assign)NSInteger gorup_index;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,strong)UIImage *img;
@property(nonatomic,strong)CIImage *ciimg;
@property(nonatomic,assign)CVPixelBufferRef buff;
@property(nonatomic,assign)int64_t value;
@property(nonatomic,assign)BOOL selected;



@end

NS_ASSUME_NONNULL_END
