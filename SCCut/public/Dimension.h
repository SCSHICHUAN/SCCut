//
//  Dimension.h
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#ifndef Dimension_h
#define Dimension_h

#define iphone_6_w 375
#define iphone_6_h 667


#define K_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define K_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define W = (iphone_6_w/(K_WIDTH * 1.0))
#define H = (iphone_6_h/(K_HEIGHT * 1.0))


#endif /* Dimension_h */
