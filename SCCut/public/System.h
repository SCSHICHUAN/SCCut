//
//  System.h
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#ifndef System_h
#define System_h


#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define WeakSelf(type)      __weak typeof(type) weak##type = type;
#define StrongSelf(type)    __strong typeof(type) type = weak##type;

// 缓存相册
#define PHOTOCACHEPATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"photoCache"]

// 缓存视频
#define VIDEOCACHEPATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"videoCache"]

#endif /* System_h */
