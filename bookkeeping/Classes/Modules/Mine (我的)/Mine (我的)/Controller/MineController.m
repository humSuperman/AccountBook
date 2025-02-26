/**
 * 记账
 * @author Hum 2025-02-26
 */

#import "MineController.h"
#import "CategoryController.h"
#import "WebVC.h"
#import "AboutController.h"
#import "DatabaseManager.h"
#import "MINE_EVENT_MANAGER.h"
#import <MobileCoreServices/MobileCoreServices.h>

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
}
// 详情
- (void)detailChangeRequest:(NSNumber *)isOn {
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:isOn, @"detail", nil];;
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
            CategoryController *vc = [[CategoryController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [[DatabaseManager sharedManager] closeDatabase];
            @try {
                [self shareFile];
                [[DatabaseManager sharedManager] openDatabase];
            } @catch (NSException *exception){
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                [self showTextHUD:@"保存数据发生了错误" delay:1.5f];
                return;
            } @finally {
                [[DatabaseManager sharedManager] openDatabase];
            }
        } else if (indexPath.row == 1) {
            [[DatabaseManager sharedManager] closeDatabase];
            @try {
                [self importFile];
            } @catch (NSException *exception){
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                [self showTextHUD:@"导入数据发生了错误" delay:1.5f];
                return;
            } @finally {
                NSLog( @" 导入成功，打开数据库");
                [[DatabaseManager sharedManager] openDatabase];
            }
        }
    }
    else if (indexPath.section == 2) {
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

- (void)shareFile {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:@"bookkeeping.db"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self showTextHUD:@"文件未找到" delay:1.5f];
        return;
    }
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];

    activityVC.excludedActivityTypes = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook];

    if (@available(iOS 10.0, *)) {
        [self presentViewController:activityVC animated:YES completion:nil];
    } else {
        [self presentViewController:activityVC animated:YES completion:nil];
    }

    [activityVC setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray  * _Nullable returnedItems, NSError  * _Nullable activityError) {
        [self leftButtonClick];
        if (completed) {
            [self showTextHUD:@"文件导出成功" delay:1.5f];
        } else {
            [self showTextHUD:@"文件导出失败" delay:1.5f];
        }
    }];
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

// 点击导入按钮时触发
- (void)importFile {
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeItem] inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.allowsMultipleSelection = NO;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate

// 用户选中文件后的回调
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *fileURL = [urls firstObject];
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *destinationPath = [documentDirectory stringByAppendingPathComponent:@"bookkeeping.db"]; // 替换为你要覆盖的文件名
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:&error];
    }
    BOOL success = [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:[NSURL fileURLWithPath:destinationPath] error:&error];
    if (success) {
        [self showTextHUD:@"文件导入成功！重启应用生效" delay:3.0f];
    } else {
        NSLog(@"文件导入失败: %@", error.localizedDescription);
        [self showTextHUD:@"文件导入失败" delay:1.5f];
    }
}

// 用户取消文件选择的回调
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"用户取消了文件选择");
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
