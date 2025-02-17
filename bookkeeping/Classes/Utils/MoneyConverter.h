#import <Foundation/Foundation.h>

@interface MoneyConverter : NSObject

// 分转元
+ (NSString *)toRealMoney:(NSInteger)money;

// 元转分
+ (NSInteger)toIntMoney:(NSString *)money;

@end
