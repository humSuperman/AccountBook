/**
 * 系统配置
 * @author 郑业强 2018-12-16 创建文件
 */

#import "AppDelegate.h"
#import "DatabaseManager.h"


#pragma mark - 声明
@interface AppDelegate ()

@end


#pragma mark - 实现
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 根控制器
    [self makeRootController];
    // 系统配置
    [self systemConfig];
    // 数据库
    [[DatabaseManager sharedManager] openDatabase];
    
    return YES;
}
// 根控制器
- (void)makeRootController {
    [self setWindow:[[UIWindow alloc] initWithFrame:SCREEN_BOUNDS]];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window setRootViewController:[[BaseTabBarController alloc] init]];
    [self.window makeKeyAndVisible];
}
// 配置
- (void)systemConfig {
    [[UITextField appearance] setTintColor:kColor_Main_Color];
}



// 支持所有iOS系统
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    
    return YES;
}


// 去后台
- (void)applicationWillResignActive:(UIApplication *)application {
    [[DatabaseManager sharedManager] closeDatabase];
    [ScreenBlurry addBlurryScreenImage];
}
// 回前台
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[DatabaseManager sharedManager] openDatabase];
    [ScreenBlurry removeBlurryScreenImage];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[DatabaseManager sharedManager] closeDatabase];
    NSLog(@"Application will terminate.");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[DatabaseManager sharedManager] closeDatabase];
}




@end
