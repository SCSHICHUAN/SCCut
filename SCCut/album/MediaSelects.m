//
//  MediaSelects.m
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#define  statuH ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define screenW ([UIScreen mainScreen].bounds.size.width)
#define screenH ([UIScreen mainScreen].bounds.size.height)
#define kCountBtnW 40
#define kCountBtnH 40
static NSString *cellIdentifier = @"cellIdentifier";

#import "MediaSelects.h"
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>
#import "CollectionViewCell.h"
#import "CacheModel.h"

@interface MediaSelects ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UIImage *image;
    NSMutableArray *videoUrls;
    NSIndexPath *_indexPath;
}
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)PHFetchResult<PHAsset *> *assets;
@property(nonatomic,strong)NSMutableArray<PHAsset *> *photos;
@property(nonatomic,strong)UIView *bottonBtnView;
@property (nonatomic, strong) UIButton *countButton;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic,strong)UIButton *previewB;
@property (nonatomic,strong)NSMutableArray<PHAsset *> *selectedAssets;
@property (nonatomic,strong)NSMutableArray<UIView *> *selectViews;
@property (nonatomic,strong)NSMutableArray<NSMutableDictionary *> *cellDicts;
@property (nonatomic,strong)NSMutableArray *medias;
@end

@implementation MediaSelects
-(NSMutableArray *)medias{
    if(!_medias){
        _medias = [NSMutableArray array];
    }
    return _medias;
}
-(UIView *)bottonBtnView
{
    if (!_bottonBtnView) {
        CGFloat height = [self bottomHeight];
        _bottonBtnView = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height - height, screenW, 50)];
        _bottonBtnView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    }
    return _bottonBtnView;
}
-(UIButton *)confirmBtn
{
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        _confirmBtn.backgroundColor = UIColor.blackColor;
        _confirmBtn.frame = CGRectMake(screenW / 2, 0, screenW / 2, 50);
        [_confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}
- (UIButton *)countButton
{
    if (_countButton == nil) {
        _countButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _countButton.frame = CGRectMake(screenW-120,0, 22, 22);
        _countButton.layer.cornerRadius = 11.f;
        [_countButton setTitleColor:RGB(71.f, 179.f, 141.f) forState:UIControlStateNormal];
        [_countButton setImage:[UIImage imageNamed:@"medium_selected_num"] forState:UIControlStateNormal];
        _countButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _countButton.titleEdgeInsets = UIEdgeInsetsMake(0, -22, 0, 0);
        [_countButton setTitle:@"0" forState:UIControlStateNormal];
        
    }
    return _countButton;
}
-(UICollectionView *)collectionView
{
     CGFloat h = [UIApplication sharedApplication].statusBarFrame.size.height;
     CGFloat height = [self bottomHeight];
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, h+44, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-h-44) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _collectionView.backgroundColor= [UIColor whiteColor];
        _collectionView.allowsMultipleSelection = YES;
        [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.contentInset = UIEdgeInsetsMake(1, 0, height, 0);
    }
    return _collectionView;
}
-(UIButton *)previewB
{
    if (!_previewB) {
        _previewB = [UIButton buttonWithType:UIButtonTypeCustom];
        [_previewB setTitle:@"预览" forState:UIControlStateNormal];
        _previewB.backgroundColor = UIColor.blackColor;
        _previewB.frame = CGRectMake(0, 0, screenW / 2, 50);
        [_previewB addTarget:self action:@selector(preview:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previewB;
}
-(NSMutableArray<PHAsset *> *)selectedAssets
{
    if (!_selectedAssets) {
        _selectedAssets = [NSMutableArray array];
    }
    return _selectedAssets;
}

-(NSMutableArray<UIView *> *)selectViews
{
    if (!_selectViews) {
        _selectViews = [NSMutableArray array];
    }
    return _selectViews;
}
-(NSMutableArray<NSMutableDictionary *> *)cellDicts
{
    if (!_cellDicts) {
        _cellDicts = [NSMutableArray array];
    }
    return _cellDicts;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGFloat)bottomHeight {
    CGFloat height = 50.f;
    if (@available(iOS 11.0, *)) {
        height += [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    return height;
}

- (NSMutableArray<PHAsset *> *)photos {
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置导航栏
   
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottonBtnView];
    // 列表和底部按钮容器
    [self.bottonBtnView addSubview:self.confirmBtn];
    [self.bottonBtnView addSubview:self.countButton];
    [self.bottonBtnView addSubview:self.previewB];
    
    [self.countButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.confirmBtn);
        make.right.equalTo(self.confirmBtn.mas_centerX).offset(-25.f);
        make.width.height.mas_equalTo(22.f);
    }];
   
    [self requstPHsource];
}
//请求PHsource快捷资源
-(void)requstPHsource{
    WeakSelf(self)
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        StrongSelf(self)
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized) {
                if ([self.photoTyp isEqualToString:@"photo"]) {
                    [self loadImage];
                    
                } else if ([self.photoTyp isEqualToString:@"videos"]){
                    [self loadVides];
                    
                } else {
                    [self loadImageAndVideos];
                }
                
                [self.collectionView reloadData];
                
            } else if (status == PHAuthorizationStatusRestricted ||
                       status == PHAuthorizationStatusDenied) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"你未获得相册权限，去设置？" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *al = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                [alert addAction:al];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

//从相册获取图片
-(void)loadImage{
    // 获得全部相片
    PHFetchResult<PHAssetCollection *> *cameraRolls = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    for (PHAssetCollection *collection in cameraRolls) {
        // 获得某个相簿中的所有PHAsset对象
        self.assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    }
    
    [self.assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.mediaType == PHAssetMediaTypeImage) {
            [self.photos addObject:obj];
        }
    }];
}
//从相册获取视频
-(void)loadVides
{
    // 获得全部视频
    PHFetchResult<PHAssetCollection *> *videos = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumVideos options:nil];
    
    for (PHAssetCollection *collection in videos) {
        // 获得某个相簿中的所有PHAsset对象
        self.assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    }
}
// 所有数据
- (void)loadImageAndVideos {
    // 获得全部相片
    PHFetchResult<PHAssetCollection *> *cameraRolls = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    for (PHAssetCollection *collection in cameraRolls) {
        // 获得某个相簿中的所有PHAsset对象
        self.assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    }
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.photoTyp isEqualToString:@"photo"])  {
        return self.photos.count;
    }
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CollectionViewCell *cell = [CollectionViewCell CollectionView:collectionView indexPath:indexPath indentfir:cellIdentifier];
    UIImage *fullScreenImage = nil;
    if ([self.photoTyp isEqualToString:@"photo"]) {
        fullScreenImage = [self getImageAndPHAsset:self.photos[self.photos.count-  indexPath.item-1]];;
    } else {
        PHAsset *phasset = self.assets[self.assets.count-  indexPath.item-1];
        cell.phasset = phasset;
        fullScreenImage = [self getImageAndPHAsset:phasset];
    }

    // 设置背景视图
    UIImageView *imageView = (id)cell.backgroundView;
    if ([imageView isKindOfClass:[UIImageView class]]) {
        imageView.image = fullScreenImage;
        
    } else {
        imageView = [[UIImageView alloc] initWithImage:fullScreenImage];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        cell.backgroundView = imageView;
    }
    return cell;
}
-(UIImage *)getImageAndPHAsset:(PHAsset *)pHAsset
{
    self->image = [[UIImage alloc] init];
   
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;//YES 获取高清
    [[PHCachingImageManager defaultManager] requestImageForAsset:pHAsset targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self->image = result;
    }];
    return self->image;
}
#pragma mark - UICollectionViewDelegate
//选择
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    
    CollectionViewCell *cell =(CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
 
    
    PHAsset *phasset = nil;
    if ([self.photoTyp isEqualToString:@"photo"]) {
        phasset = self.photos[self.photos.count-indexPath.item-1];
    } else {
        phasset = self.assets[self.assets.count-indexPath.item-1];
    }
    
    //添加资源
    [self.selectedAssets addObject:phasset];
    
    NSString *x = [[NSString stringWithFormat:@"%f",cell.frame.origin.x] copy];
    NSString *y = [[NSString stringWithFormat:@"%f",cell.frame.origin.y] copy];
    [self.cellDicts addObject:(NSMutableDictionary *)@{@"x":x,@"y":y,@"cell":cell}];
    
    //刷新选中的view
    for (UIView *view in self.selectViews) {
        [view removeFromSuperview];
    }
    [self.selectViews removeAllObjects];
    
    for (int i = 0; i < self.cellDicts.count; i++) {
        NSMutableDictionary *dict = self.cellDicts[i];
        [self addCountButton:dict andCiunt:[NSString stringWithFormat:@"%d",i+1] andTag:0];
    }
    
    [self selectedCound:self.selectedAssets.count];
    
}
//取消选择
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell =(CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
   
    
    //删除资源
    if (self.photos.count) {
        [self.selectedAssets removeObject:self.photos[self.photos.count-indexPath.item-1]];
        
    } else {
        [self.selectedAssets removeObject:self.assets[self.assets.count-indexPath.item-1]];
    }
    
    NSString *x = [[NSString stringWithFormat:@"%f",cell.frame.origin.x] copy];
    NSString *y = [[NSString stringWithFormat:@"%f",cell.frame.origin.y] copy];
   
    //删除选中的cell 的count显示 dict
    for (int i = 0; i<self.cellDicts.count; i++) {
        NSDictionary *dict = self.cellDicts[i];
        if ([dict[@"x"] isEqualToString:x] && [dict[@"y"] isEqualToString:y]) {
            [self.cellDicts removeObjectAtIndex:i];
        }
    }
    
    //刷新选中的view
    for (UIView *view in self.selectViews) {
        [view removeFromSuperview];
    }
    [self.selectViews removeAllObjects];
    
    
    for (int i = 0; i < self.cellDicts.count; i++) {
        NSMutableDictionary *dict = self.cellDicts[i];
        [self addCountButton:dict andCiunt:[NSString stringWithFormat:@"%d",i+1] andTag:0];
    }
    
    [self selectedCound:self.selectedAssets.count];

}

