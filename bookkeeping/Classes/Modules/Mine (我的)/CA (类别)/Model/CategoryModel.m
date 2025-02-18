/**
 * 分类model
 * @author Hum 2025-02-18 创建文件
 */

#import "CategoryModel.h"
#import "DatabaseManager.h"

@implementation CategoryModel

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

// 获取所有分类
+ (NSArray<CategoryModel *> *)getAllCategories {
    NSString *selectSQL = @"SELECT * FROM Category";
    
    // 获取查询结果
    FMResultSet *results = [[DatabaseManager sharedManager].db executeQuery:selectSQL];
    
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
+ (CategoryModel *)getCategorieById :(NSInteger)Id {
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
+ (void)deleteCategorieById :(NSInteger)Id {
    NSString *deleteSQL = @"UPDATE Category SET status=1 where id = ?";
    [[DatabaseManager sharedManager].db executeQuery:deleteSQL, @(Id)];
}

@end
