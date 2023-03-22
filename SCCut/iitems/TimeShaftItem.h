//
//  TimeShaftItem.h
//  SCCut
//
//  Created by Stan on 2023/3/8.
//

#import <UIKit/UIKit.h>
#import "FrameModel.h"
NS_ASSUME_NONNULL_BEGIN


static  NSString *timeShaftItemIdent = @"TimeShaftItem";

@interface TimeShaftItem : UICollectionViewCell

@property(nonatomic,strong)FrameModel *frameModel;

@end

NS_ASSUME_NONNULL_END
