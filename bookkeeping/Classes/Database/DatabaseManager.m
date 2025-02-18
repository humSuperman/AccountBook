#import "DatabaseManager.h"

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
        [self createBKModel];
        [self updateDatabaseVersion:1];
        fromVersion = 1;
    }

    if (fromVersion < 2) {
        [self createCategoryModel];
        [self updateDatabaseVersion:2];
        fromVersion = 2;
    }

}



- (void)createBKModel {
    // 创建表格的 SQL 语句
    NSString *createTableQuery = @"CREATE TABLE IF NOT EXISTS BKModel (Id INTEGER PRIMARY KEY autoincrement, price INTEGER, year INTEGER, month INTEGER, day INTEGER, mark TEXT, category_id INTEGER, cmodelId INTEGER,created_at datetime default (datetime('now', 'localtime')),updated_at datetime default (datetime('now', 'localtime')))";
    if (![self.db executeUpdate:createTableQuery]) {
        NSLog(@"Failed to create table: %@", [self.db lastErrorMessage]);
    }
    NSLog(@"Success to create table");
}


- (void)createCategoryModel {
    // 创建表格的 SQL 语句
    NSString *sql = @"CREATE TABLE IF NOT EXISTS Category (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL default '',type INTEGER NOT NULL default 0,status INTEGER DEFAULT 0,icon TEXT default '',created_at datetime default (datetime('now', 'localtime')),updated_at datetime default (datetime('now', 'localtime')))";
    
    NSString *dataSql = @"INSERT INTO Category (id, name, type, icon)"
    "VALUES"
    "(1, '餐饮', 0, 'e_catering'),"
    "(2, '零食', 0, 'e_snack'),"
    "(3, '购物', 0, 'e_shopping'),"
    "(4, '交通', 0, 'e_traffic'),"
    "(5, '运动', 0, 'e_sport'),"
    "(6, '汽车', 0, 'e_car'),"
    "(7, '医疗', 0, 'e_medical'),"
    "(8, '宠物', 0, 'e_pet'),"
    "(9, '书籍', 0, 'e_books'),"
    "(10, '学习', 0, 'e_study'),"
    "(11, '礼物', 0, 'e_gift'),"
    "(12, '办公', 0, 'e_office'),"
    "(13, '维修', 0, 'e_repair'),"
    "(14, '捐赠', 0, 'e_donate'),"
    "(15, '彩票', 0, 'e_lottery'),"
    "(16, '快递', 0, 'e_express'),"
    "(17, '社交', 0, 'e_social'),"
    "(18, '美容', 0, 'e_beauty'),"
    "(19, '水果', 0, 'e_fruite'),"
    "(20, '旅行', 0, 'e_travel'),"
    "(21, '娱乐', 0, 'e_entertainmente'),"
    "(22, '礼金', 0, 'e_money'),"
    "(23, '蔬菜', 0, 'e_vegetable'),"
    "(24, '长辈', 0, 'e_elder'),"
    "(25, '住房', 0, 'e_house'),"
    "(26, '孩子', 0, 'e_child'),"
    "(27, '通讯', 0, 'e_communicate'),"
    "(28, '服饰', 0, 'e_dress'),"
    "(29, '日用', 0, 'e_commodity'),"
    "(30, '烟酒', 0, 'e_smoke'),"
    "(31, '亲友', 0, 'e_friend'),"
    "(32, '数码', 0, 'e_digital'),"
    "(33, '居家', 0, 'e_home'),"
    "(34, '工资', 1, 'i_wage'),"
    "(35, '兼职', 1, 'i_parttimework'),"
    "(36, '理财', 1, 'i_finance'),"
    "(37, '礼金', 1, 'i_money'),"
    "(38, '兼职', 1, 'i_parttimework'),"
    "(39, '其它', 1, 'i_other');";

    if (![self.db executeUpdate:sql]) {
        NSLog(@"Failed to create Category table: %@", [self.db lastErrorMessage]);
    }
    
    if (![self.db executeUpdate:dataSql]) {
        NSLog(@"Failed to create Category table: %@", [self.db lastErrorMessage]);
    }
    NSLog(@"Success to create Category table");
}

- (void)updateDatabaseVersion:(NSInteger)version {
    // 更新数据库版本号
    NSString *updateVersionQuery = @"REPLACE INTO DBVersion (id, version) VALUES (1, ?)";
    if (![self.db executeUpdate:updateVersionQuery, @(version)]) {
        NSLog(@"Failed to update database version: %@", [self.db lastErrorMessage]);
    }
}

@end
