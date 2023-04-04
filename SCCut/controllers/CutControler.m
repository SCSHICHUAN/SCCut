//
//  CutControler.m
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#import "CutControler.h"
#include "libavutil/log.h"
#include "libavformat/avio.h"
#include "libavformat/avformat.h"
#include "one_frame.h"
#import "SeccionItem.h"
#import "CacheModel.h"
#import "FrameModel.h"
#import "SCCollection.h"model.gorup_index
#import "SelectedView.h"
#import "AVPlayer+SeekSmoothly.h"



@interface CutControler ()<
UICollectionViewDataSource,
UICollectionViewDelegate,
SCCollectionDelegate,
UIScrollViewDelegate>
{
    MBProgressHUD *hud;
}
@property(nonatomic,strong)UIButton *backBtn;
@property(nonatomic,strong)UIButton *pleyBtn;
@property(nonatomic,strong)UICollectionView *seccionCollectView;
@property(nonatomic,strong)UIImageView *imgView;
@property(nonatomic,strong)NSTimer *time;
@property(nonatomic,assign)NSInteger playItem;
@property(nonatomic,strong)UIView *scaleLine;
@property(nonatomic,strong)UILabel *lab;
@property(nonatomic,strong)AVPlayer *avPlarer;
@property(nonatomic,strong)NSMutableArray *cacheFrameImg;
@property(nonatomic,strong)AVMutableComposition *workbench;
@property(nonatomic,assign)BOOL b;
@property(nonatomic,strong)SelectedView *selectView;
@property(nonatomic,assign)NSInteger allFrames;
@property(nonatomic,strong)AVMutableComposition *mixComposition;
@property(nonatomic,strong)AVMutableVideoComposition *videoComposition;
@property(nonatomic,strong)NSMutableArray *selectedAssets;
@end


@implementation CutControler

