//
//  CollectionViewCell.m
//  XNEWS
//
//  Created by 石川 on 2019/7/5.
//  Copyright © 2019 沈树亮. All rights reserved.
//
#define kCountBtnW 22
#define kCountBtnH 22

#import "CollectionViewCell.h"

@interface CollectionViewCell ()

@property (nonatomic, weak) UIImageView *videoImageView;
@property (nonatomic, weak) UILabel *timeLable;


@end

@implementation CollectionViewCell
+(CollectionViewCell *)CollectionView:(UICollectionView *)collView indexPath:(NSIndexPath*)indexpath indentfir:(NSString*)indentfir
{
    //cell重用
    CollectionViewCell *cell = [collView dequeueReusableCellWithReuseIdentifier:indentfir forIndexPath:indexpath];
    //设置被选中后的背景视图
    UIView *view = [[UIView alloc] initWithFrame:cell.bounds];
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    cell.selectedBackgroundView = view;
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (UIImageView *)videoImageView {
    if (!_videoImageView) {
        UIImageView *videoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iv_video"]];
        videoImageView.contentMode = UIViewContentModeScaleAspectFit;
        videoImageView.hidden = YES;
        [self.contentView addSubview:videoImageView];
        _videoImageView = videoImageView;
    }
    return _videoImageView;
}

- (UILabel *)timeLable {
    if (!_timeLable) {
        UILabel *timeLable = [[UILabel alloc] init];
        timeLable.font = BOLDSYSTEMFONT(14.f);
        timeLable.textColor = WhiteColor;
        timeLable.hidden = YES;
        [self.contentView addSubview:timeLable];
        _timeLable = timeLable;
    }
    return _timeLable;
}


- (void)setup {
    // iv_video
    [self.videoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(3.f);
        make.bottom.equalTo(self.contentView).offset(-3.f);
        make.size.mas_equalTo(CGSizeMake(15.f, 15.f));
    }];
    
    [self.timeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-5);
        make.centerY.equalTo(self.videoImageView);
    }];
}

- (void)setPhasset:(PHAsset *)phasset {
    _phasset = phasset;
    if (phasset.mediaType == PHAssetMediaTypeVideo) {
        self.timeLable.hidden = NO;
        self.videoImageView.hidden = NO;
        self.timeLable.text = [CollectionViewCell getMMSSFromSS:phasset.duration];
        
    } else {
        self.timeLable.hidden = YES;
        self.videoImageView.hidden = YES;
    }
}

// 秒转化==》时分秒
+ (NSString *)getMMSSFromSS:(NSTimeInterval)totalTime {
    
    NSInteger seconds = totalTime;
    
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    if ([str_hour doubleValue] == 0) {
        format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    }
    return format_time;
}


- (void)addToShoppingCartWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint completion:(void (^)(BOOL))completion {
    [CollectionViewCell addToShoppingCartWithGoodsImage:[self screenShotImage] startPoint:startPoint endPoint:endPoint completion:completion];
}

+ (void)addToShoppingCartWithGoodsImage:(UIImage *)goodsImage startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint completion:(void (^)(BOOL))completion {
    //------- 创建shapeLayer -------//
    CAShapeLayer *animationLayer = [[CAShapeLayer alloc] init];
    animationLayer.frame = CGRectMake(startPoint.x - 20, startPoint.y - 20, goodsImage.size.width, goodsImage.size.height);
    animationLayer.contents = (id)goodsImage.CGImage;
    
    // 获取window的最顶层视图控制器
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    UIViewController *parentVC = rootVC;
    while ((parentVC = rootVC.presentedViewController) != nil ) {
        rootVC = parentVC;
    }
    while ([rootVC isKindOfClass:[UINavigationController class]]) {
        rootVC = [(UINavigationController *)rootVC topViewController];
    }
    
    // 添加layer到顶层视图控制器上
    [rootVC.view.layer addSublayer:animationLayer];
    
    
    //------- 创建移动轨迹 -------//
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:startPoint];
    [movePath addQuadCurveToPoint:endPoint controlPoint:CGPointMake(200,100)];
    // 轨迹动画
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGFloat durationTime = 1; // 动画时间1秒
    pathAnimation.duration = durationTime;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.path = movePath.CGPath;
    
    
    //------- 创建缩小动画 -------//
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.5];
    scaleAnimation.duration = 1.0;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    
    
    // 添加轨迹动画
    [animationLayer addAnimation:pathAnimation forKey:nil];
    // 添加缩小动画
    [animationLayer addAnimation:scaleAnimation forKey:nil];
    
    
    //------- 动画结束后执行 -------//
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(durationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [animationLayer removeFromSuperlayer];
        completion(YES);
    });
}
- (UIImage *)screenShotImage {
    UIImage *imageRet = nil;
    if(&UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    }
    // 获取图像
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    imageRet = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageRet;
}


@end
