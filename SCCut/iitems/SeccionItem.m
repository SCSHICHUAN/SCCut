//
//  SeccionItem.m
//  SCCut
//
//  Created by Stan on 2023/3/22.
//

#import "SeccionItem.h"
#import "TimeShaftItem.h"

@interface SeccionItem ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong)UICollectionView *partCollectView;

@end

@implementation SeccionItem

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self UI];
    }
    return self;
}
-(void)UI{
    [self.contentView addSubview:self.partCollectView];
}

-(UICollectionView *)partCollectView{
    if(!_partCollectView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(50, 50);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _partCollectView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [_partCollectView registerClass:[TimeShaftItem class] forCellWithReuseIdentifier:timeShaftItemIdent];
        _partCollectView.dataSource = self;
        _partCollectView.delegate = self;
    }
    return _partCollectView;
}

-(void)layoutSubviews{
    self.partCollectView.frame = self.bounds;
}
-(void)setPartArry:(NSMutableArray *)partArry{
    _partArry = partArry;
    [self.partCollectView reloadData];
}
#pragma mark-UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
     return self.partArry.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TimeShaftItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:timeShaftItemIdent forIndexPath:indexPath];
    FrameModel *model =  self.partArry[indexPath.item];
    item.frameModel = model;
    return item;
}
@end
