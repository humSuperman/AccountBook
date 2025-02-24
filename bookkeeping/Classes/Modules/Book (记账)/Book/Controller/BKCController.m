/**
 * 记账分类
 * @author Hum 2025-02-20 创建文件
 */

#import "BKCController.h"
#import "BKCCollection.h"
#import "BKCNavigation.h"
#import "BKCKeyboard.h"
#import "BKCIncomeModel.h"
#import "CAController.h"
#import "KKRefreshGifHeader.h"
#import "BOOK_EVENT.h"
#import "BKModel.h"
#import "CategoryModel.h"
#import "MoneyConverter.h"


#pragma mark - 声明
@interface BKCController()<UIScrollViewDelegate>

@property (nonatomic, strong) BKCNavigation *navigation;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) NSMutableArray<BKCCollection *> *collections;
@property (nonatomic, strong) BKCKeyboard *keyboard;
@property (nonatomic, strong) NSArray<BKCIncomeModel *> *models;
@property (nonatomic, strong) NSDictionary<NSString *, NSInvocation *> *eventStrategy;

@end


#pragma mark - 实现
@implementation BKCController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setJz_navigationBarHidden:YES];
    [self setTitle:@"记账"];
    [self navigation];
    [self scroll];
    [self collections];
    [self keyboard];
    [self bendiData];

    if (_model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL is_income = (self.model.type == 1);
            [self.scroll setContentOffset:CGPointMake(SCREEN_WIDTH * is_income, 0) animated:false];
            [self.navigation setOffsetX:self.scroll.contentOffset.x];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BKCCollection *collection = self.collections[is_income];
                NSArray<CategoryModel *> *arrm = [NSArray array];
                NSMutableDictionary *conditions = [NSMutableDictionary dictionary];
                if (is_income == false) {
                    [conditions setObject:@(0) forKey:@"type ="];
                    arrm = [CategoryModel getAllCategories:conditions];
                } else {
                    [conditions setObject:@(1) forKey:@"type ="];
                    arrm = [CategoryModel getAllCategories:conditions];
                }
                NSInteger targetIndex = -1;
                for(NSUInteger i = 0; i < arrm.count; i++){
                    if(arrm[i].Id == self.model.category.Id){
                        targetIndex = (NSInteger)i;
                        break;
                    }
                }
                [collection setSelectIndex:[NSIndexPath indexPathForRow:targetIndex inSection:0]];
                [collection setSelectedModelId:self.model.category.Id];
                [collection reloadData];
                [self bookClickItem:collection];
                [self.keyboard setModel:self.model];
            });
        });
    }

}

- (void)bendiData {
    BKCIncomeModel *model1 = [[BKCIncomeModel alloc] init];
    model1.is_income = false;
    NSMutableDictionary *conditions = [NSMutableDictionary dictionary];
    [conditions setObject:@(0) forKey:@"type ="];
    model1.list = [NSMutableArray arrayWithArray:[CategoryModel getAllCategories:conditions]];

    BKCIncomeModel *model2 = [[BKCIncomeModel alloc] init];
    model2.is_income = true;
    conditions = [NSMutableDictionary dictionary];
    [conditions setObject:@(1) forKey:@"type ="];
    model2.list = [NSMutableArray arrayWithArray:[CategoryModel getAllCategories:conditions]];
    [self setModels:@[model1, model2]];
}


#pragma mark - 请求

// 记账
- (void)createBookRequest:(NSString *)price mark:(NSString *)mark date:(NSDate *)date {
    NSInteger index = self.scroll.contentOffset.x / SCREEN_WIDTH;
    BKCCollection *collection = self.collections[index];
    CategoryModel *category = [CategoryModel getCategoryById:collection.selectedModelId];
    if(category == nil){
        NSLog(@"分类不存在，%ld",collection.selectedModelId);
        return;
    }
    NSInteger intPrice = labs([MoneyConverter toIntMoney:price]);
    if(intPrice == 0 && [mark  isEqual: @""]){
        [self showTextHUD:@"金额与备注至少输入一个" delay:1.f];
        return;
    }
    if(intPrice > 99999999){
        [self showTextHUD:@"最大金额999,999.99" delay:1.f];
        return;
    }
    BKModel *model = [[BKModel alloc] init];
    if (!_model) {
        // 新增
        model.price = intPrice;
        model.year = date.year;
        model.month = date.month;
        model.day = date.day;
        model.mark = mark;
        model.category_id = category.Id;
        model.type = category.type;
        [BKModel saveAccount:model];
    } else {
        // 修改
        _model.price = intPrice;
        _model.year = date.year;
        _model.month = date.month;
        _model.day = date.day;
        _model.mark = mark;
        _model.category_id = category.Id;
        _model.type = category.type;
        // 更新数据库中的数据
        [BKModel updateAccount:_model];
        model = _model;
    }

    if (self.navigationController.viewControllers.count != 1) {
        [self.navigationController popViewControllerAnimated:true];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOT_BOOK_COMPLETE object:model];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NOT_BOOK_COMPLETE object:model];
        }];
    }
}


