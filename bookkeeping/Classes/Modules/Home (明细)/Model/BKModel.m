/**
 * 记账model
 * @author Hum 2025-02-18 创建文件
 */

#import "BKModel.h"
#import "CategoryModel.h"
#import "DatabaseManager.h"
#import "MoneyConverter.h"

#define BKModelId @"BKModelId"

@implementation BKModel

+ (void)load {
    [BKModel mj_setupIgnoredPropertyNames:^NSArray *{
        return @[@"date"];
    }];
}

- (CategoryModel *)categoryModel {
    return [CategoryModel getCategoryById:self.category_id];
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
    return [self Id] == [model Id];
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
    __block NSInteger lastId = 0;
    NSString *query = @"SELECT MAX(id) FROM AccountBook";
    FMResultSet *result = [[DatabaseManager sharedManager].db executeQuery:query];
    if ([result next]) {
        lastId = [result intForColumnIndex:0];
    }
    [result close];
    return @(lastId + 1);
}

+ (NSArray<BKModel *> *)getAllModels {
    return [self getAllModelsWithConditions:nil];
}

+ (NSArray<BKModel *> *)getAllModelsWithConditions:(NSDictionary<NSString *,id> *)conditions {
    NSMutableArray *models = [NSMutableArray array];
    
    // 构建 SQL 查询语句
    NSMutableString *selectQuery = [NSMutableString stringWithString:@"SELECT * FROM AccountBook"];
    NSMutableArray *arguments = [NSMutableArray array];
    
    if (conditions.count > 0) {
        [selectQuery appendString:@" WHERE "];
        __block int i = 0;
        [conditions enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (i > 0) {
                [selectQuery appendString:@" AND "];
            }
            [selectQuery appendFormat:@"%@ ?", key];
            [arguments addObject:obj];
            i++;
        }];
    }

    // 执行查询
    FMResultSet *results = [[DatabaseManager sharedManager].db executeQuery:selectQuery withArgumentsInArray:arguments];
    while ([results next]) {
        BKModel *model = [[BKModel alloc] init];
        model.Id = [results intForColumn:@"id"];
        model.price = [results intForColumn:@"price"];
        model.year = [results intForColumn:@"year"];
        model.month = [results intForColumn:@"month"];
        model.day = [results intForColumn:@"day"];
        model.mark = [results stringForColumn:@"mark"];
        model.category_id = [results intForColumn:@"category_id"];
        model.type = [results intForColumn:@"type"];
        model.category = [CategoryModel getCategoryById:model.category_id]; // 关联查询Category
        [models addObject:model];
    }
    [results close];
    
    return models;
}

+ (void)saveAccount:(BKModel *)model {
    NSString *insertQuery = @"INSERT INTO AccountBook (price, year, month, day, mark, category_id, type) VALUES (?, ?, ?, ?, ?, ?, ?)";
    [[DatabaseManager sharedManager].db executeUpdate:insertQuery, @(model.price), @(model.year), @(model.month), @(model.day), model.mark, @(model.category_id), @(model.type)];
}

+ (void)updateAccount:(BKModel *)model {
    NSString *updateQuery = @"UPDATE AccountBook SET price = ?, year = ?, month = ?, day = ?, mark = ?, category_id = ?, type = ?, updated_at = DATETIME('now', 'localtime') WHERE id = ?";
    [[DatabaseManager sharedManager].db executeUpdate:updateQuery, @(model.price), @(model.year), @(model.month), @(model.day), model.mark, @(model.category_id), @(model.type), @(model.Id)];
}

+ (BKModel *)getAccountById:(NSInteger)modelId{
    NSString *selectQuery = @"SELECT * FROM AccountBook WHERE Id = ?";
    FMResultSet *results = [[DatabaseManager sharedManager].db executeQuery:selectQuery, @(modelId)];

    if ([results next]) {
        BKModel *model = [[BKModel alloc] init];
        model.Id = [results intForColumn:@"id"];
        model.price = [results doubleForColumn:@"price"];
        model.year = [results intForColumn:@"year"];
        model.month = [results intForColumn:@"month"];
        model.day = [results intForColumn:@"day"];
        model.mark = [results stringForColumn:@"mark"];
        model.category_id = [results intForColumn:@"category_id"];
        model.type = [results intForColumn:@"type"];
        model.category = [CategoryModel getCategoryById:model.category_id]; // 关联查询Category
        return model;
    }
    return nil;
}

