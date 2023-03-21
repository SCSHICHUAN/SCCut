//
//  TimeShaftItem.m
//  SCCut
//
//  Created by Stan on 2023/3/8.
//

#import "TimeShaftItem.h"
#import <MetalKit/MetalKit.h>


@interface TimeShaftItem ()

@property(nonatomic,strong)UIImageView *imageV;

@end

@implementation TimeShaftItem

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self UI];
    }
    return self;
}

-(UIImageView *)imageV{
    if(!_imageV){
        _imageV = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageV.contentMode = UIViewContentModeScaleAspectFill;
        _imageV.userInteractionEnabled = NO;
    }
    return _imageV;
}

-(void)UI{
    [self.contentView addSubview:self.imageV];
    [self.contentView setClipsToBounds:YES];
    self.backgroundColor = UIColor.grayColor;
    self.imageV.layer.borderWidth = 0.5;
    self.imageV.layer.borderColor = UIColor.whiteColor.CGColor;
}

-(void)setQualityModel:(QualityModel *)qualityModel{
    _qualityModel = qualityModel;
    self.imageV.image = qualityModel.img;
    
    
    return;
    
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            CIImage *ciImage = qualityModel.ciimg;
               CIContext *ciContext = [[CIContext alloc] init];
            CGImageRef cgImage = [ciContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(qualityModel.buff), CVPixelBufferGetHeight(qualityModel.buff))];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageV.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                self.imageV.layer.contents = (__bridge id)cgImage;
                
                // 释放 CGImage 和 CMSampleBuffer
                CGImageRelease(cgImage);
            });
        });
}








@end
