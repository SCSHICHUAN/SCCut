//
//  CutControler.h
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#import <UIKit/UIKit.h>
#import "CacheModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CutControler : UIViewController

@property(nonatomic,strong) CacheModel *model;
//@property(nonatomic,strong) NSMutableArray *arr;
@property(nonatomic,strong) NSMutableArray *assetArray;
@property(nonatomic,strong) NSMutableArray *sourceSessionArry;
-(void)addPlayItem;

@end

NS_ASSUME_NONNULL_END
