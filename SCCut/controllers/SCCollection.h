//
//  SCCollection.h
//  SCCut
//
//  Created by Stan on 2023/3/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCCollectionDelegate <NSObject>

-(void)touchesBegan;

@end

@interface SCCollection : UICollectionView

@property(nonatomic,weak)id<SCCollectionDelegate> sCCollectionDelegate;

@end

NS_ASSUME_NONNULL_END
