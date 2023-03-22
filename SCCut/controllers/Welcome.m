//
//  Welcome.m
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#import "Welcome.h"
#import "CutControler.h"
#import "MediaSelects.h"
#import "CacheModel.h"
#import "Cache.h"
#import "GetFrame.h"
#import <Photos/Photos.h>
#import "IndexModel.h"

@interface Welcome ()<MediaSelectsDelegate>
@property (nonatomic,strong)UIButton *start;
@end

@implementation Welcome

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"welcome";
    [self.view addSubview:self.start];
    
}
-(UIButton *)start{
    if(!_start){
        _start = [UIButton buttonWithType:UIButtonTypeCustom];
        _start.frame = CGRectMake(10, 100,K_WIDTH-20, 110);
        [_start setTitle:@"开始创作" forState:UIControlStateNormal];
        [_start addTarget:self action:@selector(started) forControlEvents:UIControlEventTouchUpInside];
        [_start setImage:[UIImage imageNamed:@"IMG_7421"] forState:UIControlStateNormal];
        _start.backgroundColor = UIColor.blackColor;
    }
    
    return _start;
}

-(void)started{
    
    
    MediaSelects *vc = [[MediaSelects alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.delegate = self;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
    NSLog(@"%@",NSHomeDirectory());
}


#pragma mark-MediaSelectsDelegate
-(void)selectVideosAndimages:(NSMutableArray *)sources{
    
    CutControler *cut = [[CutControler alloc] init];
    cut.assetArray = sources;
    cut.modalPresentationStyle = UIModalPresentationFullScreen;
    [cut addPlayItem];
    [self.navigationController presentViewController:cut animated:YES completion:nil];
    
    
    NSMutableArray *session = [NSMutableArray array];
    for (NSInteger i = 0; i < sources.count; i++) {
        NSMutableArray *part = [NSMutableArray array];
        [session addObject:part];
        cut.sourceSessionArry = session;
    }
    
    for (NSInteger i = 0; i < sources.count; i++) {
        CacheModel *model = sources[i];
        if(model.mediaType == MediaType_video){
            [GetFrame QualitychangeInput:model.avAsset witchIndex:i];
        }
    }
}

@end
