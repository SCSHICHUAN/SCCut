//
//  TimeShaftItem.m
//  SCCut
//
//  Created by Stan on 2023/3/8.
//

#import "TimeShaftItem.h"

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
    }
    return _imageV;
}

-(void)UI{
    [self.contentView addSubview:self.imageV];
    [self.contentView setClipsToBounds:YES];
}

-(void)setImage:(UIImage *)image{
    self.imageV.image = image;
}

@end
