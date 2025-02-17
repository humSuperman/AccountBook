#import "DatabaseManager.h"
#import "BKModel.h"

@implementation DatabaseManager

+ (instancetype)sharedManager {
    static DatabaseManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance openDatabase];
        [sharedInstance checkAndMigrateDatabase];
    });
    return sharedInstance;
}

- (void)openDatabase {
    // 获取数据库路径，保存在 Documents 目录中
    NSString *dbPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/bookkeeping.db"];
    self.db = [FMDatabase databaseWithPath:dbPath];
    if (![self.db open]) {
        NSLog(@"Failed to open database!!!");
    }else{
        NSLog(@"Success to open database...");
    }
    [self createDBVersionTable];
    [self checkAndMigrateDatabase];

}

- (void)createDBVersionTable {

    NSString *checkTableQuery = @"SELECT name FROM sqlite_master WHERE type='table' AND name='DBVersion'";
    FMResultSet *results = [self.db executeQuery:checkTableQuery];

    if (![results next]) {
        // 如果没有找到表，创建它
        NSString *createTableQuery = @"CREATE TABLE IF NOT EXISTS DBVersion (id INTEGER PRIMARY KEY, version INTEGER)";
        if (![self.db executeUpdate:createTableQuery]) {
            NSLog(@"Failed to create DBVersion table: %@", [self.db lastErrorMessage]);
        }

        // 设置初始版本为 0
        NSString *insertVersionQuery = @"INSERT INTO DBVersion (id, version) VALUES (1, 0)";
        if (![self.db executeUpdate:insertVersionQuery]) {
            NSLog(@"Failed to insert initial version: %@", [self.db lastErrorMessage]);
        }
    }
}

- (void)checkAndMigrateDatabase {
    NSInteger savedVersion = [self getSavedDatabaseVersion];

    [self migrateDatabaseFromVersion:savedVersion];
}

- (NSInteger)getSavedDatabaseVersion {
    // 从数据库中读取当前存储的版本号
    NSString *versionQuery = @"SELECT version FROM DBVersion WHERE id = 1";
    FMResultSet *results = [self.db executeQuery:versionQuery];

    NSInteger savedVersion = 0;
    if ([results next]) {
        savedVersion = [results intForColumn:@"version"];
    }

    return savedVersion;
}

- (void)migrateDatabaseFromVersion:(NSInteger)fromVersion  {
    // 执行迁移逻辑
    if (fromVersion < 1) {
        [self createTable];
        [self updateDatabaseVersion:1];
    }

    if (fromVersion < 2) {
    // 可以继续添加其他版本的迁移操作
    }

}



- (void)createTable {
    // 创建表格的 SQL 语句
    NSString *createTableQuery = @"CREATE TABLE IF NOT EXISTS BKModel (Id INTEGER PRIMARY KEY autoincrement, price INTEGER, year INTEGER, month INTEGER, day INTEGER, mark TEXT, category_id INTEGER, cmodelId INTEGER,created_at datetime default (datetime('now', 'localtime')),updated_at datetime default (datetime('now', 'localtime')))";
    if (![self.db executeUpdate:createTableQuery]) {
        NSLog(@"Failed to create table: %@", [self.db lastErrorMessage]);
    }
    NSLog(@"Success to create table");
}

- (void)saveModel:(BKModel *)model {
    // 插入数据的 SQL 语句
    NSString *insertQuery = @"INSERT INTO BKModel (price, year, month, day, mark, category_id, cmodelId) VALUES (?, ?, ?, ?, ?, ?, ?)";
    [self.db executeUpdate:insertQuery, @(model.price), @(model.year), @(model.month), @(model.day), model.mark, @(model.category_id), @(model.cmodel.Id)];
    NSLog(@"Success to save BKModel");
}

- (NSArray<BKModel *> *)getAllModels {
    NSMutableArray *models = [NSMutableArray array];
    NSString *selectQuery = @"SELECT * FROM BKModel";
    FMResultSet *results = [self.db executeQuery:selectQuery];

    while ([results next]) {
        BKModel *model = [[BKModel alloc] init];
        model.Id = [results intForColumn:@"Id"];
        model.price = [results intForColumn:@"price"];
        model.year = [results intForColumn:@"year"];
        model.month = [results intForColumn:@"month"];
        model.day = [results intForColumn:@"day"];
        model.mark = [results stringForColumn:@"mark"];
        model.category_id = [results intForColumn:@"category_id"];
        // 你可以根据需要填充 `cmodel`
        [models addObject:model];
    }
    return models;
}

- (NSArray<BKModel *> *)getAllModelsWithConditions:(NSDictionary<NSString *,id> *)conditions {
    NSMutableArray *models = [NSMutableArray array];
    
    // 构建 SQL 查询语句
    NSMutableString *selectQuery = [NSMutableString stringWithString:@"SELECT * FROM BKModel"];
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
    NSLog(@"查询sql及条件");
    NSLog(@"%@",selectQuery);
    NSLog(@"%@",arguments);
    // 执行查询
    FMResultSet *results = [self.db executeQuery:selectQuery withArgumentsInArray:arguments];
    while ([results next]) {
        BKModel *model = [[BKModel alloc] init];
        model.Id = [results intForColumn:@"Id"];
        model.price = [results intForColumn:@"price"];
        model.year = [results intForColumn:@"year"];
        model.month = [results intForColumn:@"month"];
        model.day = [results intForColumn:@"day"];
        model.mark = [results stringForColumn:@"mark"];
        model.category_id = [results intForColumn:@"category_id"];
        // 你可以根据需要填充 `cmodel`
        [models addObject:model];
    }
    [results close];
    
    return models;
}

- (void)updateModel:(BKModel *)model {
    NSString *updateQuery = @"UPDATE BKModel SET price = ?, year = ?, month = ?, day = ?, mark = ?, category_id = ?,updated_at = DATETIME('now', 'localtime') WHERE Id = ?";
    [self.db executeUpdate:updateQuery, @(model.price), @(model.year), @(model.month), @(model.day), model.mark, @(model.category_id), @(model.Id)];
    NSLog(@"Success to update BKModel");
}

- (BKModel *)getModelById:(NSInteger)modelId{
    NSString *selectQuery = @"SELECT * FROM BKModel WHERE Id = ?";
    FMResultSet *results = [self.db executeQuery:selectQuery, @(modelId)];

    if ([results next]) {
        BKModel *model = [[BKModel alloc] init];
        model.Id = [results intForColumn:@"Id"];
        model.price = [results doubleForColumn:@"price"];
        model.year = [results intForColumn:@"year"];
        model.month = [results intForColumn:@"month"];
        model.day = [results intForColumn:@"day"];
        model.mark = [results stringForColumn:@"mark"];
        model.category_id = [results intForColumn:@"category_id"];
        // 设置 cmodel，如果需要的话
        return model;
    }
    return nil;  // 如果找不到，返回 nil
}

- (void)deleteModelById:(NSInteger)modelId {
    NSString *deleteQuery = @"DELETE FROM BKModel WHERE Id = ?";
    [self.db executeUpdate:deleteQuery, @(modelId)];
    NSLog(@"Success to delete BKModel");
}

- (void)updateDatabaseVersion:(NSInteger)version {
    // 更新数据库版本号
    NSString *updateVersionQuery = @"REPLACE INTO DBVersion (id, version) VALUES (1, ?)";
    if (![self.db executeUpdate:updateVersionQuery, @(version)]) {
        NSLog(@"Failed to update database version: %@", [self.db lastErrorMessage]);
    }
}

@end
