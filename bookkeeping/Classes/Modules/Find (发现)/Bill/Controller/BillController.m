/**
 * 账单
 * @author Hum  2025-02-28
 */

#import "BillController.h"
#import "BillTable.h"
#import "AccountBook.h"
#import "MoneyConverter.h"

#pragma mark - 声明
@interface BillController()

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) BillTable *table;

@end


#pragma mark - 实现
@implementation BillController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"账单"];
    [self setDate:[NSDate date]];
    [self.rightButton setHidden:false];
    [self.rightButton setFrame:CGRectMake(0, 0, 70, 44)];
    [self.rightButton addSubview:({
        UIImageView *image = [[UIImageView alloc] init];
        image.frame = CGRectMake(self.rightButton.width - 15, 0, 15, self.rightButton.height);
        image.image = [UIImage imageNamed:@"time_down"];
        image.contentMode = UIViewContentModeScaleAspectFit;
        image;
    })];
    [self.rightButton addSubview:({
        UILabel *lab = nil;
        if(@available(iOS 11.0, *)){
            lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 65.54, 44)];
        }else{
            lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 55, 44)];
        }
        lab.text = @"2019年";
        lab.font = [UIFont systemFontOfSize:AdjustFont(14)];
        lab.textColor = kColor_Text_Black;
        lab.textAlignment = NSTextAlignmentRight;
        lab.tag = 10;
        lab;
    })];
    [self table];
    dispatch_async(dispatch_get_main_queue(), ^{
       [self changeVlaue:[@(self.date.year) stringValue]];
    });
}


- (void)rightButtonClick {
    @weakify(self)
    NSDate *date = [NSDate date];
    NSDate *min = [NSDate br_setYear:2010 month:1 day:1];
    NSDate *max = [NSDate br_setYear:date.year month:date.month day:31];
    [BRDatePickerView showDatePickerWithTitle:@"选择日期" dateType:BRDatePickerModeY defaultSelValue:[@(self.date.year) description] minDate:min maxDate:max isAutoSelect:false themeColor:nil resultBlock:^(NSString *selectYear) {
        @strongify(self)
        [self changeVlaue:selectYear];
    }];
}


- (void)changeVlaue:(NSString *)selectYear {
    
    [self setDate:[NSDate dateWithYMD:[NSString stringWithFormat:@"%@-01-01", selectYear]]];
    [(UILabel *)[self.rightButton viewWithTag:10] setText:[NSString stringWithFormat:@"%ld年", self.date.year]];
    // 过滤
    NSMutableDictionary *incomeConditions = [NSMutableDictionary dictionary];
    [incomeConditions setObject:selectYear forKey:@"year ="];
    [incomeConditions setObject:@(1) forKey:@"type ="];
    NSInteger incomeAmount = [AccountBook sumPriceWithConditions:incomeConditions];
    
    NSMutableDictionary *payConditions = [NSMutableDictionary dictionary];
    [payConditions setObject:selectYear forKey:@"year ="];
    [payConditions setObject:@(0) forKey:@"type ="];
    
    NSInteger payAmount = [AccountBook sumPriceWithConditions:payConditions];
    
    [self.table setIncome:incomeAmount];
    [self.table setPay:payAmount];
    
    NSMutableArray *arrm = [NSMutableArray array];
    for (NSInteger i=1; i<=12; i++) {
        NSMutableDictionary *monthIncomeConditions = [NSMutableDictionary dictionary];
        [monthIncomeConditions setObject:selectYear forKey:@"year ="];
        [monthIncomeConditions setObject:@(i) forKey:@"month ="];
        [monthIncomeConditions setObject:@(1) forKey:@"type ="];
        NSInteger income = [AccountBook sumPriceWithConditions:monthIncomeConditions];
        
        NSMutableDictionary *monthPayConditions = [NSMutableDictionary dictionary];
        [monthPayConditions setObject:selectYear forKey:@"year ="];
        [monthPayConditions setObject:@(i) forKey:@"month ="];
        [monthPayConditions setObject:@(0) forKey:@"type ="];
        NSInteger pay = [AccountBook sumPriceWithConditions:monthPayConditions];
        
        NSDictionary *param = @{@"month": [NSString stringWithFormat:@"%ld月", i],
                                @"income":[MoneyConverter toRealMoney:income],
                                @"pay": [MoneyConverter toRealMoney:pay],
                                @"sum": [MoneyConverter toRealMoney:(income-pay)]
                                };
        [arrm addObject:param];
    }

    BOOL maxMonth = false;
    NSMutableArray *newArrm = [NSMutableArray array];
    for (NSInteger i=12; i>=1; i--) {
        NSDictionary *param = arrm[i-1];
        if (![param[@"income"] isEqualToString:@"0.00"] || ![param[@"pay"] isEqualToString:@"0.00"]) {
            maxMonth = true;
        }
        if (maxMonth == true) {
            [newArrm addObject:param];
        }
    }
    [self.table setModels:newArrm];
}


#pragma mark - get
- (BillTable *)table {
    if (!_table) {
        _table = [[BillTable alloc] initWithFrame:CGRectMake(0, NavigationBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - NavigationBarHeight) style:UITableViewStyleGrouped];
        [_table setBackgroundView:({
            UIView *back = [[UIView alloc] initWithFrame:self.table.bounds];
            [back setBackgroundColor:kColor_BG];
            [back addSubview:({
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
                view.backgroundColor = kColor_Main_Color;
                view;
            })];
            back;
        })];
        [self.view addSubview:_table];
    }
    return _table;
}


@end
