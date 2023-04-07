//
//  SCCutPlayer.m
//  SCCut
//
//  Created by Stan on 2023/4/3.
//

#import "SCCutPlayer.h"
#import <CoreGraphics/CoreGraphics.h>

@interface SCCutPlayer ()


@property(nonatomic,assign)NSMutableArray <NSValue*>*timeRanges;
@property(nonatomic,strong)NSMutableArray *assets;
@property (nonatomic,assign)CGSize nusize;

@end

@implementation SCCutPlayer

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initData];
    }
    return self;
}

-(void)initData{
    
    if(self.renderSize.width <= 0){
        self.renderSize = CGSizeMake(K_WIDTH * 2, (K_WIDTH)*(9/16.0) * 2);
    }
    
    if(self.playSize.width <= 0){
        self.playSize = CGSizeMake(K_WIDTH, (K_WIDTH)*(9/16.0));
    }
    
    self.assets = [NSMutableArray array];
    self.timeRanges = [NSMutableArray array];
    
    self.composition = [AVMutableComposition composition];
    self.videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:self.composition];
    self.videoComposition.frameDuration = CMTimeMake(1, 60);
    self.composition.naturalSize = self.renderSize;
    self.videoComposition.renderSize = self.renderSize;
    
    
    
}


-(void)addAsset:(AVAsset *)asset{
    
}

-(void)addAssets:(NSArray<AVAsset*> *)assets{
    self.assets = (NSMutableArray*)assets;
    [self createTracks];
}

-(void)createTracks{
    
    CMTime trasitionTime = CMTimeMake(0, 1);
    CMTime nextClipStartTime = kCMTimeZero;//一个资源的开始时间,去除过渡时间
    NSInteger assetCount = self.assets.count;
    
    // 添加两个视频轨道 和 两个音频轨道
    AVMutableCompositionTrack *compositionVideoTracks[2];
    AVMutableCompositionTrack *compositionAudioTracks[2];
    compositionVideoTracks[0] = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionVideoTracks[1] = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionAudioTracks[0] = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionAudioTracks[1] = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //一个资源轨道除去过渡的时间范围,去除在这个视频上的过渡的时间
    CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) * assetCount);
    //过渡的时间范围
    CMTimeRange *transitionTimeRanges = alloca(sizeof(CMTimeRange) * assetCount);
    
    
    
    for (int i = 0; i < assetCount ; i++) {
        
        NSInteger alternatingIndex = i % 2; // alternating targets: 0, 1, 0, 1, ...
        AVURLAsset *asset = self.assets[i];
        //        NSValue *clipTimeRange = self.timeRanges[i];
        CMTimeRange timeRangeInAsset;//一个资源的开始到结束的范围
        //        if (clipTimeRange)
        //            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        //        else
        timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        
        //从asset中取出视频放入轨道[0]或者[1],资源完整时间范围
        AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [compositionVideoTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];
        //从asset中取出音频放入轨道[0]或者[1],资源完整时间范围
        AVAssetTrack *clipAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [compositionAudioTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipAudioTrack atTime:nextClipStartTime error:nil];
        
        
        passThroughTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, timeRangeInAsset.duration);
        
        
        
        if(i > 0){//第二个资源开始要减去头尾的过渡时间
            //减去头过渡时间
            passThroughTimeRanges[i].start = CMTimeAdd(passThroughTimeRanges[i].start, trasitionTime);
            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, trasitionTime);
        }
        
        if(i+1 < assetCount){
            //减去尾过渡时间
            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, trasitionTime);
        }
        
        
        //跳到当前资源的的末位,不包含过渡层叠的时间
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration);
        nextClipStartTime = CMTimeSubtract(nextClipStartTime, trasitionTime);
        
        //从第二段视频开始有过渡时间
        if(i+1 < assetCount){
            transitionTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, trasitionTime);
        }
        
    }
    
    NSMutableArray *instructions = [NSMutableArray array];
    NSMutableArray *trackMixArray = [NSMutableArray array];
    for (int i = 0; i < assetCount; i++) {
        NSInteger alternatingIndex = i % 2;
        
        //去除过渡时间的音视频
        AVMutableVideoCompositionInstruction *instruction_video_pass = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction_video_pass.timeRange = passThroughTimeRanges[i];
        
        AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
        
        AVURLAsset *asset = self.assets[i];
        CGAffineTransform transform = [self changeVideoSizeAndVirection:passThroughLayer asset:asset];
        [passThroughLayer setTransform:transform atTime:kCMTimeZero];
        
        
        
        instruction_video_pass.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
        [instructions addObject:instruction_video_pass];
        
        
        if (i+1 < assetCount) {
            
            //初始化视频指令
            AVMutableVideoCompositionInstruction *instruction_video_transition = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            
            //track选中layer指令
            AVMutableVideoCompositionLayerInstruction *layer_instruction_from
            = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
            AVMutableVideoCompositionLayerInstruction *layer_instruction_to
            = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[1-alternatingIndex]];
            
            //layer变换指令
            [layer_instruction_to setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0 timeRange:transitionTimeRanges[i]];
            instruction_video_transition.layerInstructions = [NSArray arrayWithObjects:layer_instruction_from,layer_instruction_to ,nil];
        }
        
    }
    
    
    
    self.videoComposition.instructions = instructions;
    
    
}

