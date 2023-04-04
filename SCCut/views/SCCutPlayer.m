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
        self.renderSize = CGSizeMake(K_WIDTH, (K_WIDTH)*(9/16.0));
    }
    self.assets = [NSMutableArray array];
    self.timeRanges = [NSMutableArray array];
    
    self.composition = [AVMutableComposition composition];
    self.composition.naturalSize = CGSizeMake(self.renderSize.width * 2, self.renderSize.height * 2);
    
    self.videoComposition = [AVMutableVideoComposition videoComposition];
    self.videoComposition.frameDuration = CMTimeMake(1, 60);
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
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0,0);
    
    AVAssetTrack *assetTrack  = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    CGSize asstSize = assetTrack.naturalSize;
    
    NSInteger deg = [self assetDegress:asset];
    
    if(deg == 90){
        transform =  CGAffineTransformMakeTranslation(K_WIDTH/2,0);
        transform =  CGAffineTransformScale(transform,K_WIDTH/asstSize.width,((K_WIDTH)*(9/16.0))/asstSize.height);
        transform =  CGAffineTransformRotate(transform, M_PI/2.0);
        transform =  CGAffineTransformScale(transform,(9/16.0),9/16.0);
        transform =  CGAffineTransformTranslate(transform,0,-K_WIDTH*3);
    }else if(deg == 0 && asstSize.width > asstSize.height){
        transform =  CGAffineTransformScale(transform,K_WIDTH/asstSize.width,((K_WIDTH)*(9/16.0))/asstSize.height);
    }else if(deg == 0 && asstSize.width < asstSize.height){
        transform =  CGAffineTransformTranslate(transform, K_WIDTH/2, 0);
        transform =  CGAffineTransformScale(transform,K_WIDTH/asstSize.width,((K_WIDTH)*(16/9.0))/asstSize.height);
        transform =  CGAffineTransformScale(transform,9/16.0,9/16.0);
        transform =  CGAffineTransformScale(transform,9/16.0,9/16.0);
        transform =  CGAffineTransformTranslate(transform,-K_WIDTH*3,0);
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
-(NSInteger)assetDegress:(AVAsset*)asset{
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    CGAffineTransform t = track.preferredTransform;
    
    NSInteger degress = -1;
    
    if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
        // Portrait
        degress = 90;
    }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
        // PortraitUpsideDown
        degress = 270;
    }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
        // LandscapeRight
        degress = 0;
    }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
        // LandscapeLeft
        degress = 180;
    }
    
    return degress;
    
}

@end
