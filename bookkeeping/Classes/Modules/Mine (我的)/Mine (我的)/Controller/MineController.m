/**
 * 记账
 * @author 郑业强 2018-12-16 创建文件
 */

#import "MineController.h"
#import "CAController.h"
#import "WebVC.h"
#import "AboutController.h"
#import "MINE_EVENT_MANAGER.h"


#pragma mark - 声明
@interface MineController()

@property (nonatomic, strong) UserModel *model;
@property (nonatomic, strong) NSDictionary<NSString *, NSInvocation *> *eventStrategy;

@end


#pragma mark - 实现
@implementation MineController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setJz_navigationBarHidden:YES];
    [self mine];
    [self setupUI];
}
- (void)setupUI {
    
}


#pragma mark - 请求
// 声音
- (void)soundChangeRequest:(NSNumber *)isOn {
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:isOn, @"sound", nil];;
    [AFNManager POST:SoundRequest params:param complete:^(APPResult *result) {
        UserModel *model = [UserInfo loadUserInfo];
        model.sound = [isOn integerValue];
        [UserInfo saveUserModel:model];
    }];
}
// 详情
- (void)detailChangeRequest:(NSNumber *)isOn {
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:isOn, @"detail", nil];;
    [AFNManager POST:DetailRequest params:param complete:^(APPResult *result) {
        UserModel *model = [UserInfo loadUserInfo];
        model.detail = [isOn integerValue];
        [UserInfo saveUserModel:model];
    }];
}


#pragma mark - set
// 数据
- (void)setModel:(UserModel *)model {
    _model = model;
    _mine.model = model;
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
// Cell
- (void)mineCellClick:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // 类别
        if (indexPath.row == 0) {
            CAController *vc = [[CAController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            WebVC *vc = [[WebVC alloc] init];
            [vc setNavTitle:@"帮助"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        // 关于
        else if (indexPath.row == 1 ) {
            AboutController *vc = [[AboutController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
// 头像
- (void)headerIconClick:(id)data {
    
}
// 切换声音
- (void)soundClick:(NSNumber *)isOn {
    NSNumber *sound = [NSUserDefaults objectForKey:PIN_SETTING_SOUND];
    NSNumber *sound_synced = [NSUserDefaults objectForKey:PIN_SETTING_SOUND_SYNCED];
    sound = @(![sound boolValue]);
    [NSUserDefaults setObject:sound forKey:PIN_SETTING_SOUND];
    if (![sound isEqual:sound_synced]) {
        [NSUserDefaults setObject:sound forKey:PIN_SETTING_SOUND_SYNCED];
    }
    
}
// 切换详情
- (void)detailClick:(NSNumber *)isOn {
    NSNumber *detail = [NSUserDefaults objectForKey:PIN_SETTING_DETAIL];
    NSNumber *detail_synced = [NSUserDefaults objectForKey:PIN_SETTING_DETAIL_SYNCED];
    detail = @(![detail boolValue]);
    [NSUserDefaults setObject:detail forKey:PIN_SETTING_DETAIL];
    if (![detail isEqual:detail_synced]) {
        [NSUserDefaults setObject:detail forKey:PIN_SETTING_DETAIL_SYNCED];
    }
}


#pragma mark - get
- (MineView *)mine {
    if (!_mine) {
        _mine = [MineView loadCode:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - TabbarHeight)];
        [self.view addSubview:_mine];
    }
    return _mine;
}
- (NSDictionary<NSString *, NSInvocation *> *)eventStrategy {
    if (!_eventStrategy) {
        _eventStrategy = @{
                           MINE_CELL_CLICK: [self createInvocationWithSelector:@selector(mineCellClick:)],
                           MINE_HEADER_ICON_CLICK: [self createInvocationWithSelector:@selector(headerIconClick:)],
                           MINE_SOUND_CLICK: [self createInvocationWithSelector:@selector(soundClick:)],
                           MINE_DETAIL_CLICK: [self createInvocationWithSelector:@selector(detailClick:)]
                           };
    }
    return _eventStrategy;
}


#pragma mark - 系统
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setModel:[UserInfo loadUserInfo]];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupUI];
}


@end
