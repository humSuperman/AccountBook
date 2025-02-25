/**
 * 分类
 * @author Hum 2025-02-19 添加本地数据
 */

#import "CAController.h"
#import "CAHeader.h"
#import "CategoryTable.h"
#import "BottomButton.h"
#import "ACAController.h"
#import "CategoryCell.h"
#import "CategoryListModel.h"
#import "CategoryModel.h"
#import "CA_EVENT.h"


#pragma mark - 声明
@interface CAController()

@property (nonatomic, strong) CAHeader *header;
@property (nonatomic, strong) CategoryTable *table;
@property (nonatomic, strong) BottomButton *bootom;
@property (nonatomic, strong) NSMutableArray<CategoryListModel *> *models;
@property (nonatomic, strong) NSDictionary<NSString *, NSInvocation *> *eventStrategy;

@end


#pragma mark - 实现
@implementation CAController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"类别设置"];
    [self setJz_navigationBarHidden:NO];
    [self setJz_navigationBarTintColor:kColor_Main_Color];
    [self header];
    [self table];
    [self bootom];
    [self.rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [self.rightButton setTitle:@"完成" forState:UIControlStateHighlighted];
    [self.view bringSubviewToFront:self.bootom];
    if (_is_income == true) {
        [_header.seg setSelectedSegmentIndex:1];
    }
    [self monitorNotification];
    dispatch_async(dispatch_get_main_queue(), ^{

        NSMutableDictionary *conditions = [NSMutableDictionary dictionary];

        CategoryListModel *model1 = [[CategoryListModel alloc] init];
        model1.is_income = 0;
        [conditions setObject:@(0) forKey:@"type ="];
        model1.insert = [NSMutableArray arrayWithArray:[CategoryModel getAllCategories:conditions]];

        CategoryListModel *model2 = [[CategoryListModel alloc] init];
        conditions = [NSMutableDictionary dictionary];
        [conditions setObject:@(1) forKey:@"type ="];
        model2.is_income = 1;
        model2.insert = [NSMutableArray arrayWithArray:[CategoryModel getAllCategories:conditions]];

        [self setModels:[NSMutableArray arrayWithArray:@[model1, model2]]];
    });
}

// 监听通知
- (void)monitorNotification {
    @weakify(self)
    // 删除记账
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:CATEGORY_DELETE object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self)
        NSMutableDictionary *conditions = [NSMutableDictionary dictionary];

        CategoryListModel *model1 = [[CategoryListModel alloc] init];
        model1.is_income = 0;
        [conditions setObject:@(0) forKey:@"type ="];
        model1.insert = [NSMutableArray arrayWithArray:[CategoryModel getAllCategories:conditions]];

        CategoryListModel *model2 = [[CategoryListModel alloc] init];
        conditions = [NSMutableDictionary dictionary];
        [conditions setObject:@(1) forKey:@"type ="];
        model2.is_income = 1;
        model2.insert = [NSMutableArray arrayWithArray:[CategoryModel getAllCategories:conditions]];
        [self setModels:[NSMutableArray arrayWithArray:@[model1, model2]]];
    }];
}

#pragma mark - set
- (void)setModels:(NSMutableArray<CategoryListModel *> *)models {
    _models = models;
    _table.model = _models[_header.seg.selectedSegmentIndex];
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
// 添加类别
- (void)categoryBtnClick:(id)data {
    ACAController *vc = [[ACAController alloc] init];
    [vc setIs_income:_header.seg.selectedSegmentIndex == 0 ? false : true];
    [vc setComplete:^(CategoryModel *submodel) {
        NSInteger index = self.header.seg.selectedSegmentIndex;
        CategoryListModel *model = self.models[self.header.seg.selectedSegmentIndex];
        [model.insert addObject:submodel];
        [self.models replaceObjectAtIndex:index withObject:model];
        [self.table reloadData];

        if (self.complete) {
            self.complete();
        }
    }];
    [self.navigationController pushViewController:vc animated:YES];
}
// 值改变
- (void)segValueChange:(NSNumber *)number {
    _table.model = _models[[number integerValue]];
}
// 删除cell
- (void)deleteCellClick:(CategoryCell *)cell {
    @weakify(self)
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"删除类别会同时删除该类别下的所有历史收支记录" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *number) {
        @strongify(self)
        NSInteger index = [number integerValue];
        // 确定
        if (index == 1) {
            [self deleteWithCell:cell];
        }
    }];
}
- (void)updateCellSort:(CategoryCell *)cell {
    NSLog(@" 重新排序 %@",cell);
    NSLog(@" 重新排序 %@",cell.indexPath);
}
// 删除cell
- (void)deleteWithCell:(CategoryCell *)cell {
    NSLog(@" deleteWithCell %@",cell);
    // 回调
    [CategoryModel deleteCategoryById:cell.model.Id];
    [[NSNotificationCenter defaultCenter] postNotificationName:CATEGORY_DELETE object:nil];
    if (self.complete) {
        self.complete();
    }
}



#pragma mark - get
- (CAHeader *)header {
    if (!_header) {
        _header = [CAHeader loadFirstNib:CGRectMake(0, NavigationBarHeight, SCREEN_WIDTH, countcoordinatesX(50))];
        [self.view addSubview:_header];
    }
    return _header;
}
- (CategoryTable *)table {
    if (!_table) {
        _table = [CategoryTable initWithFrame:CGRectMake(0, _header.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - self.header.bottom - self.bootom.height)];
        [self.view addSubview:_table];
    }
    return _table;
}
- (BottomButton *)bootom {
    if (!_bootom) {
        _bootom = [BottomButton initWithFrame:({
            CGFloat height = countcoordinatesX(50) + SafeAreaBottomHeight;
            CGFloat top = SCREEN_HEIGHT - height;
            CGRectMake(0, top, SCREEN_WIDTH, height);
        })];
        [_bootom setName:@"添加类别"];
        [self.view addSubview:_bootom];
    }
    return _bootom;
}
- (NSDictionary<NSString *, NSInvocation *> *)eventStrategy {
    if (!_eventStrategy) {
        _eventStrategy = @{
                           CATEGORY_BTN_CLICK: [self createInvocationWithSelector:@selector(categoryBtnClick:)],
                           CATEGORY_SEG_CHANGE: [self createInvocationWithSelector:@selector(segValueChange:)],
                           CATEGORY_ACTION_DELETE_CLICK: [self createInvocationWithSelector:@selector(deleteCellClick:)],
                           CATEGORY_ACTION_INSERT_CLICK: [self createInvocationWithSelector:@selector(updateCellSort:)],
                           };
    }
    return _eventStrategy;
}


@end
