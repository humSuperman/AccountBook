/**
 * 登录
 * @author 郑业强 2018-12-17 创建文件
 */


#import "LoginController.h"
#import "RE1Controller.h"
#import "PhoneController.h"
#import "BaseViewController+Extension.h"
#import "LOGIN_NOTIFICATION.h"


#pragma mark - 声明
@interface LoginController()

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UIImageView *nameIcn;
@property (weak, nonatomic) IBOutlet UIButton *wxLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreBtnConstraintB;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wxConstraintH;

@end


#pragma mark - 实现
@implementation LoginController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setJz_navigationBarHidden:YES];
    
    [self.wxLoginBtn.layer setCornerRadius:3];
    [self.wxLoginBtn.layer setMasksToBounds:YES];
    [self.wxLoginBtn setTitleColor:kColor_Text_Black forState:UIControlStateNormal];
    [self.wxLoginBtn setTitleColor:kColor_Text_Black forState:UIControlStateHighlighted];
    [self.wxLoginBtn setBackgroundImage:[UIColor createImageWithColor:kColor_Main_Color] forState:UIControlStateNormal];
    [self.wxLoginBtn setBackgroundImage:[UIColor createImageWithColor:kColor_Main_Dark_Color] forState:UIControlStateHighlighted];
    [self.wxLoginBtn.titleLabel setFont:[UIFont systemFontOfSize:AdjustFont(14)]];
    [self.moreBtn.titleLabel setFont:[UIFont systemFontOfSize:AdjustFont(12)]];
    [self.moreBtn setTitleColor:kColor_Text_Gary forState:UIControlStateNormal];
    [self.moreBtn setTitleColor:kColor_Text_Gary forState:UIControlStateHighlighted];
    
    [self.moreBtnConstraintB setConstant:countcoordinatesX(20) + SafeAreaBottomHeight];
    [self.wxConstraintH setConstant:countcoordinatesX(45)];
    
    [self rac_notification_register];
}

// 监听通知
- (void)rac_notification_register {
    @weakify(self)
    // 忘记密码完成
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:LOPGIN_FORGET_COMPLETE object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        NSLog(@"忘记密码完成");
    }];
    // 注册完成
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:LOPGIN_REGISTER_COMPLETE object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self)
        // 回调
        if (self.complete) {
            self.complete();
        }
        // 关闭
        [self.navigationController dismissViewControllerAnimated:true completion:nil];
    }];
    // 登录完成
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:LOPGIN_LOGIN_COMPLETE object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self)
        // 回调
        if (self.complete) {
            self.complete();
        }
        // 关闭
        [self.navigationController dismissViewControllerAnimated:true completion:nil];
    }];
    
    
}


#pragma mark - 请求
// QQ登录
- (void)getQQLoginRequest:(UMSocialUserInfoResponse *)resp {

}


#pragma mark - 点击
// 关闭
- (IBAction)closeBtnClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
// 微信
- (IBAction)wxBtnClick:(UIButton *)sender {
    [self startQQLogin:^{
        [self.navigationController dismissViewControllerAnimated:true completion:nil];
    }];
    
}
// 更多登录方式
- (IBAction)moreBtnClick:(UIButton *)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"注册", @"手机登录", nil];
    [sheet showInView:self.view];
    [[sheet rac_buttonClickedSignal] subscribeNext:^(NSNumber *number) {
        NSInteger index = [number integerValue];
        // 注册
        if (index == 0) {
            RE1Controller *vc = [[RE1Controller alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        // 手机登录
        else if (index == 1) {
            PhoneController *vc = [[PhoneController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}


@end
