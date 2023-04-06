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
    AVPlayerItem *item1 = [[AVPlayerItem alloc] initWithAsset:self.composition1];
    //创建视频工作台
    item1.videoComposition = self.videoComposition1;
    [self.avPlarer replaceCurrentItemWithPlayerItem:item1];
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
    
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 60, 60)];
    view.backgroundColor = UIColor.redColor;
    [self.view addSubview:view];
    
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
    [self popTimePlay:self.seccionCollectView.contentOffset.x];
}
-(void)popTimePlay:(CGFloat)x
{
    
    if(!self.b)return;
    float offxet = x + K_WIDTH/2.0;
    if(offxet < 0) return;
    
    CMTimeValue value = ((offxet * 1000)/((self.allFrames * 50 * 1000.0))) * self.composition1.duration.value;
    CMTime seekTime = CMTimeMake(value, self.composition1.duration.timescale);
    
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
@end