-(void)addPlayItem{
    
    self.b = NO;
    
//    if (self.videoComposition1) {
//        // Every videoComposition needs these properties to be set:
//        self.videoComposition1.frameDuration = CMTimeMake(1, 30); // 30 fps
//        self.videoComposition1.renderSize = CGSizeMake(K_WIDTH, (K_WIDTH)*(9/16.0));
//    }
    
    AVPlayerItem *item1 = [[AVPlayerItem alloc] initWithAsset:self.composition1];
    
    //创建视频工作台
    item1.videoComposition = self.videoComposition1;
    
    
    [self.avPlarer replaceCurrentItemWithPlayerItem:item1];
    
    return;
    
    [self test:self.assetArray];
    return;
    
//    __block AVMutableCompositionTrack*videoCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
//                                                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
//       AVAssetTrack *videoFirstTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
//       [videoCompositionTrack setPreferredTransform:videoFirstTrack.preferredTransform];

    
    //创建工作台
    AVMutableComposition *workbench = [AVMutableComposition composition];
    //创建主视频和音频轨道添加到工作台
    AVMutableCompositionTrack *mainVideoTrack = [workbench addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [mainVideoTrack setPreferredTransform:CGAffineTransformRotate(CGAffineTransformMakeScale(-1, 1), M_PI)];

    

    
//    [mainVideoTrack setPreferredTransform:videoFirstTrack.preferredTransform];
    
//    AVMutableCompositionTrack *mainAudioTrack = [workbench addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
   
    AVMutableVideoComposition *videoComp ;
    self.assetArray = (NSMutableArray *)self.assetArray.reverseObjectEnumerator.allObjects;
    int32_t i = 0;
    for (CacheModel *model in self.assetArray) {
        AVAsset *videoAsset = model.avAsset;
        if(model.mediaType == MediaType_video){
            
            
            AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            
            
            //设置视频的尺寸，720*1280是竖屏的和横屏的分水岭
            CGSize videoSize = CGSizeMake(720, 1280);
            
            
            
            
            //创建父layer
//            CALayer *parentLayer = [CALayer layer];
//            parentLayer.backgroundColor = UIColor.redColor.CGColor;
//            parentLayer.frame=CGRectMake(0, 0, videoSize.width, videoSize.height);
//            //准备layer为参数，这个决定视频的大小
//            CALayer *videoLayer=[CALayer layer];
//            videoLayer.frame=CGRectMake(0, 0,videoSize.height,videoSize.width);
//            videoLayer.backgroundColor = UIColor.yellowColor.CGColor;
//            [parentLayer addSublayer:videoLayer];
            
            
//            //BA动画 旋转视频，和移动视频
//            videoLayer.anchorPoint = CGPointMake(0.5, 0.5);
//
//
//            //俩次放射变换 旋转视频90度，和移动视频
//            videoLayer.affineTransform = CGAffineTransformMakeRotation(-3*M_PI/2);
//            videoLayer.affineTransform = CGAffineTransformConcat(videoLayer.affineTransform, CGAffineTransformMakeTranslation(-280,280));
            
            
            videoComp = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:workbench];
            videoComp.renderSize = videoSize;
            videoComp.frameDuration = CMTimeMake(1, 30);
//            videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
            
            
            AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            //改变工作台视频的尺寸为720*1280
            CGFloat changeWidth = 720 / mainVideoTrack.naturalSize.width;
            CGFloat changeHeight = 1280 / mainVideoTrack.naturalSize.height;
            CGAffineTransform chageingScale = CGAffineTransformMakeScale(changeWidth, changeHeight);
            [layerInstruction setTransform:CGAffineTransformConcat(mainVideoTrack.preferredTransform, chageingScale) atTime:kCMTimeZero];
            
            //加入指令
            instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
            videoComp.instructions = [NSArray arrayWithObject: instruction];
            
            
            
            
            
            
//            if(i == 0){
//                AVMutableCompositionTrack *mainVideoTrack1 = [workbench addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:i];
//                mainVideoTrack1.preferredTransform = CGAffineTransformMakeRotation(M_PI/2.0);
//                AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
                //视频
//                [mainVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
//            }else{
//                AVMutableCompositionTrack *mainVideoTrack1 = [workbench addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:11111];
//                AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//                //视频
//                [mainVideoTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
//            }
//
//
//            i++;
//
//            AVMutableCompositionTrack *mainVideoTrack = [workbench addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//            mainVideoTrack.preferredTransform = CGAffineTransformMakeRotation(M_PI/2.0);
//            AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//            [mainVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:videoTrack atTime:CMTimeMake(i, 1) error:nil];
//
//            int64_t time = videoAsset.duration.value/videoAsset.duration.timescale;
//            i += time;
            //引入外部多媒体 创建资源轨道
           
            
           
//            AVMutableCompositionTrack *comVideoTrack =  [workbench mutableTrackCompatibleWithTrack:videoTrack];
//
//            [comVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
//            comVideoTrack.preferredTransform =  CGAffineTransformMakeRotation(M_PI/2.0);
//
//
//
            
            
            
            
           
            
            
            
//            //音频
//            AVAssetTrack *audioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
//            [mainAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:audioTrack atTime:kCMTimeZero error:nil];
        }else{
            
        }
    }
    

    
    self.workbench = workbench;
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:workbench];
    
    //创建视频工作台
    item.videoComposition = videoComp;
    
    
    [self.avPlarer replaceCurrentItemWithPlayerItem:item];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor =UIColor.whiteColor;
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.pleyBtn];
    [self.view addSubview:self.seccionCollectView];
//    [self.view addSubview:self.imgView];
    [self.view addSubview:self.scaleLine];
    [self.view addSubview:self.lab];
    _playItem = 0;
    self.allFrames = 0;
    
    //
    //    const char *a = [self.model.cachePath cStringUsingEncoding: NSUTF8StringEncoding];
    //    const char *b = [VIDEOCACHEPATH cStringUsingEncoding: NSUTF8StringEncoding];
    //
    //    const char *argv[] ={"",a,b,"0","120"};
    //
    //    getOneFreame(5, argv);
    //    [self show];
    //    [self.seccionCollectView reloadData];
