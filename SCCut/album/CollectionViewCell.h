//
//  CollectionViewCell.h
//  XNEWS
//
//  Created by 石川 on 2019/7/5.
//  Copyright © 2019 沈树亮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) PHAsset *phasset;

+(CollectionViewCell *)CollectionView:(UICollectionView *)collView indexPath:(NSIndexPath*)indexpath indentfir:(NSString*)indentfir;
- (void)addToShoppingCartWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint completion:(void (^)(BOOL))completion;
@end

NS_ASSUME_NONNULL_END
