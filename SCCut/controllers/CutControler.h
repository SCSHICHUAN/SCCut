//
//  CutControler.h
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#import <UIKit/UIKit.h>
#import "CacheModel.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CutControler : UIViewController

@property(nonatomic,strong) CacheModel *model;
//@property(nonatomic,strong) NSMutableArray *arr;
@property(nonatomic,strong) NSMutableArray *assetArray;
@property(nonatomic,strong) NSMutableArray *sourceSessionArry;
-(void)addPlayItem;

@property(nonatomic,strong)AVMutableComposition *composition1;
@property(nonatomic,strong)AVMutableVideoComposition *videoComposition1;

@end

NS_ASSUME_NONNULL_END
