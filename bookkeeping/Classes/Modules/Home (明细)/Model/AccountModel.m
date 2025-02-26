//
//  Account.m
//  bookkeeping
//
//  Created by Hum on 2025/2/26.
//  Copyright © 2025 kk. All rights reserved.
//

#import "AccountModel.h"
#import "DatabaseManager.h"

@implementation AccountModel

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
    AccountModel *model = [[[self class] allocWithZone:zone] init];
    model.Id = self.Id;
    model.name = self.name;
    model.status = self.status;
    model.is_default = self.is_default;
    model.default_exchange_rate = self.default_exchange_rate;
    return model;
}

+ (AccountModel *) getDefaultAccount{
    NSString *sql = @"select * from Account where `is_default`=1;";
    FMResultSet *results = [[DatabaseManager sharedManager].db executeQuery:sql];
    if ([results next]) {
        AccountModel *model = [[AccountModel alloc] init];
        model.Id = [results intForColumn:@"id"];
        model.name = [results stringForColumn:@"name"];
        model.status = [results intForColumn:@"status"];
        model.is_default = [results intForColumn:@"is_default"];
        model.is_default = [results intForColumn:@"is_default"];
        return model;
    }
    return nil;
}

+ (NSArray<AccountModel *> *)getAccountsWithCondition:(NSDictionary<NSString *,id> *)conditions {
    NSMutableArray<AccountModel *> *accounts = [NSMutableArray array];
    NSMutableString *query = [NSMutableString stringWithString:@"SELECT * FROM Account"];
    NSMutableArray *arguments = [NSMutableArray array];
    
    if (conditions.count > 0) {
        [query appendString:@" WHERE "];
        __block int i = 0;
        [conditions enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (i > 0) {
                [query appendString:@" AND "];
            }
            [query appendFormat:@"%@ ?", key];
            [arguments addObject:obj];
            i++;
        }];
    }
    FMResultSet *rs = [[DatabaseManager sharedManager].db executeQuery:query withArgumentsInArray: arguments];
    while ([rs next]) {
        AccountModel *account = [[AccountModel alloc] init];
        account.Id = [rs intForColumn:@"Id"];
        account.name = [rs stringForColumn:@"name"];
        account.money_icon = [rs stringForColumn:@"money_icon"];
        account.status = [rs intForColumn:@"status"];
        account.is_default = [rs intForColumn:@"is_default"];
        account.default_exchange_rate = [rs intForColumn:@"default_exchange_rate"];
        [accounts addObject:account];
    }
    [rs close];
    return accounts;
}

+ (BOOL)createAccount:(AccountModel *)account {
    NSString *sql = @"INSERT INTO Account (name, money_icon, status, is_default, default_exchange_rate) VALUES (?,?,?,?,?)";
    BOOL result = [[DatabaseManager sharedManager].db executeUpdate:sql, account.name, account.money_icon, @(account.status), @(account.is_default), @(account.default_exchange_rate)];
    return result;
}


+ (BOOL)updateAccount:(AccountModel *)account {
    NSString *sql = @"UPDATE Account SET name = ?, money_icon = ?, status = ?, is_default = ?, default_exchange_rate = ? WHERE Id = ?";
    BOOL result = [[DatabaseManager sharedManager].db executeUpdate:sql, account.name, account.money_icon, @(account.status), @(account.is_default), @(account.default_exchange_rate), @(account.Id)];
    return result;
}

+ (AccountModel *)getAccountById:(NSInteger)Id {
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Account WHERE Id = %ld", (long)Id];
    FMResultSet *rs = [[DatabaseManager sharedManager].db executeQuery:query];
    if ([rs next]) {
        AccountModel *account = [[AccountModel alloc] init];
        account.Id = [rs intForColumn:@"Id"];
        account.name = [rs stringForColumn:@"name"];
        account.money_icon = [rs stringForColumn:@"money_icon"];
        account.status = [rs intForColumn:@"status"];
        account.is_default = [rs intForColumn:@"is_default"];
        account.default_exchange_rate = [rs intForColumn:@"default_exchange_rate"];
        [rs close];
        return account;
    }
    [rs close];
    return nil;
}

+ (void)deleteAccountById:(NSInteger)Id {
    NSString *deleteQuery = @"UPDATE Account SET `status`=10 WHERE id = ?";
    [[DatabaseManager sharedManager].db executeUpdate:deleteQuery, @(Id)];
}

@end