-(CGAffineTransform)changeVideoSizeAndVirection:(AVMutableVideoCompositionLayerInstruction *)passThroughLayer asset:(AVAsset*)asset{
    
    
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    CGSize sourceSize = track.naturalSize;
    
    //reand size play size scal
    CGFloat k_r_p = self.renderSize.width/self.playSize.width;
    
    //source scal to render size
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0,0);
    transform = CGAffineTransformTranslate(transform, 0.000000000000000000001, 0.0);
    
    
    CGFloat deg = [self assetDegress:asset];
    transform =  CGAffineTransformRotate(transform, deg);
    
    
   
    CGFloat k_target = 1;
    CGFloat k_h_target = self.renderSize.height/sourceSize.height;
    CGFloat k_w_target = self.renderSize.width/sourceSize.width;
    CGFloat w_target = sourceSize.width * k_h_target;
    
    
    if(deg == M_PI * 1/2.0 || deg == M_PI * 3/2.0){
        sourceSize = CGSizeMake(sourceSize.height, sourceSize.width);
    }
    
    /*
     照高度比例来把源视频缩放到self.renderSize中,高度铺满,查看宽度情况
     如果宽度超出renderSize.width,就按照高度比例缩放
     */
    if(w_target <= self.renderSize.width){
        k_target = k_h_target;
    } else{
        k_target = k_w_target;
    }
    
    transform =  CGAffineTransformScale(transform,k_target,k_target);
    
    //根据视频比例判断这么填充播放器
    CGFloat render_w_h_scale = self.renderSize.width/self.renderSize.height;
    CGFloat source_w_h_scale = sourceSize.width/sourceSize.height;
    
    
    if(deg == 0.0){//0
        
        //source 缩放到 plarey size 的大小
        CGFloat source_in_player_w =  sourceSize.width * k_target / k_r_p;
        CGFloat source_in_player_h =  sourceSize.height * k_target / k_r_p;

        CGFloat k = (1/k_target) * k_r_p;
        
        if(render_w_h_scale >= source_w_h_scale){//高度填满播放器
            CGFloat offset = (self.playSize.width/2.0 - source_in_player_w/2.0);
            transform =  CGAffineTransformTranslate(transform, offset * k ,0);
        }else if(render_w_h_scale < source_w_h_scale){//宽度填满播放器
            CGFloat offset = (self.playSize.height/2.0 - source_in_player_h/2.0);
            transform =  CGAffineTransformTranslate(transform, 0, offset * k);
        }
        
    }else if(deg == M_PI * 1/2.0){//90
        
            CGFloat k_scale_w = self.renderSize.width/self.renderSize.height;
            CGFloat source_in_palyer_h = sourceSize.height * k_target * k_scale_w;
            
            if(render_w_h_scale >= source_w_h_scale){
                //按照高度填满
                CGFloat  k_scale_h = self.renderSize.height/source_in_palyer_h;
                CGFloat  k = (1/k_target) * k_r_p * (1/k_scale_w) * (1/k_scale_h);
                
                CGFloat source_in_player_w =  sourceSize.width * k_target * k_scale_w * k_scale_h * (1/k_r_p);//按照相同比例转换
                CGFloat offset_x = self.playSize.width/2.0 + source_in_player_w/2.0;
                
                transform =  CGAffineTransformScale(transform,k_scale_h,k_scale_h);
                transform =  CGAffineTransformScale(transform,k_scale_w,k_scale_w);
                transform =  CGAffineTransformTranslate(transform,0,-offset_x * k);
                
            }else if(render_w_h_scale < source_w_h_scale){
                //按照宽度添满
                CGFloat k = (1/k_target) * k_r_p * (1/k_scale_w);
                
                source_in_palyer_h = sourceSize.height * k_target * k_scale_w * (1/k_r_p);
                CGFloat offset_x = self.playSize.width;
                CGFloat offset_y = self.playSize.height/2.0 -  source_in_palyer_h/2.0;
                
                transform =  CGAffineTransformScale(transform,k_scale_w,k_scale_w);
                transform =  CGAffineTransformTranslate(transform, offset_y * k,-offset_x * k);
            }

            
        
        
    }else if(deg == M_PI){//180
        
    }else if(deg ==  M_PI * 3/2.0){//270
        
        
        
        if(0 == self.renderSize.width){
            //宽度填满播放器
          
        }else{
            //高度填满播放器
            CGFloat k_scale = self.renderSize.width/self.renderSize.height;
            CGFloat k = (1/k_target) * k_r_p * (1/k_scale);
            CGFloat source_in_player_w = sourceSize.width;
            CGFloat offset_y = self.playSize.height/2.0 * k + source_in_player_w/2.0;

            transform =  CGAffineTransformScale(transform,k_scale,k_scale);
            transform =  CGAffineTransformTranslate(transform, -offset_y,0);
        }
    }
    
    
    return transform;
}


/*                      |------------------ CGAffineTransformComponents ----------------|
 *
 *      | a  b  0 |     | sx  0  0 |   |  1  0  0 |   | cos(t)  sin(t)  0 |   | 1  0  0 |
 *      | c  d  0 |  =  |  0 sy  0 | * | sh  1  0 | * |-sin(t)  cos(t)  0 | * | 0  1  0 |
 *      | tx ty 1 |     |  0  0  1 |   |  0  0  1 |   |   0       0     1 |   | tx ty 1 |
 *  CGAffineTransform      scale           shear            rotation          translation
 *
 sin(90)  =  1
 sin(180) =  0
 sin(270) = -1
 sin(360) =  0
 
 cos(90)  =  0
 cos(180) = -1
 cos(270) =  0
 cos(360) =  1
 
 */
-(CGFloat)assetDegress:(AVAsset*)asset{
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    CGAffineTransform t = track.preferredTransform;
    
    CGFloat degress = -1;
    
    if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
        // Portrait 90
        degress = M_PI * 1/2.0;
    }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
        // PortraitUpsideDown 270
        degress = M_PI * 3/2.0;
    }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
        // LandscapeRight 0
        degress = 0.0;
    }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
        // LandscapeLeft 180
        degress = M_PI;
    }
    
    return degress;
    
}

@end
