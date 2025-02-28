/**
 * 记账model
 * @author Hum 2025-02-26 创建文件
 */

#import "BaseModel.h"
#import "CategoryModel.h"
#import "BKCIncomeModel.h"


NS_ASSUME_NONNULL_BEGIN


@interface AccountBook : BaseModel<NSCoding, NSCopying>

@property (nonatomic, assign) NSInteger Id;
@property (nonatomic, assign) NSInteger account_id; // 账本id
@property (nonatomic, assign) NSInteger category_id;
@property (nonatomic, assign) NSInteger price;
@property (nonatomic, assign) NSInteger exchange_rate; // 汇率*10000
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign) NSInteger week;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy  ) NSString *mark;
@property (nonatomic, copy  ) NSString *dateStr;    // 日期(例: 01月03日 星期五)
@property (nonatomic, strong) NSDate *date;         // 日期
@property (nonatomic, assign) NSInteger dateNumber; // 日期数字
@property (nonatomic, strong) BKCModel *cmodel;
@property (nonatomic, strong) CategoryModel *category;

- (CategoryModel *)categoryModel;

// 获取Id
+ (NSNumber *)getId;
+ (void)saveAccountBook:(AccountBook *)model;
+ (NSArray<AccountBook *> *)getAllModels;
+ (NSArray<AccountBook *> *)getAllModelsWithConditions:(NSDictionary<NSString *,id> *)conditions;
+ (NSInteger)sumPriceWithConditions:(NSDictionary<NSString *,id> *)conditions;
+ (void)updateAccountBook:(AccountBook *)model;
+ (AccountBook *)getAccountById:(NSInteger)modelId;
+ (void)deleteAccountById:(NSInteger)modelId;
@end


// 数据统计(首页)
@interface BKMonthModel : BaseModel<NSCoding>

@property (nonatomic, strong) NSDate *date;         // 日期
@property (nonatomic, copy  ) NSString *dateStr;    // 日期(例: 01月03日 星期五)
@property (nonatomic, copy  ) NSString *moneyStr;   // 支出收入(例: 收入: 23  支出: 165)
@property (nonatomic, assign) NSInteger income;       // 收入
@property (nonatomic, assign) NSInteger pay;          // 支出
@property (nonatomic, strong) NSMutableArray<AccountBook *> *list;  // 数据

// 统计数据
+ (NSMutableArray<BKMonthModel *> *)statisticalMonthWithYear:(NSInteger)year month:(NSInteger)month;

@end


// 数据统计(图表)
@interface BookChartModel : BaseModel<NSCoding>

@property (nonatomic, assign) NSString *sum;                          // 总值
@property (nonatomic, assign) NSString *max;                          // 最大值
@property (nonatomic, assign) NSString *avg;                          // 平均值
@property (nonatomic, assign) BOOL is_income;                       // 是否是收入
@property (nonatomic, strong) NSMutableArray<AccountBook *> *groupArr;  // 排行榜
@property (nonatomic, strong) NSMutableArray<AccountBook *> *chartArr;  // 图表
@property (nonatomic, strong) NSMutableArray<NSMutableArray<AccountBook *> *> *chartHudArr;  // 图表

// 统计数据(图表首页)
+ (BookChartModel *)statisticalChart:(NSInteger)status isIncome:(BOOL)isIncome date:(NSDate *)date;

@end


NS_ASSUME_NONNULL_END
