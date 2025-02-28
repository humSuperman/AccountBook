/**
 * 分类model
 * @author Hum 2025-02-18 创建文件
 */

#import "CategoryModel.h"
#import "DatabaseManager.h"

@implementation CategoryModel

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [NSObject encodeClass:self encoder:coder];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self = [NSObject decodeClass:self decoder:coder];
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    CategoryModel *model = [[[self class] allocWithZone:zone] init];
    model.Id = self.Id;
    model.name = self.name;
    model.type = self.type;
    model.icon = self.icon;
    model.status = self.status;
    model.createdAt = self.createdAt;
    model.updatedAt = self.updatedAt;
    return model;
}

+ (CategoryModel *)createSetModel{
    CategoryModel *set = [[CategoryModel alloc] init];
    set.Id = -1;
    set.name = @"设置";
    set.icon = @"cc_home_tools.png";
    return set;
}

- (NSString *)getIconForSuffix:(NSString *)suffix {
    return [self.icon stringByAppendingString:suffix];
}

// 添加分类
+ (void)addCategory:(CategoryModel *)model  {
    NSString *insertSQL = @"INSERT INTO Category (name, type, icon) VALUES (?, ?, ?);";
    
    [[DatabaseManager sharedManager].db executeUpdate:insertSQL, model.name, @(model.type), model.icon];
}

// 修改分类
+ (void)updateCategory:(CategoryModel *)model {
    NSString *updateSQL = @"UPDATE Category SET name = ?, type = ?, icon = ?, status = ? WHERE id = ?;";
    
    [[DatabaseManager sharedManager].db executeUpdate:updateSQL,model.name,@(model.type),model.icon,@(model.status),@(model.Id)];
}

// 修改分类排序
+ (void)updateCategorySort:(NSInteger)oldSort newSort:(NSInteger)newSort {
    if (oldSort == newSort) {
        return;
    }
    NSArray<CategoryModel *> *list = [self getAllCategories:nil];
    if (list.count == 0) {
        NSLog(@"分类列表为空，无法更新排序");
        return;
    }
    if (oldSort < 0 || oldSort >= list.count || newSort < 0 || newSort >= list.count) {
        NSLog(@"oldSort 或 newSort 超出范围");
        return;
    }
    CategoryModel *model = list[oldSort];
    NSMutableArray<CategoryModel *> *mutableList = [list mutableCopy];
    NSLog(@"移动的分类：%@",model.name);
    [[DatabaseManager sharedManager].db beginTransaction];
    @try {
        [mutableList removeObjectAtIndex:oldSort];
        [mutableList insertObject:model atIndex:newSort];
        NSString *sortSQL = @"UPDATE Category SET sort = ? WHERE id = ?;";
        for (NSInteger i = 0; i < mutableList.count; i++) {
            CategoryModel *category = mutableList[i];
            if(category.sort == i){
                continue;
            }
            [[DatabaseManager sharedManager].db executeUpdate:sortSQL, @(i), @(category.Id)];
        }
        [[DatabaseManager sharedManager].db commit];
        NSLog(@"排序更新成功！");
    }
    @catch (NSException *exception) {
        // 如果发生异常，回滚事务
        [[DatabaseManager sharedManager].db rollback];
        NSLog(@"发生错误，回滚事务：%@", exception.reason);
    }
}

// 获取所有分类
+ (NSArray<CategoryModel *> *)getAllCategories:(NSDictionary<NSString *,id> *)conditions {
    NSMutableString *selectQuery = [NSMutableString stringWithString:@"SELECT * FROM Category WHERE status = 0"];
    NSMutableArray *arguments = [NSMutableArray array];
    if (conditions.count > 0) {
        __block int i = 0;
        [conditions enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [selectQuery appendFormat:@" AND %@ ?", key];
            [arguments addObject:obj];
            i++;
        }];
    }
    
    [selectQuery appendString:@" ORDER BY sort asc"];
    // 获取查询结果
    FMResultSet *results = [[DatabaseManager sharedManager].db executeQuery:selectQuery withArgumentsInArray:arguments];
    NSMutableArray *categories = [NSMutableArray array];
    while ([results next]) {
        CategoryModel *category = [[CategoryModel alloc] init];
        category.Id = [results intForColumn:@"id"];
        category.name = [results stringForColumn:@"name"];
        category.type = [results intForColumn:@"type"];
        category.icon = [results stringForColumn:@"icon"];
        category.status = [results intForColumn:@"status"];
        category.createdAt = results[@"created_at"];
        category.updatedAt = results[@"updated_at"];
        [categories addObject:category];
    }
    [results close];
    return categories;
}


// 获取分类
+ (CategoryModel *)getCategoryById :(NSInteger)Id {
    NSString *selectSQL = @"SELECT * FROM Category where id = ?";
    
    // 获取查询结果
    FMResultSet *results = [[DatabaseManager sharedManager].db executeQuery:selectSQL, @(Id)];
    
    if ([results next]) {
        CategoryModel *model = [[CategoryModel alloc] init];
        model.Id = [results intForColumn:@"id"];
        model.name = [results stringForColumn:@"name"];
        model.type = [results intForColumn:@"type"];
        model.icon = [results stringForColumn:@"icon"];
        model.status = [results intForColumn:@"status"];
        model.createdAt = results[@"created_at"];
        model.updatedAt = results[@"updated_at"];
        return model;
    }
    return nil;
}

// 删除分类
+ (void)deleteCategoryById :(NSInteger)Id {
    NSString *deleteSQL = @"UPDATE Category SET `status`=1 WHERE `id` = ?;";
    NSLog(@"%@", deleteSQL);
    [[DatabaseManager sharedManager].db executeUpdate:deleteSQL, @(Id)];
}

@end
