//
//  MediaSelects.h
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PHAsset;
@protocol MediaSelectsDelegate <NSObject>
@optional
-(void)selectVideosAndimages:(NSMutableArray*)sources;
@end

@interface MediaSelects : UIViewController
@property(nonatomic,copy)NSString *photoTyp;
@property(nonatomic,weak)id <MediaSelectsDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
