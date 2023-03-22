//
//  SCCollection.m
//  SCCut
//
//  Created by Stan on 2023/3/14.
//

#import "SCCollection.h"

@interface SCCollection()

@end

@implementation SCCollection

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if([self.sCCollectionDelegate respondsToSelector:@selector(touchesBegan)]){
        [self.sCCollectionDelegate touchesBegan];
    }
}


@end
