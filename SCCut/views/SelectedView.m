//
//  SelectedView.m
//  SCCut
//
//  Created by Stan on 2023/3/21.
//

#import "SelectedView.h"


@interface SelectedView()

@property(nonatomic,strong)UIImageView *left;
@property(nonatomic,strong)UIImageView *right;

@end


@implementation SelectedView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self UI];
    }
    return self;
}

-(void)UI{
    self.layer.borderWidth = 2;
    self.layer.borderColor = [UIColor colorWithRed:248/255.0 green:122/255.0 blue:2/255.0 alpha:1].CGColor;
    self.layer.cornerRadius = 1;
    [self addSubview:self.left];
    [self addSubview:self.right];
    [self addpan];
    [self addpanLeft];
    [self addpanRight];
}

-(UIImageView *)left
{
    if(!_left){
        _left = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 50)];
        _left.image = [UIImage imageNamed:@"select_cut"];
        _left.userInteractionEnabled = YES;
    }
    return _left;
}

-(UIImageView *)right
{
    if(!_right){
        _right = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-20, 0,20, 50)];
        _right.image = [UIImage imageNamed:@"select_cut"];
        _right.userInteractionEnabled = YES;
    }
    return _right;
    
}

-(void)layoutSubviews{
    self.left.frame = CGRectMake(0, 0, 20, 50);
    self.right.frame = CGRectMake(self.bounds.size.width-20, 0, 20, 50);
}


#pragma mark - 拖拽
-(void)addpan
{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    //    panGestureRecognizer.delegate = self;
//    [self addGestureRecognizer:panGestureRecognizer];
}
-(void)addpanLeft
{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panLeft:)];
    [self.left addGestureRecognizer:panGestureRecognizer];
}
-(void)addpanRight
{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRight:)];
    [self.right addGestureRecognizer:panGestureRecognizer];
}


-(void)pan:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self];
    self.frame = CGRectMake(self.frame.origin.x + point.x, 0, self.bounds.size.width, 50);
    [pan setTranslation:CGPointZero inView:self];
}
-(void)panLeft:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self];
    CGPoint pointToWindow =   [self convertPoint:point fromView:k_window];
    CGRect rightToView =  [self.left convertRect:self.right.frame fromView:k_window];
    if(pointToWindow.x + 30 > rightToView.origin.x) return;
    self.frame = CGRectMake(self.frame.origin.x + point.x, 0, self.bounds.size.width -  point.x, 50);
    [pan setTranslation:CGPointZero inView:self];
}
-(void)panRight:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self];
    CGPoint pointToWindow =   [self convertPoint:point fromView:k_window];
    CGRect leftToView =   [self.right convertRect:self.left.frame fromView:k_window];
    if(pointToWindow.x - 30 < leftToView.origin.x) return;
    self.frame = CGRectMake(self.frame.origin.x, 0, self.bounds.size.width + point.x, 50);
    [pan setTranslation:CGPointZero inView:self];
}




@end
