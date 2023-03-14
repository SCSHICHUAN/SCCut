//
//  Font.h
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#ifndef Font_h
#define Font_h


#define MEDIUMSYSTEMFONT(FONTSIZE)  [UIFont systemFontOfSize:FONTSIZE]
#define BOLDSYSTEMFONT(FONTSIZE)    [UIFont fontWithName:@"PingFang-SC-Medium" size:(FONTSIZE)]
#define SYSTEMFONT(FONTSIZE)        [UIFont systemFontOfSize:FONTSIZE]
#define FONT(NAME, FONTSIZE)        [UIFont fontWithName:(NAME) size:(FONTSIZE)]


// 定义UIImage对象
#define ImageWithFile(_pointer) [UIImage imageWithContentsOfFile:([[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@%dx", _pointer, (int)[UIScreen mainScreen].nativeScale] ofType:@"png"])]
#define IMAGE_NAMED(name) [UIImage imageNamed:name]


#endif /* Font_h */