//添加图片count
-(void)addCountButton:(NSMutableDictionary *)cellDect andCiunt:(NSString *)count andTag:(NSInteger)tag
{
    
    CollectionViewCell *cell = cellDect[@"cell"];
    CGFloat x = [cellDect[@"x"] floatValue];
    CGFloat y = [cellDect[@"y"] floatValue];
    CGFloat w = cell.bounds.size.width;
    CGFloat h = cell.bounds.size.height;
    
    UIButton*  _countButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _countButton.frame = CGRectMake(cell.bounds.size.width-40,0, 40, 40);
    [_countButton setImage:[UIImage imageNamed:@"ms_badge"] forState:UIControlStateNormal];
    _countButton.titleLabel.font = [UIFont systemFontOfSize:14];
    //设置_countButton的titleLabel的位置
    _countButton.titleEdgeInsets = UIEdgeInsetsMake(0, -20-5, 0, 0);
    [_countButton setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [_countButton setTitle:count forState:UIControlStateNormal];
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, y,w, h)];
    view.userInteractionEnabled = NO;
    view.tag = tag;
    
    [view addSubview:_countButton];
    [self.collectionView addSubview:view];
    [self.selectViews addObject:view];
   
}
//
-(void)delectView:(CollectionViewCell *)cell
{
    
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(([UIScreen mainScreen].bounds.size.width-2)/3.0, ([UIScreen mainScreen].bounds.size.width-2)/3.0);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}
- (void)confirm:(UIButton *)button
{
    if (self.selectedAssets.count<=0) {
        [SVProgressHUD showMessage:@"请选择"];
 
    } else {
        [self requsetOriginSource];
    }
}

