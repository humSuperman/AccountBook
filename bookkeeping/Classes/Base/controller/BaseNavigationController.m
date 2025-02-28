/**
 * 导航栏
 * @author Hum 2025-02-25
 */

#import "BaseNavigationController.h"

#pragma mark - 声明
@interface BaseNavigationController ()

@end

#pragma mark - 实现
@implementation BaseNavigationController


#pragma mark - 初始化
+ (instancetype)initWithRootViewController:(UIViewController *)vc {
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    nav.jz_navigationBarTransitionStyle = JZNavigationBarTransitionStyleSystem;
    return nav;
}

- (void)viewDidLayoutSubviews {
    
    // 顶部标题栏及按钮被遮盖的bug
    [super viewDidLayoutSubviews];
    UINavigationBar *navigationBar = self.navigationBar;
    if (!navigationBar) {
        return;
    }
    
    UIView *navigationBarContentView = nil;
    for (UIView *subview in navigationBar.subviews) {
        if ([NSStringFromClass([subview class]) isEqualToString:@"_UINavigationBarContentView"]) {
            navigationBarContentView = subview;
            break;
        }
    }
        
    if (navigationBarContentView) {
        for (UIView *subview in navigationBar.subviews) {
            if ([subview isKindOfClass:[UIView class]]) {
                [navigationBarContentView setBackgroundColor:kColor_Main_Color];
                subview.frame = CGRectMake(0, 0, 0, 0);
                [navigationBar insertSubview:subview belowSubview:navigationBarContentView];
            }
        }
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BaseViewController *vc = (BaseViewController *)viewController;
    if (self.viewControllers.count == 1) {
        vc.leftButton.hidden = true;
        vc.hidesBottomBarWhenPushed = true;
    } else {
        vc.leftButton.hidden = false;
        vc.hidesBottomBarWhenPushed = false;
    }
    
    [super pushViewController:viewController animated:animated];
}

@end