//    hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
//    hud.mode = MBProgressHUDModeIndeterminate;
//    hud.label.text = @"处理中";
    [self.seccionCollectView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveArr:) name:@"video_frame_image" object:nil];
    
    self.b = YES;
}
#pragma mark-UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.sourceSessionArry.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SeccionItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:seccionItemIdent forIndexPath:indexPath];
    item.partArry = self.sourceSessionArry[indexPath.item];
    return item;
}
#pragma mark-UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray *part = self.sourceSessionArry[indexPath.item];
//    FrameModel *model = self.timeShaftArry[indexPath.item];
//    NSLog(@"model.gorup_index:%ld",(long)model.gorup_index);
//
  
    SeccionItem *item = (SeccionItem *)[collectionView cellForItemAtIndexPath:indexPath];
    
    self.selectView.frame = item.frame;

    [self.seccionCollectView addSubview:self.selectView];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *part = self.sourceSessionArry[indexPath.item];
    CGSize  sessionItemSize = CGSizeMake(part.count * 50, 50);
    return sessionItemSize;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    int index = (self.seccionCollectView.contentOffset.x + K_WIDTH/2.0)/50;
    if (self.allFrames <= 0 || index >= self.allFrames) return;
//    FrameModel *model =  self.timeShaftArry[index];
//    self.imgView.image = model.img;
    self.lab.text = [NSString stringWithFormat:@"%d",index];
//    [self popTimePlay:self.seccionCollectView.contentOffset.x];
}
-(void)popTimePlay:(CGFloat)x
{
    
    if(!self.b)return;
    float offxet = x + K_WIDTH/2.0;
    if(offxet < 0) return;
    
    CMTimeValue value = ((offxet * 1000)/((self.allFrames * 50 * 1000.0))) * self.workbench.duration.value;
    CMTime seekTime = CMTimeMake(value, self.workbench.duration.timescale);
    
//    NSLog(@"cur=%lld",value);
//    NSLog(@"all=%lld",self.workbench.duration.value);
//    NSLog(@"");
    
    
    
    [self.avPlarer ss_seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
//             NSLog(@"已经跳到时间对应的视频");
        }else{
            NSLog(@"失败");
        }
    }];
}
-(void)play{
//    if(_playItem == self.timeShaftArry.count){
//        _playItem = 0;
//    }
//    _seccionCollectView.contentOffset = CGPointMake(-K_WIDTH/2.0 - 50/2 + 50 * _playItem,0);
//    _playItem++;
}
-(void)saveArr:(NSNotification*)note{
    
    self.allFrames++;
    
    self.playItem = 0;
//    [hud hideAnimated:YES];
    FrameModel *model = (FrameModel *)note.object;
    
    NSMutableArray *part = self.sourceSessionArry[model.gorup_index];
    [part addObject:model];
    
//    if(self.sourceSessionArry.count == 2){
//        NSMutableArray *indexs = [NSMutableArray array];
//        [indexs addObject:[NSIndexPath indexPathForItem:model.gorup_index inSection:0]];
//        [self.seccionCollectView reloadItemsAtIndexPaths:indexs];
//    }else{
//        [self.seccionCollectView reloadData];
//    }
    [self.seccionCollectView reloadData];
    
}
-(UIButton *)backBtn{
    if(!_backBtn){
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.backgroundColor = UIColor.blackColor;
        [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.frame = CGRectMake(20, 100, 200, 40);
    }
    return _backBtn;
}
-(UIButton *)pleyBtn{
    if(!_pleyBtn){
        _pleyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pleyBtn.backgroundColor = UIColor.blackColor;
        [_pleyBtn setTitle:@"play" forState:UIControlStateNormal];
        [_pleyBtn addTarget:self action:@selector(playBtn:) forControlEvents:UIControlEventTouchUpInside];
        _pleyBtn.frame = CGRectMake(140, 100, 200, 40);
    }
    return _pleyBtn;
}
#pragma mark-SCCollectionDelegate
-(void)touchesBegan{
    if(self.pleyBtn.selected){
        [self playBtn:self.pleyBtn];
    }
}

//开始滚动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self touchesBegan];
}

-(void)playBtn:(UIButton*)send{
    send.selected = !send.selected;
    
    if(send.selected){
        self.b = NO;
        [send setTitle:@"stop" forState:UIControlStateNormal];
        [self.avPlarer play];
    }else{
        self.b = YES;
        [self.time setFireDate:[NSDate distantFuture]];
        [send setTitle:@"paly" forState:UIControlStateNormal];
        [self.avPlarer pause];
    }
}