-(void)requsetOriginSource
{
    [SVProgressHUD dismiss];
 
    
    if (self.selectedAssets.count) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"加载资源";
        [self.medias removeAllObjects];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          
            __block NSInteger index = 0;
            for(PHAsset *asset in self.selectedAssets) {
                
                NSString* fileName=[asset valueForKey:@"filename"];
                NSLog(@"fileName:%@",fileName);
                
                
                if (asset.mediaType == PHAssetMediaTypeImage) {
                
                   
                    
                    
                    // 匹配机型有的机型读不出
                    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                    // 同步获得图片, 只会返回1张图片
                    options.synchronous = YES;//YES 获取高清
                    options.networkAccessAllowed = YES;
                    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
//                        NSLog(@"progress = %f", progress);
                        if (error) {
                            progress = -1;
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [hud hideAnimated:YES];
                                [SVProgressHUD showMessage:@"读取失败"];
                            });
                        }
                    };
                    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        if (result) {
                            
                            CacheModel *model = [[CacheModel alloc] init];
                            model.mediaType = MediaType_photo;
                            model.fileName = fileName;
                            model.image = result;
                            model.index = index;
                            [self.medias addObject:model];
                            [self requsetOriginSourceDone:hud];
                            index++;
                        } else {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [hud hideAnimated:YES];
                                [SVProgressHUD showMessage:@"读取失败"];
                            });
                        }
                    }];
                    
                    
                    
                    
                    
                } else if (asset.mediaType == PHAssetMediaTypeVideo) {
                  
                    
                    
                    
                    // 需要设置否则有的机型读不出
                    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                    options.networkAccessAllowed = YES;
                    options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
                    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
//                        NSLog(@"progress = %f", progress);
                        if (error) {
                            progress = -1;
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [hud hideAnimated:YES];
                                [SVProgressHUD showMessage:@"读取失败"];
                            });
                        }
                    };
                    
                    PHImageManager *manager = [PHImageManager defaultManager];
                    [manager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        if (asset) {
                            AVURLAsset *urlAsset = (AVURLAsset *)asset;
                            NSURL *url = urlAsset.URL;
                            
                            CacheModel *model = [[CacheModel alloc] init];
                            model.mediaType = MediaType_video;
                            model.fileName = fileName;
                            model.filePath = url.absoluteString;
                            model.avAsset = urlAsset;
                            model.index = index;
                            [self.medias addObject:model];
                            [self requsetOriginSourceDone:hud];
                            index++;
                            
                        } else {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [hud hideAnimated:YES];
                                [SVProgressHUD showMessage:@"读取失败"];
                            });
                        }
                    }];
                }
            }
            
            
            
            
        });
    }
}

