/**
 * 添加分类
 * @author Hum 2025-02-20 适配刘海屏
 */

#import "ACAController.h"
#import "ACATextField.h"
#import "ACACollection.h"
#import "ACAListModel.h"
#import "BKCIncomeModel.h"
#import "CategoryModel.h"
#import "ACA_EVENT_MANAGER.h"


#pragma mark - 声明
@interface ACAController()

@property (nonatomic, strong) ACATextField *textField;
@property (nonatomic, strong) ACACollection *collection;
@property (nonatomic, strong) ACAModel *selectModel;
@property (nonatomic, strong) NSArray<ACAListModel *> *models;
@property (nonatomic, strong) NSDictionary<NSString *, NSInvocation *> *eventStrategy;

@end


#pragma mark - 实现
@implementation ACAController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:_is_income == true ? @"添加收入类别" : @"添加支出类别"];
    [self setJz_navigationBarHidden:NO];
    [self setJz_navigationBarTintColor:kColor_Main_Color];
    [self.rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [self.rightButton setTitle:@"完成" forState:UIControlStateHighlighted];
    [self.rightButton setHidden:NO];
    [self textField];
    [self collection];

    NSMutableArray<ACAListModel *> *arrm = [NSUserDefaults objectForKey:PIN_ACA_CATE];
    [self setModels:arrm];
    
}

- (void)rightButtonClick {
    if ([_textField.textField.text length] == 0) {
        [self showTextHUD:@"类别名称不能为空" delay:1.f];
        return;
    }
    
    // 创建 CategoryModel 对象
    CategoryModel *category = [[CategoryModel alloc] init];
    category.name = _textField.textField.text;
    category.icon = _selectModel.icon_n;
    category.type = _is_income ? 1 : 0;
    
    [self showTextHUD:@"添加中..." delay:1.f];
    [CategoryModel addCategory:category];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideHUD];
        if ([self complete]) {
            self.complete(category);
        }
        [self.navigationController popViewControllerAnimated:true];
    });
    
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
// 点击item
- (void)itemClick:(ACAModel *)model {
    _selectModel = model;
    [self.textField setModel:model];
}

#pragma mark - set
- (void)setModels:(NSArray<ACAListModel *> *)models {
    _models = models;
    _collection.models = models;
}


#pragma mark - get
- (ACATextField *)textField {
    if (!_textField) {
        _textField = [ACATextField loadFirstNib:CGRectMake(0, NavigationBarHeight, SCREEN_WIDTH, countcoordinatesX(60))];
        [self.view addSubview:_textField];
    }
    return _textField;
}
- (ACACollection *)collection {
    if (!_collection) {
        _collection = [ACACollection initWithFrame:CGRectMake(0, _textField.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - _textField.bottom)];
        [self.view addSubview:_collection];
    }
    return _collection;
}
- (NSDictionary<NSString *, NSInvocation *> *)eventStrategy {
    if (!_eventStrategy) {
        _eventStrategy = @{
                           ACA_CLICK_ITEM: [self createInvocationWithSelector:@selector(itemClick:)],
                           
                           };
    }
    return _eventStrategy;
}


@end