#pragma mark - 监听
- (void)addProgressObserver {
    
    __weak typeof(self) weakSelf = self;
    [self.avPlarer addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:dispatch_get_global_queue(0, 0) usingBlock:^(CMTime time) {
        
        
        
        float allTimeF = CMTimeGetSeconds(weakSelf.avPlarer.currentItem.duration);
        float currentTimeF = CMTimeGetSeconds(weakSelf.avPlarer.currentItem.currentTime);
        CGFloat x = (currentTimeF/allTimeF) *  (self.allFrames * 50) - K_WIDTH/2.0;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!weakSelf.b){
                [weakSelf.seccionCollectView setContentOffset:CGPointMake(x, 0) animated:NO];
            }
        });
        
        //        weakSelf.allTime = allTimeF;
        //        weakSelf.currentTime = currentTimeF;
        //        if (weakSelf.centUpdatTime) {
        //            weakSelf.progressSlider.value = currentTimeF / allTimeF;
        //            weakSelf.progressView2.progress = currentTimeF / allTimeF;
        //        }
        
        int allTime = CMTimeGetSeconds(weakSelf.avPlarer.currentItem.duration);
        int currentTime = CMTimeGetSeconds(weakSelf.avPlarer.currentItem.currentTime);
        
        //        int allHour = allTime / (60*60);
        int allMin  = allTime / 60;
        int allSecond  = allTime % 60;
        
        //        int currentHour = currentTime / (60*60);
        int currentMin  = currentTime / 60;
        int currentSecond  = currentTime % 60;
        
        //        if ([weakSelf.delegate respondsToSelector:@selector(timeRunAndTime:allTime:)]) {
        //            [weakSelf.delegate timeRunAndTime:weakSelf.avPlarer.currentItem.currentTime allTime:weakSelf.avPlarer.currentItem.duration];
        //        }
        NSString *aullTime = [NSString stringWithFormat:@"%.2d:%.2d",allMin,allSecond];
        NSString *currentTime1 = [NSString stringWithFormat:@"%.2d:%.2d",currentMin,currentSecond];
        //        if (!weakSelf.isLive) {
        //            weakSelf.timeLab.text = [NSString stringWithFormat:@"%@ / %@",currentTime1,aullTime];
        //        }
    }];
}
-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)show{
    
    //    for(int i = 0;i<fream_count;i++){
    //        if([self freams:i]){
    //            [self.timeShaftArry addObject:[self freams:i]];
    //        }
    //    }
    //    [self.seccionCollectView reloadData];
    
}

-(UIImage *)freams:(int)a
{
    NSString *fileName = [NSString stringWithFormat:@"videoCache-%d",a];
    NSData *data =  [CutControler readFileName:fileName Type:@"bmp"];
    return [UIImage imageWithData:data];
}

+(NSData *)readFileName:(NSString *)name Type:(NSString *)type{
    
    NSString *filePathStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //    filePathStr = [filePathStr stringByAppendingPathComponent:@"videoCache"];
    
    NSString *fullPathStr = [filePathStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",name,type]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:fullPathStr];
    return [fileHandle readDataToEndOfFile];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.time setFireDate:[NSDate distantFuture]];
}


#pragma mark-GET

