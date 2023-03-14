//
//  IndexModel.h
//  SCCut
//
//  Created by Stan on 2023/3/14.
//

#import <Foundation/Foundation.h>
#import "QualityModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface IndexModel : NSObject

@property(nonatomic,assign)NSInteger gorup_index;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,strong)QualityModel *model;

@end

NS_ASSUME_NONNULL_END