#pragma mark - set
- (void)setModels:(NSArray<BKCIncomeModel *> *)models {
    _models = models;
    for (int i=0; i<models.count; i++) {
        self.collections[i].model = models[i];
    }
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
// 点击导航栏
- (void)bookClickNavigation:(NSNumber *)index {
    [self.scroll setContentOffset:CGPointMake(SCREEN_WIDTH * [index integerValue], 0) animated:YES];
}
// 点击item
- (void)bookClickItem:(BKCCollection *)collection {
    NSIndexPath *indexPath = collection.selectIndex;
    // 选择类别
    if (collection.selectedModelId != -1) {
        // 显示键盘
        [self.keyboard show];
        // 刷新
        NSInteger page = _scroll.contentOffset.x / SCREEN_WIDTH;
        BKCCollection *collection = self.collections[page];
        [collection setHeight:SCREEN_HEIGHT - NavigationBarHeight - self.keyboard.height];
        [collection scrollToIndex:indexPath];
    }
    // 设置
    else {
        // 隐藏键盘
        for (BKCCollection *collection in self.collections) {
            [collection reloadSelectIndex];
            [collection setHeight:SCREEN_HEIGHT - NavigationBarHeight];
        }
        [self.keyboard hide];
        // 刷新
        CAController *vc = [[CAController alloc] init];
        [vc setIs_income:collection.tag];
        [vc setComplete:^{
            [self bendiData];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (BKCCollection *collection in self.collections) {
        [collection reloadSelectIndex];
        [collection setHeight:SCREEN_HEIGHT - NavigationBarHeight];
    }
    [self.keyboard hide];
    [self.navigation setOffsetX:scrollView.contentOffset.x];
}


#pragma mark - get
- (UIScrollView *)scroll {
    if (!_scroll) {
        _scroll = [[UIScrollView alloc] initWithFrame:({
            CGFloat left = 0;
            CGFloat top = NavigationBarHeight;
            CGFloat width = SCREEN_WIDTH;
            CGFloat height = SCREEN_HEIGHT - NavigationBarHeight;
            CGRectMake(left, top, width, height);
        })];
        [_scroll setDelegate:self];
        [_scroll setShowsHorizontalScrollIndicator:NO];
        [_scroll setPagingEnabled:YES];
        [self.view addSubview:_scroll];
    }
    return _scroll;
}

- (BKCNavigation *)navigation {
    if (!_navigation) {
        _navigation = [BKCNavigation loadFirstNib:CGRectMake(0, 0, SCREEN_WIDTH, NavigationBarHeight)];
        [self.view addSubview:_navigation];
    }
    return _navigation;
}
- (NSMutableArray<BKCCollection *> *)collections {
    if (!_collections) {
        _collections = [NSMutableArray array];
        for (int i=0; i<2; i++) {
            BKCCollection *collection = [BKCCollection initWithFrame:({
                CGFloat width = SCREEN_WIDTH;
                CGFloat left = i * width;
                CGFloat height = SCREEN_HEIGHT - NavigationBarHeight;
                CGRectMake(left, 0, width, height);
            })];
            [collection setTag:i];
            [_scroll setContentSize:CGSizeMake(SCREEN_WIDTH * 2, 0)];
            [_scroll addSubview:collection];
            [_collections addObject:collection];
        }
    }
    return _collections;
}
- (BKCKeyboard *)keyboard {
    if (!_keyboard) {
        @weakify(self)
        _keyboard = [BKCKeyboard init];
        [_keyboard setComplete:^(NSString *price, NSString *mark, NSDate *date) {
            @strongify(self)
            [self createBookRequest:price mark:mark date:date];
        }];
        [self.view addSubview:_keyboard];
    }
    return _keyboard;
}
- (NSDictionary<NSString *, NSInvocation *> *)eventStrategy {
    if (!_eventStrategy) {
        _eventStrategy = @{
                           BOOK_CLICK_ITEM: [self createInvocationWithSelector:@selector(bookClickItem:)],
                           BOOK_CLICK_NAVIGATION: [self createInvocationWithSelector:@selector(bookClickNavigation:)],
                           };
    }
    return _eventStrategy;
}



@end