-(NSMutableArray *)sourceSessionArry{
    if(!_sourceSessionArry){
        _sourceSessionArry = [NSMutableArray array];
    }
    return _sourceSessionArry;
}
-(SelectedView *)selectView{
    if(!_selectView){
        _selectView = [[SelectedView alloc] init];
    }
    return _selectView;
}
-(NSMutableArray *)cacheFrameImg{
    if(!_cacheFrameImg){
        _cacheFrameImg = [NSMutableArray array];
    }
    return _cacheFrameImg;
}
-(NSMutableArray *)assetArray{
    if(!_assetArray){
        _assetArray = [NSMutableArray array];
    }
    return _assetArray;
}
-(AVPlayer *)avPlarer{
    if(!_avPlarer){
        _avPlarer = [[AVPlayer alloc] init];
        AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:_avPlarer];
        layer.backgroundColor = UIColor.blackColor.CGColor;
        layer.frame = CGRectMake(0, 200, K_WIDTH, (K_WIDTH)*(9/16.0));
        layer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.view.layer addSublayer:layer];
        [self addProgressObserver];
    }
    return _avPlarer;
}
-(UILabel *)lab{
    if(!_lab){
        _lab = [[UILabel alloc] initWithFrame:CGRectMake(K_WIDTH/2-50, K_HEIGHT-455, 100, 40)];
        _lab.textAlignment = NSTextAlignmentCenter;
        _lab.font = [UIFont boldSystemFontOfSize:20];
        _lab.textColor = UIColor.redColor;
    }
    return _lab;
}
-(UIView *)scaleLine{
    if(!_scaleLine){
        _scaleLine = [[UIView alloc] initWithFrame:CGRectMake(K_WIDTH/2.0-1, K_HEIGHT-410, 2, 90)];
        _scaleLine.backgroundColor = UIColor.redColor;
    }
    return _scaleLine;
}
-(NSTimer *)time{
    if(!_time){
        _time = [NSTimer scheduledTimerWithTimeInterval:1/4.0 target:self selector:@selector(play) userInfo:nil repeats:YES];
    }
    return _time;
}
-(UIImageView *)imgView{
    if(!_imgView){
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 600, K_WIDTH, (K_WIDTH)*(9/16.0))];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        _imgView.backgroundColor = UIColor.blueColor;
    }
    return _imgView;
}
-(UICollectionView *)seccionCollectView{
    if(!_seccionCollectView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _seccionCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, K_HEIGHT-400, K_WIDTH, 50) collectionViewLayout:layout];
        [_seccionCollectView registerClass:[SeccionItem class] forCellWithReuseIdentifier:seccionItemIdent];
        _seccionCollectView.dataSource = self;
        _seccionCollectView.contentInset = UIEdgeInsetsMake(0, K_WIDTH/2.0, 0, K_WIDTH/2.0);
        _seccionCollectView.delegate = self;
    }
    return _seccionCollectView;
}

//-(NSMutableArray *)timeShaftArry{
//    if(!_timeShaftArry){
//        _timeShaftArry = [NSMutableArray array];
//    }
//    return _timeShaftArry;
//}




