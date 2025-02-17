/**
 * 记账model
 * @author 郑业强 2018-12-31 创建文件
 */

#import "BKModel.h"
#import "DatabaseManager.h"
#import "MoneyConverter.h"

#define BKModelId @"BKModelId"

@implementation BKModel

+ (void)load {
    [BKModel mj_setupIgnoredPropertyNames:^NSArray *{
        return @[@"date"];
    }];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self = [NSObject decodeClass:self decoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [NSObject encodeClass:self encoder:aCoder];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    BKModel *model = [[[self class] allocWithZone:zone] init];
    model.Id = self.Id;
    model.category_id = self.category_id;
    model.price = self.price;
    model.year = self.year;
    model.month = self.month;
    model.day = self.day;
    model.week = self.week;
    model.mark = self.mark;
    model.dateStr = self.dateStr;
    model.date = self.date;
    model.dateNumber = self.dateNumber;
    model.cmodel = [self.cmodel copy];
    return model;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[BKModel class]]) {
        return false;
    }
    BKModel *model = object;
    if ([self Id] == [model Id]) {
        return true;
    }
    return false;
}

- (NSString *)dateStr {
    NSString *str = [NSString stringWithFormat:@"%ld-%02ld-%02ld", _year, _month, _day];
    NSDate *date = [NSDate dateWithYMD:str];
    return [NSString stringWithFormat:@"%ld年%02ld月%02ld日   %@", _year, _month, _day, [date dayFromWeekday]];
}

- (NSDate *)date {
    return [NSDate dateWithYMD:[NSString stringWithFormat:@"%ld-%02ld-%02ld", _year, _month, _day]];
}

- (NSInteger)dateNumber {
    return [[NSString stringWithFormat:@"%ld%02ld%02ld", _year, _month, _day] integerValue];
}

- (NSInteger)week {
    return [self.date weekOfYear];
}

// 获取Id
+ (NSNumber *)getId {
    NSNumber *Id = [NSUserDefaults objectForKey:BKModelId];
    if (!Id) {
        Id = @(0);
    }
    Id = @([Id integerValue] + 1);
    [NSUserDefaults setObject:Id forKey:BKModelId];
    return Id;
}


@end



@implementation BKMonthModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self = [NSObject decodeClass:self decoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [NSObject encodeClass:self encoder:aCoder];
}

- (NSString *)dateStr {
    return [NSString stringWithFormat:@"%02ld月%02ld日   %@", [_date month], [_date day], [_date dayFromWeekday]];
}

- (NSString *)moneyStr {
    NSMutableString *strm = [NSMutableString string];
    if (_income != 0) {
        [strm appendFormat:@"收入: %@", [@(_income) description]];
    }
    if (_income != 0 && _pay != 0) {
        [strm appendString:@"    "];
    }
    if (_pay != 0) {
        [strm appendFormat:@"支出: %@", [@(_pay) description]];
    }
    return strm;
}

+ (NSMutableArray<BKMonthModel *> *)statisticalMonthWithYear:(NSInteger)year month:(NSInteger)month {
    // 根据时间过滤
    NSMutableArray<BKModel *> *bookArr = [NSUserDefaults objectForKey:PIN_BOOK];
    NSString *preStr = [NSString stringWithFormat:@"year == %ld AND month == %ld", year, month];
//    NSPredicate *pre = [NSPredicate predicateWithFormat:preStr];
//    NSMutableArray<BKModel *> *models = [NSMutableArray arrayWithArray:[bookArr filteredArrayUsingPredicate:pre]];
    NSMutableArray<BKModel *> *models = [NSMutableArray kk_filteredArrayUsingPredicate:preStr array:bookArr];
    
    // 统计数据
    NSMutableDictionary *dictm = [NSMutableDictionary dictionary];
    for (BKModel *model in models) {
        NSString *key = [NSString stringWithFormat:@"%ld-%02ld-%02ld", model.year, model.month, model.day];
        // 初始化
        if (![[dictm allKeys] containsObject:key]) {
            BKMonthModel *submodel = [[BKMonthModel alloc] init];
            submodel.list = [NSMutableArray array];
            submodel.income = 0;
            submodel.pay = 0;
            submodel.date = [NSDate dateWithYMD:key];
            [dictm setObject:submodel forKey:key];
        }
        // 添加数据
        BKMonthModel *submodel = dictm[key];
        [submodel.list addObject:model];
        // 收入
        if (model.cmodel.is_income == true) {
            [submodel setIncome:submodel.income + model.price];
        }
        // 支出
        else {
            [submodel setPay:submodel.pay + model.price];
        }
        [dictm setObject:submodel forKey:key];
    }
    
    // 排序
    NSMutableArray<BKMonthModel *> *arrm = [NSMutableArray arrayWithArray:[dictm allValues]];
    arrm = [NSMutableArray arrayWithArray:[arrm sortedArrayUsingComparator:^NSComparisonResult(BKMonthModel *obj1, BKMonthModel *obj2) {
        return [obj1.dateStr compare:obj2.dateStr];
    }]];
    return arrm;
}

@end




@implementation BKChartModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self = [NSObject decodeClass:self decoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [NSObject encodeClass:self encoder:aCoder];
}

