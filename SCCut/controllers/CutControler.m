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
#import "TimeShaftItem.h"
#import <AVFoundation/AVFoundation.h>
#import "CacheModel.h"
#import "QualityModel.h"
#import "SCCollection.h"





@interface CutControler ()<UICollectionViewDataSource,SCCollectionDelegate,UIScrollViewDelegate>
{
    MBProgressHUD *hud;
}
@property(nonatomic,strong)UIButton *backBtn;
@property(nonatomic,strong)UIButton *pleyBtn;
@property(nonatomic,strong)SCCollection *time_collectView;
@property(nonatomic,strong)NSMutableArray *timeShaftArry;
@property(nonatomic,strong)UIImageView *imgView;
@property(nonatomic,strong)NSTimer *time;
@property(nonatomic,assign)NSInteger playItem;
@property(nonatomic,strong)UIView *scaleLine;
@property(nonatomic,strong)UILabel *lab;
@property(nonatomic,strong)AVPlayer *avPlarer;
@property(nonatomic,strong)NSMutableArray *cacheFrameImg;
@property(nonatomic,strong)AVMutableComposition *workbench;
@property(nonatomic,assign)BOOL b;
@end


@implementation CutControler
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
-(SCCollection *)time_collectView{
    if(!_time_collectView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(50, 50);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _time_collectView = [[SCCollection alloc] initWithFrame:CGRectMake(0, K_HEIGHT-400, K_WIDTH, 60) collectionViewLayout:layout];
        [_time_collectView registerClass:[TimeShaftItem class] forCellWithReuseIdentifier:timeShaftItemIdent];
        _time_collectView.dataSource = self;
        _time_collectView.contentInset = UIEdgeInsetsMake(0, K_WIDTH/2.0, 0, K_WIDTH/2.0);
        _time_collectView.sCCollectionDelegate = self;
        _time_collectView.delegate = (id)self;
    }
    return _time_collectView;
}
-(NSMutableArray *)timeShaftArry{
    if(!_timeShaftArry){
        _timeShaftArry = [NSMutableArray array];
    }
    return _timeShaftArry;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.timeShaftArry.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TimeShaftItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:timeShaftItemIdent forIndexPath:indexPath];
    QualityModel *model =  self.timeShaftArry[indexPath.item];
    item.image = model.img;
    return item;
}

-(void)addPlayItem{
    
    
    
    //创建工作台
    AVMutableComposition *workbench = [AVMutableComposition composition];
    //创建主视频和音频轨道添加到工作台
    AVMutableCompositionTrack *mainVideoTrack = [workbench addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *mainAudioTrack = [workbench addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    for (CacheModel *model in self.assetArray) {
        
        AVAsset *videoAsset = model.avAsset;
        if(model.mediaType == MediaType_video){
            //引入外部多媒体 创建资源轨道
            AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            AVAssetTrack *audioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
            //向音视频轨道插入资源
            [mainVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
            [mainAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:audioTrack atTime:kCMTimeZero error:nil];
        }else{
            
        }
    }
    
    self.workbench = workbench;
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:workbench];
    [self.avPlarer replaceCurrentItemWithPlayerItem:item];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor =UIColor.whiteColor;
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.pleyBtn];
    [self.view addSubview:self.time_collectView];
    [self.view addSubview:self.imgView];
    [self.view addSubview:self.scaleLine];
    [self.view addSubview:self.lab];
    _playItem = 0;
    self.timeShaftArry = self.arr;
    //
    //    const char *a = [self.model.cachePath cStringUsingEncoding: NSUTF8StringEncoding];
    //    const char *b = [VIDEOCACHEPATH cStringUsingEncoding: NSUTF8StringEncoding];
    //
    //    const char *argv[] ={"",a,b,"0","120"};
    //
    //    getOneFreame(5, argv);
    //    [self show];
    //    [self.time_collectView reloadData];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"处理中";
    [self.time_collectView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveArr:) name:@"video_frame_image" object:nil];
    
    self.b = YES;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    int index = (self.time_collectView.contentOffset.x + K_WIDTH/2.0)/50;
    if (self.timeShaftArry.count <= 0 || index >= self.timeShaftArry.count) return;
    QualityModel *model =  self.timeShaftArry[index];
    self.imgView.image = model.img;
    self.lab.text = [NSString stringWithFormat:@"%d",index];
    [self popTimePlay:self.time_collectView.contentOffset.x];
}
-(void)popTimePlay:(CGFloat)x
{
    
    if(!self.b)return;
    float offxet = x + K_WIDTH/2.0;
    if(offxet < 0) return;
    CMTimeValue value = ((offxet * 1000)/((self.timeShaftArry.count * 50 * 1000.0))) * self.workbench.duration.value;
    CMTime seekTime = CMTimeMake(value, self.workbench.duration.timescale);
    
    NSLog(@"cur=%lld",value);
    NSLog(@"all=%lld",self.workbench.duration.value);
    NSLog(@"");
    

    [self.avPlarer seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            // NSLog(@"已经跳到时间对应的视频");
        }else{
            //NSLog(@"失败");
        }
    }];
}
-(void)play{
    if(_playItem == self.timeShaftArry.count){
        _playItem = 0;
    }
    _time_collectView.contentOffset = CGPointMake(-K_WIDTH/2.0 - 50/2 + 50 * _playItem,0);
    _playItem++;
}
-(void)saveArr:(NSNotification*)note{
    
    self.playItem = 0;
    [hud hideAnimated:YES];
    QualityModel *model = (QualityModel *)note.object;
    
    [self.timeShaftArry addObject:model];
    [self.timeShaftArry sortUsingComparator:^NSComparisonResult(QualityModel *obj1, QualityModel *obj2) {
        return  obj1.gorup_index<obj2.gorup_index;
    }];
    
    
    if(self.timeShaftArry.count == 2){
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:[NSIndexPath indexPathForItem:self.timeShaftArry.count inSection:0]];
        [self.time_collectView reloadItemsAtIndexPaths:arr];
    }else{
        [self.time_collectView reloadData];
    }
    
    
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
        CGFloat x = (currentTimeF/allTimeF) *  (self.timeShaftArry.count * 50) - K_WIDTH/2.0;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!weakSelf.b){
                [weakSelf.time_collectView setContentOffset:CGPointMake(x, 0) animated:NO];
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
    //    [self.time_collectView reloadData];
    
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



@end


