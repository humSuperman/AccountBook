//
//  Account.h
//  bookkeeping
//
//  Created by Hum on 2025/2/26.
//  Copyright © 2025 kk. All rights reserved.
//

#import "BaseModel.h"


NS_ASSUME_NONNULL_BEGIN


@interface AccountModel : BaseModel<NSCoding, NSCopying>

@property (nonatomic, assign) NSInteger Id;
@property (nonatomic, copy  ) NSString *name;       // 账本名
@property (nonatomic, copy  ) NSString *money_icon;  // 金额标记
@property (nonatomic, assign) NSInteger status;      // 账本状态 1-正在使用 2-停用 3-归档
@property (nonatomic, assign) NSInteger is_default;   // 是否默认 1-默认 other-不默认
@property (nonatomic, assign) NSInteger default_exchange_rate; // 默认汇率 x*10000


+ (AccountModel *) getDefaultAccount;
+ (void)deleteAccountById:(NSInteger)Id;
+ (NSArray<AccountModel *> *)getAccountsWithCondition:(NSDictionary<NSString *,id> *)conditions;
+ (BOOL)createAccount:(AccountModel *)account;
+ (BOOL)updateAccount:(AccountModel *)account;
+ (AccountModel *)getAccountById:(NSInteger)Id;

@end

NS_ASSUME_NONNULL_END
