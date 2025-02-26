#import "DatabaseManager.h"

@implementation DatabaseManager

+ (instancetype)sharedManager {
    static DatabaseManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)closeDatabase {
    if (self.db) {
        [self.db close];
        self.db = nil;
        NSLog(@"Database connection closed.");
    }
}

- (void)openDatabase {
    // 获取数据库路径，保存在 Documents 目录中
    NSString *dbPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/bookkeeping.db"];
    NSLog(@"数据库路径： %@",dbPath);
    self.db = [FMDatabase databaseWithPath:dbPath];
    if (![self.db open]) {
        NSLog(@"Failed to open database!!!");
    }else{
        NSLog(@"Success to open database...");
    }
    [self createConfigTable];
    [self checkAndMigrateDatabase];

}

- (void)createConfigTable {

    NSString *checkTableQuery = @"SELECT name FROM sqlite_master WHERE type='table' AND name='Config'";
    FMResultSet *results = [self.db executeQuery:checkTableQuery];

    if (![results next]) {
        NSString *tableSql = @"CREATE TABLE IF NOT EXISTS Config (`id` INTEGER PRIMARY KEY autoincrement,`key` VARCHAR(50) not null default '',`value` VARCHAR(255)  not null default '')";
        if (![self.db executeUpdate:tableSql]) {
            NSLog(@"Failed to create Config table: %@", [self.db lastErrorMessage]);
        }
        NSString *idxSql =  @"CREATE INDEX IF NOT EXISTS idx_config_key ON Config (key);";
        if (![self.db executeUpdate:idxSql]) {
            NSLog(@"Failed to create Config index: %@", [self.db lastErrorMessage]);
        }

        NSString *versionQuery = @"INSERT INTO Config (`key`, `value`) VALUES ('db_version', 0)";
        if (![self.db executeUpdate:versionQuery]) {
            NSLog(@"Failed to insert initial version: %@", [self.db lastErrorMessage]);
        }
    }
}


- (void)updateDatabaseVersion:(NSInteger)version {
    // 更新数据库版本号
    NSString *updateVersionQuery = @"UPDATE Config SET `value` = ? WHERE `key` = 'db_version'";
    if (![self.db executeUpdate:updateVersionQuery, @(version)]) {
        NSLog(@"Failed to update database version: %@", [self.db lastErrorMessage]);
    }
}

- (void)checkAndMigrateDatabase {
    NSInteger savedVersion = [self getSavedDatabaseVersion];

    [self migrateDatabaseFromVersion:savedVersion];
}

- (NSInteger)getSavedDatabaseVersion {
    // 从数据库中读取当前存储的版本号
    NSString *versionQuery = @"SELECT `value` FROM Config WHERE `key` = 'db_version'";
    FMResultSet *results = [self.db executeQuery:versionQuery];

    NSInteger savedVersion = 0;
    if ([results next]) {
        savedVersion = [results intForColumn:@"value"];
    }

    return savedVersion;
}

- (void)migrateDatabaseFromVersion:(NSInteger)fromVersion  {
    // 执行迁移逻辑
    if (fromVersion < 1) {
        [self createAccountBook];
        [self updateDatabaseVersion:1];
        fromVersion = 1;
    }

    if (fromVersion < 2) {
        [self createCategoryModel];
        [self updateDatabaseVersion:2];
        fromVersion = 2;
    }

    if (fromVersion < 3) {
        [self createAccountTable];
        [self accountBookAddAccountIdField];
        [self categoryAddSortField];
        [self updateDatabaseVersion:3];
        fromVersion = 3;
    }

}



