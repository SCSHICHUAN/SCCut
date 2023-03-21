//
//  TimeShaftItem.h
//  SCCut
//
//  Created by Stan on 2023/3/8.
//

#import <UIKit/UIKit.h>
#import "QualityModel.h"
NS_ASSUME_NONNULL_BEGIN


static  NSString *timeShaftItemIdent = @"TimeShaftItem";

@interface TimeShaftItem : UICollectionViewCell

@property(nonatomic,strong)QualityModel *qualityModel;

@end

NS_ASSUME_NONNULL_END