+ (void)deleteAccountById:(NSInteger)Id {
    NSString *deleteQuery = @"DELETE FROM AccountBook WHERE id = ?";
    [[DatabaseManager sharedManager].db executeUpdate:deleteQuery, @(Id)];
    NSLog(@"Success to delete BKModel");
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
        [strm appendFormat:@"收入: %@", [MoneyConverter toRealMoney:_income]];
    }
    if (_income != 0 && _pay != 0) {
        [strm appendString:@"    "];
    }
    if (_pay != 0) {
        [strm appendFormat:@"支出: %@", [MoneyConverter toRealMoney:_pay]];
    }
    return strm;
}

+ (NSMutableArray<BKMonthModel *> *)statisticalMonthWithYear:(NSInteger)year month:(NSInteger)month {
    // 获取数据库中的数据
    NSMutableDictionary *conditions = [NSMutableDictionary dictionary];
    [conditions setObject:@(year) forKey:@"year ="];
    [conditions setObject:@(month) forKey:@"month ="];
    NSMutableArray<BKModel *> *models = [[BKModel getAllModelsWithConditions:conditions] mutableCopy];
    
    // 统计数据
    NSMutableDictionary *dictm = [NSMutableDictionary dictionary];
    
    for (BKModel *model in models) {
        NSString *key = [NSString stringWithFormat:@"%ld-%02ld-%02ld", model.year, model.month, model.day];
        
        // 初始化字典中的值
        if (![dictm objectForKey:key]) {
            BKMonthModel *submodel = [[BKMonthModel alloc] init];
            submodel.list = [NSMutableArray array];
            submodel.income = 0;
            submodel.pay = 0;
            submodel.date = [NSDate dateWithYMD:key];
            [dictm setObject:submodel forKey:key];
        }
        
        // 更新数据
        BKMonthModel *submodel = dictm[key];
        [submodel.list addObject:model];
        
        // 收入或支出
        if (model.type == 0) {
            submodel.pay += model.price;
        } else {
            submodel.income += model.price;
        }
    }
    
    // 将字典中的所有值转换为数组，并按照日期进行排序
    NSMutableArray<BKMonthModel *> *arrm = [NSMutableArray arrayWithArray:[dictm allValues]];
    [arrm sortUsingComparator:^NSComparisonResult(BKMonthModel *obj1, BKMonthModel *obj2) {
        return [obj1.dateStr compare:obj2.dateStr];
    }];
    
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

    BKChartModel *model = [[BKChartModel alloc] init];
    
    
    NSMutableDictionary *conditions = [NSMutableDictionary dictionary];
    [conditions setObject:isIncome ? @(1) : @(0) forKey:@"type = "];
    
    if (status == 0) { // 周
        NSDate *start = [date offsetDays:-[date weekday] + 1];
        NSDate *end = [date offsetDays:7 - [date weekday]];
        [conditions setObject:@(start.year) forKey:@"year >= "];
        [conditions setObject:@(start.month) forKey:@"month >= "];
        [conditions setObject:@(start.day) forKey:@"day >= "];
        [conditions setObject:@(end.year) forKey:@"year <= "];
        [conditions setObject:@(end.month) forKey:@"month <= "];
        [conditions setObject:@(end.day) forKey:@"day <= "];
    } else if (status == 1) { // 月
        [conditions setObject:@(date.year) forKey:@"year ="];
        [conditions setObject:@(date.month) forKey:@"month ="];
    } else if (status == 2) { // 年
        [conditions setObject:@(date.year) forKey:@"year ="];
    }
    
    NSMutableArray<BKModel *> *filteredModels = [[BKModel getAllModelsWithConditions:conditions] mutableCopy];
    
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

        for (BKModel *model in filteredModels) {
            NSInteger index = [model.date weekday] - 1;
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

    [chartHudArr enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj sortUsingComparator:^NSComparisonResult(BKModel *obj1, BKModel *obj2) {
            return obj1.price < obj2.price;
        }];
    }];
    
    NSMutableArray<BKModel *> *groupArr = [NSMutableArray array];
    for (BKModel *model in filteredModels) {
        NSInteger index = [groupArr indexOfObjectPassingTest:^BOOL(BKModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return obj.category_id == model.category_id;
        }];
        if (index == NSNotFound) {
            BKModel *submodel = [model copy];
            submodel.category = model.category;
            [groupArr addObject:submodel];
        } else {
            groupArr[index].price += model.price;
        }
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
    model.is_income = isIncome;
    model.sum = [MoneyConverter toRealMoney:sum];
    model.max = [[chartArr valueForKeyPath:@"@max.price.floatValue"] stringValue];
    model.avg = [MoneyConverter toRealMoney:[[NSString stringWithFormat:@"%.2lu", sum / chartArr.count] intValue]];

    return model;
}


@end