-(void)test:(NSMutableArray*)arr{
    
    self.selectedAssets = [NSMutableArray array];
    for (CacheModel *model in arr) {
        [self.selectedAssets  addObject:model.avAsset];
    }
    
    
    self.mixComposition = [AVMutableComposition composition];
    self.videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:self.mixComposition];
    
    CMTime nextClipStartTime = kCMTimeZero;
    NSInteger i;
    CMTime transitionDuration = CMTimeMake(1, 1); // Default transition duration is one second.

    // Add two video tracks and two audio tracks.
    AVMutableCompositionTrack *compositionVideoTracks[2];
    AVMutableCompositionTrack *compositionAudioTracks[2];
    compositionVideoTracks[0] = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionVideoTracks[1] = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionAudioTracks[0] = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionAudioTracks[1] = [self.mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) * [self.selectedAssets count]);
    CMTimeRange *transitionTimeRanges = alloca(sizeof(CMTimeRange) * [self.selectedAssets count]);

    // Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
    for (i = 0; i < [self.selectedAssets count]; i++ )
    {
        NSInteger alternatingIndex = i % 2; // alternating targets: 0, 1, 0, 1, ...
        AVURLAsset *asset = [self.selectedAssets objectAtIndex:i];

        NSLog(@"number of tracks %d",asset.tracks.count);

        CMTimeRange assetTimeRange;
        assetTimeRange.start = kCMTimeZero;
        assetTimeRange.duration = asset.duration;
        NSValue *clipTimeRange = [NSValue valueWithCMTimeRange:assetTimeRange];
        CMTimeRange timeRangeInAsset;
        if (clipTimeRange)
            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        else
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);

        AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [compositionVideoTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];

        AVAssetTrack *clipAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [compositionAudioTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipAudioTrack atTime:nextClipStartTime error:nil];

        // Remember the time range in which this clip should pass through.
        // Every clip after the first begins with a transition.
        // Every clip before the last ends with a transition.
        // Exclude those transitions from the pass through time ranges.
        passThroughTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, timeRangeInAsset.duration);
        if (i > 0) {
            passThroughTimeRanges[i].start = CMTimeAdd(passThroughTimeRanges[i].start, transitionDuration);
            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, transitionDuration);
        }
        if (i+1 < [self.selectedAssets count]) {
            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, transitionDuration);
        }

        // The end of this clip will overlap the start of the next by transitionDuration.
        // (Note: this arithmetic falls apart if timeRangeInAsset.duration < 2 * transitionDuration.)
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration);
        nextClipStartTime = CMTimeSubtract(nextClipStartTime, transitionDuration);

        // Remember the time range for the transition to the next item.
        transitionTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, transitionDuration);
    }

    // Set up the video composition if we are to perform crossfade or push transitions between clips.
    NSMutableArray *instructions = [NSMutableArray array];

    // Cycle between "pass through A", "transition from A to B", "pass through B", "transition from B to A".
    for (i = 0; i < [self.selectedAssets count]; i++ )
    {
        NSInteger alternatingIndex = i % 2; // alternating targets

        // Pass through clip i.
        AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        passThroughInstruction.timeRange = passThroughTimeRanges[i];
        AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];

        passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
        [instructions addObject:passThroughInstruction];

        AVMutableVideoCompositionLayerInstruction *fromLayer;

        AVMutableVideoCompositionLayerInstruction *toLayer;

        if (i+1 < [self.selectedAssets count])
        {
            // Add transition from clip i to clip i+1.

            AVMutableVideoCompositionInstruction *transitionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            transitionInstruction.timeRange = transitionTimeRanges[i];
            fromLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
            toLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[1-alternatingIndex]];


            // Fade out the fromLayer by setting a ramp from 1.0 to 0.0.
            [fromLayer setOpacityRampFromStartOpacity:1.0 toEndOpacity:0.0 timeRange:transitionTimeRanges[i]];

            
            [fromLayer setTransform:CGAffineTransformMakeRotation(0.1 * M_PI) atTime:kCMTimeZero];
//            [toLayer setTransform:CGAffineTransformMakeRotation(0.1 * M_PI) atTime:CMTimeMake(1, 1)];
            
//            [toLayer setCropRectangleRampFromStartCropRectangle:CGRectMake(100, 100, 100, 100) toEndCropRectangle:CGRectMake(100, 100, 4000, 4000) timeRange:transitionTimeRanges[i]];
            
            transitionInstruction.layerInstructions = [NSArray arrayWithObjects:fromLayer, toLayer, nil];
            [instructions addObject:transitionInstruction];
        }


        AVURLAsset *sourceAsset  = self.selectedAssets.firstObject;
        AVAssetTrack *sourceVideoTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];



//        CGSize temp = CGSizeApplyAffineTransform(sourceVideoTrack.naturalSize, sourceVideoTrack.preferredTransform);
//        CGSize size = CGSizeMake(fabsf(temp.width), fabsf(temp.height));
//        CGAffineTransform transform = sourceVideoTrack.preferredTransform;

        
        
        
        
        
        self.videoComposition.renderSize = sourceVideoTrack.naturalSize;
//        if (size.width > size.height) {
//
//            [fromLayer setTransform:transform atTime:sourceAsset.duration];
//        } else {
//
//
//            float s = size.width/size.height;
//
//
//            CGAffineTransform new = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(s,s));
//
//            float x = (size.height - size.width*s)/2;
//
//            CGAffineTransform newer = CGAffineTransformConcat(new, CGAffineTransformMakeTranslation(x, 0));
//
//            [fromLayer setTransform:newer atTime:sourceAsset.duration];
//        }



    }

    self.videoComposition.instructions = instructions;
    self.videoComposition.frameDuration = CMTimeMake(1, 30);



  

    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.mixComposition];
    playerItem.videoComposition = self.videoComposition;
    [self.avPlarer replaceCurrentItemWithPlayerItem:playerItem];

    self.b =NO;
}


@end