-(void)requsetOriginSourceDone:(MBProgressHUD *)hud{
    if(self.selectedAssets.count == self.medias.count){
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:^{
                if([self.delegate respondsToSelector:@selector(selectVideosAndimages:)]){
                    [self.delegate selectVideosAndimages:self.medias];
                }
            }];
        });
    }
}


//- (void)backWithSelectedMedias:(NSArray *)medias selected:(NSArray*)selecs  hud:(MBProgressHUD*)hud {
//    if (selecs.count > 0 ) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [hud hideAnimated:YES];
//            if (self.seletedBlock) {
//                self.seletedBlock(medias, self.isFocusing);
//            }
//            [self.navigationController popViewControllerAnimated:YES];
//        });
//    }
//}

//获取原图
//- (UIImage *)getImageAndPHAssetPHD:(PHAsset *)pHAsset
//{
//    self->image = [[UIImage alloc] init];
//    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//    // 同步获得图片, 只会返回1张图片
//    options.synchronous = YES;//YES 获取高清
//    [[PHCachingImageManager defaultManager] requestImageForAsset:pHAsset targetSize:PHImageManagerMaximumSize contentMode: PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        self->image = result;
//    }];
//    return self->image;
//}
//获取视频url
//- (void)getVideoUrls
//{
//    videoUrls =[NSMutableArray array];
//    PHImageManager *manager = [PHImageManager defaultManager];
//    for (PHAsset *assetL in self.selectedAssets) {
//
//        [manager requestAVAssetForVideo:assetL options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
//            AVURLAsset *urlAsset = (AVURLAsset *)asset;
//            NSURL *url = urlAsset.URL;
//            [self->videoUrls addObject:@{@"url":url,@"image":[self getImageAndPHAsset:assetL]}];
//
//            if (self.selectedAssets.count == self->videoUrls.count) {
//                if ([self.delegate respondsToSelector:@selector(backVidesUrls:)]) {
//                    [self.delegate backVidesUrls:self->videoUrls];
//                }
//            }
//        }];
//    }
//}

//-(void)bac:(NSMutableArray*)arr
//{
//
//}
-(void)preview:(UIButton *)button
{
   
}
-(void)selectedCound:(NSUInteger )count
{
    CGFloat w = 22;
    CGFloat h = 22;
    
    //1.创建动画
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
    //2.设置关键帧动画的values
    NSValue *value1 = [NSValue valueWithCGRect:CGRectMake(0, 0, w*0.5, h*0.5)];
    NSValue *value2 = [NSValue valueWithCGRect:CGRectMake(0, 0, w*1.1, h*1.1)];
    NSValue *value3 = [NSValue valueWithCGRect:CGRectMake(0, 0, w, h)];
    animation.values = @[value1,value2,value3];
    //3.添加动画
    [self.countButton.imageView.layer addAnimation:animation forKey:@"bounds"];
    NSString *title = [NSString stringWithFormat:@"%lu",count];
    [self.countButton setTitle:title forState:UIControlStateNormal];
}






@end
