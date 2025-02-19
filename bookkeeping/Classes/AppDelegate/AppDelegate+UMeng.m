/**
 * 友盟m配置
 * @author 郑业强 2018-12-22 创建文件
 */

#import "AppDelegate+UMeng.h"

@implementation AppDelegate (UMeng)


// 友盟分享
- (void)shareUMengConfig {
    [UMConfigure initWithAppkey:kUMengAppKey channel:@"App Store"];
}


@end
