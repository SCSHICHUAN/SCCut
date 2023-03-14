//
//  Color.h
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#ifndef Color_h
#define Color_h


#define ClearColor      [UIColor clearColor]
#define WhiteColor      [UIColor whiteColor]
#define BlackColor      [UIColor blackColor]
#define GrayColor       [UIColor grayColor]
#define Gray2Color      [UIColor lightGrayColor]
#define BlueColor       [UIColor blueColor]
#define RedColor        [UIColor redColor]
#define HEX_RGBA(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]
#define HEX_RGB(rgbValue)[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(1)]
#define RGB(R,G,B)        [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]
#define RGBA(R,G,B,A)    [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]



#endif /* Color_h */
