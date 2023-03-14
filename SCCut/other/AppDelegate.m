//
//  AppDelegate.m
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#import "AppDelegate.h"
#import "Welcome.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UITabBarController *tab = [[UITabBarController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tab];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
   
    Welcome *we = [[Welcome alloc] init];
    [tab addChildViewController:we];
    
    
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
