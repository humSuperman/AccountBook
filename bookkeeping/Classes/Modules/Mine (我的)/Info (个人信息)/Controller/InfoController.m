/**
 * 个人信息
 * @author 郑业强 2018-12-22 创建文件
 */

#import "InfoController.h"
#import "InfoTableView.h"
#import "CPAController.h"


#pragma mark - 声明
@interface InfoController()

@property (nonatomic, strong) InfoTableView *table;
@property (nonatomic, strong) UserModel *model;
@property (nonatomic, strong) NSDictionary<NSString *, NSInvocation *> *eventStrategy;

@end


#pragma mark - 实现
@implementation InfoController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"个人信息"];
    [self setJz_navigationBarTintColor:kColor_Main_Color];
    [self setJz_navigationBarHidden:NO];
    [self.view setBackgroundColor:kColor_Line_Color];
    [self table];
    [self setModel:[UserInfo loadUserInfo]];
}


#pragma mark - 请求
// 更换头像
- (void)changeIconRequest:(UIImage *)image {
}
// 更改昵称
- (void)changeNickRequest:(NSString *)nickName {
}
// 更改性别
- (void)changeSexRequest:(NSInteger)sex {
}


#pragma mark - set
- (void)setModel:(UserModel *)model {
    _model = model;
    _table.model = model;
}


#pragma mark - 事件
- (void)routerEventWithName:(NSString *)eventName data:(id)data {
    [self handleEventWithName:eventName data:data];
}
- (void)handleEventWithName:(NSString *)eventName data:(id)data {
    NSInvocation *invocation = self.eventStrategy[eventName];
    [invocation setArgument:&data atIndex:2];
    [invocation invoke];
    [super routerEventWithName:eventName data:data];
}
// 点击cell
- (void)cellClick:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
    } else {
        CPAController *vc = [[CPAController alloc] init];
        [self.navigationController pushViewController:vc animated:true];
    }
}
// 退出登录
- (void)footerClick:(id)data {
}
- (void)txtValueChange:(UITextField *)textField {
    if (textField.text.length > 8) {
        textField.text = [textField.text substringToIndex:8];
    }
}


#pragma mark - get
- (InfoTableView *)table {
    if (!_table) {
        _table = [[InfoTableView alloc] initWithFrame:CGRectMake(0, NavigationBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - NavigationBarHeight) style:UITableViewStylePlain];
        [self.view addSubview:_table];
    }
    return _table;
}
- (NSDictionary<NSString *, NSInvocation *> *)eventStrategy {
    return _eventStrategy;
}

@end