- (void)createAccountBook {
    // 创建表格的 SQL 语句
    NSString *tableSql = @"CREATE TABLE IF NOT EXISTS `AccountBook` (`id` INTEGER PRIMARY KEY autoincrement, `price` INTEGER not null default 0, `year` INTEGER not null default 0, `month` INTEGER not null default 0, `day` INTEGER not null default 0, `mark` varchar(50) not null default '', `category_id` INTEGER not null default 0, `type` INTEGER not null default 0,`created_at` datetime default (datetime('now', 'localtime')),`updated_at` datetime default (datetime('now', 'localtime')))";

    if (![self.db executeUpdate:tableSql]) {
        NSLog(@"Failed to create Config index: %@", [self.db lastErrorMessage]);
    }
    NSString *idxSql = @"CREATE INDEX IF NOT EXISTS idx_date ON AccountBook (year,month,day);";
    if (![self.db executeUpdate:idxSql]) {
        NSLog(@"Failed to create AccountBook index: %@", [self.db lastErrorMessage]);
    }
    idxSql = @"CREATE INDEX IF NOT EXISTS idx_month ON AccountBook (month,day);";
    if (![self.db executeUpdate:idxSql]) {
        NSLog(@"Failed to create AccountBook index: %@", [self.db lastErrorMessage]);
    }
    idxSql = @"CREATE INDEX IF NOT EXISTS idx_day ON AccountBook (day);";
    if (![self.db executeUpdate:idxSql]) {
        NSLog(@"Failed to create AccountBook index: %@", [self.db lastErrorMessage]);
    }
    idxSql = @"CREATE INDEX IF NOT EXISTS idx_type ON AccountBook (type);";
    if (![self.db executeUpdate:idxSql]) {
        NSLog(@"Failed to create AccountBook index: %@", [self.db lastErrorMessage]);
    }
    NSLog(@"Success to create AccountBook table");
}


- (void)createCategoryModel {
    // 创建表格的 SQL 语句
    NSString *tableSql = @"CREATE TABLE IF NOT EXISTS `Category` (`id` INTEGER PRIMARY KEY AUTOINCREMENT,`name` varchar(50) NOT NULL default '',`type` INTEGER NOT NULL default 0,`status` INTEGER DEFAULT 0,`icon` varchar(100) default '',`created_at` datetime default (datetime('now', 'localtime')),`updated_at` datetime default (datetime('now', 'localtime')))";

    NSString *dataSql = @"INSERT INTO `Category` (`id`, `name`, `type`, `icon`)"
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

    if (![self.db executeUpdate:tableSql]) {
        NSLog(@"Failed to create Category table: %@", [self.db lastErrorMessage]);
    }

    if (![self.db executeUpdate:dataSql]) {
        NSLog(@"Failed to insert Category data: %@", [self.db lastErrorMessage]);
    }
    NSString *idxSql = @"CREATE INDEX IF NOT EXISTS idx_type ON Category (type);";
    if (![self.db executeUpdate:idxSql]) {
        NSLog(@"Failed to insert Category index: %@", [self.db lastErrorMessage]);
    }
    NSLog(@"Success to create Category table");
}

- (void) createAccountTable{
    NSString *tableSql = @"CREATE TABLE IF NOT EXISTS `Account` (`id` INTEGER PRIMARY KEY autoincrement, `name` varchar(20) not null default '', `money_icon` varchar(10) not null default '',`status` INTEGER not null default 0,`is_default` INTEGER not null default 0,`default_exchange_rate` INTEGER not null default 0,`created_at` datetime default (datetime('now', 'localtime')),`updated_at` datetime default (datetime('now', 'localtime')))";

    if (![self.db executeUpdate:tableSql]) {
        NSLog(@"Failed to create Account table: %@", [self.db lastErrorMessage]);
    }

    if (![self.db executeUpdate:@"INSERT INTO Account (`id`,`name`,`money_icon`,`status`,`is_default`,`default_exchange_rate`) VALUES (1,'默认账本','¥',1,1,10000);"]) {
        NSLog(@"Failed to insert Account: %@", [self.db lastErrorMessage]);
    }
}

- (void) accountBookAddAccountIdField{
    if (![self.db executeUpdate:@"ALTER TABLE AccountBook ADD COLUMN `account_id` INTEGER not null default 0;"]) {
        NSLog(@"Failed to create Account table: %@", [self.db lastErrorMessage]);
    }

    if (![self.db executeUpdate:@"UPDATE AccountBook set `account_id`=1;"]) {
        NSLog(@"Failed to update Account account_id: %@", [self.db lastErrorMessage]);
    }

    if (![self.db executeUpdate:@"ALTER TABLE AccountBook ADD COLUMN `exchange_rate` INTEGER not null default 0;"]) {
        NSLog(@"Failed to create Account table: %@", [self.db lastErrorMessage]);
    }

    if (![self.db executeUpdate:@"UPDATE AccountBook set `exchange_rate`=10000;"]) {
        NSLog(@"Failed to update Account account_id: %@", [self.db lastErrorMessage]);
    }
}

- (void) categoryAddSortField{
    if (![self.db executeUpdate:@"ALTER TABLE Category ADD COLUMN `sort` INTEGER not null default 0;"]) {
        NSLog(@"Failed to Category sort: %@", [self.db lastErrorMessage]);
    }
}
@end