// 统计数据(图表首页)
+ (BKChartModel *)statisticalChart:(NSInteger)status isIncome:(BOOL)isIncome cmodel:(BKModel *)cmodel date:(NSDate *)date {
    NSLog(@"进入统计sql： statisticalChart");

    // 初始化
    BKChartModel *model = [[BKChartModel alloc] init];
    model.is_income = isIncome;

    // 构建谓词
    NSMutableArray *predicates = [NSMutableArray array];
    [predicates addObject:[NSPredicate predicateWithFormat:@"cmodel.is_income == %d", isIncome]];
    if (cmodel) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"cmodel.Id == %ld", cmodel.cmodel.Id]];
    }

    if (status == 0) { // 周
        NSDate *start = [date offsetDays:-[date weekday] + 1];
        NSDate *end = [date offsetDays:7 - [date weekday]];
        [predicates addObject:[NSPredicate predicateWithBlock:^BOOL(BKModel *evaluatedObject, NSDictionary<NSString *, id> * _Nullable bindings) {
            return [evaluatedObject.date compare:start] != NSOrderedAscending && [evaluatedObject.date compare:end] != NSOrderedDescending;
        }]];
    } else if (status == 1) { // 月
        [predicates addObject:[NSPredicate predicateWithFormat:@"year == %ld AND month == %ld", date.year, date.month]];
    } else if (status == 2) { // 年
        [predicates addObject:[NSPredicate predicateWithFormat:@"year == %ld", date.year]];
    }

    // 图表数据
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    NSMutableArray<BKModel *> *filteredModels = [[[DatabaseManager sharedManager] getAllModelsWithPredicate:finalPredicate] mutableCopy];
    NSLog(@"查询结果");
    NSLog(@"%@",filteredModels);
    // 在这里声明并初始化 chartArr 和 chartHudArr
    NSMutableArray<BKModel *> *chartArr = [NSMutableArray array];
    NSMutableArray<NSMutableArray<BKModel *> *> *chartHudArr = [NSMutableArray array];

    if (status == 0) { // 周
        NSDate *first = [date offsetDays:-[date weekday] + 1];
        for (int i = 0; i < 7; i++) {
            NSDate *currentDate = [first offsetDays:i];
            BKModel *model = [[BKModel alloc] init];
            model.year = currentDate.year;
            model.month = currentDate.month;
            model.day = currentDate.day;
            model.price = 0;
            [chartArr addObject:model];
            [chartHudArr addObject:[NSMutableArray array]];
        }

        // 计算每周的总和
        for (BKModel *model in filteredModels) {
            NSInteger index = [model.date weekday] - 1; // 周日索引是 0，周一是 1，...
            chartArr[index].price += model.price;
            [chartHudArr[index] addObject:model];
        }
    } else if (status == 1) { // 月
        NSInteger daysInMonth = [date daysInMonth];
        for (int i = 1; i <= daysInMonth; i++) {
            BKModel *model = [[BKModel alloc] init];
            model.year = date.year;
            model.month = date.month;
            model.day = i;
            model.price = 0;
            [chartArr addObject:model];
            [chartHudArr addObject:[NSMutableArray array]];
        }

        for (BKModel *model in filteredModels) {
            chartArr[model.day - 1].price += model.price;
            [chartHudArr[model.day - 1] addObject:model];
        }
    } else if (status == 2) { // 年
        for (int i = 1; i <= 12; i++) {
            BKModel *model = [[BKModel alloc] init];
            model.year = date.year;
            model.month = i;
            model.day = 1;
            model.price = 0;
            [chartArr addObject:model];
            [chartHudArr addObject:[NSMutableArray array]];
        }

        for (BKModel *model in filteredModels) {
            chartArr[model.month - 1].price += model.price;
            [chartHudArr[model.month - 1] addObject:model];
        }
    }
    
    NSLog(@"pring chartArr chartHudArr");
    NSLog(@"%@", chartArr);
    NSLog(@"%@", chartHudArr);
    // 排序
    [chartHudArr enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj sortUsingComparator:^NSComparisonResult(BKModel *obj1, BKModel *obj2) {
            return obj1.price < obj2.price;
        }];
    }];

    NSMutableArray<BKModel *> *groupArr = [NSMutableArray array];
    if (!cmodel) {
        for (BKModel *model in filteredModels) {
            NSInteger index = [groupArr indexOfObjectPassingTest:^BOOL(BKModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return obj.category_id == model.category_id;
            }];
            if (index == NSNotFound) {
                BKModel *submodel = [model copy];
                [groupArr addObject:submodel];
            } else {
                groupArr[index].price += model.price;
            }
        }
    } else {
        [filteredModels enumerateObjectsUsingBlock:^(BKModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BKModel *submodel = [obj copy];
            [groupArr addObject:submodel];
        }];
    }

    [groupArr sortUsingComparator:^NSComparisonResult(BKModel *obj1, BKModel *obj2) {
        return obj1.price < obj2.price;
    }];

    NSInteger sum = 0;
    for (BKModel *model in chartArr) {
        sum += model.price;
    }

    model.groupArr = groupArr;
    model.chartArr = chartArr;
    model.chartHudArr = chartHudArr;
    model.sum = [MoneyConverter toRealMoney:sum]; // 转换为实际金额
    model.max = [[chartArr valueForKeyPath:@"@max.price.floatValue"] stringValue];
    model.avg = [MoneyConverter toRealMoney:[[NSString stringWithFormat:@"%.2lu", sum / chartArr.count] intValue]];

    return model;
}


@end

