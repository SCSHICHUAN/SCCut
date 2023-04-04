//
//  SCCutPlayer.h
//  SCCut
//
//  Created by Stan on 2023/4/3.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCCutPlayer : UIView

@property(nonatomic,assign)CGSize renderSize;
@property(nonatomic,strong)AVMutableComposition *composition;
@property(nonatomic,strong)AVMutableVideoComposition *videoComposition;


-(void)addAsset:(AVAsset *)asset;
-(void)addAssets:(NSArray<AVAsset*> *)assets;
-(void)createTracks;



@end

NS_ASSUME_NONNULL_END
