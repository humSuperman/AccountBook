#import "MoneyConverter.h"

@implementation MoneyConverter

// 分转元
+ (NSString *)toRealMoney:(NSInteger)money {
    NSDecimalNumber *fenDecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%ld", money]];
    NSDecimalNumber *divisor = [NSDecimalNumber decimalNumberWithString:@"100"];
    NSDecimalNumber *result = [fenDecimal decimalNumberByDividingBy:divisor];
    return [result stringValue];
}


+ (CGFloat )toFloatRealMoney:(NSInteger)money {
    NSDecimalNumber *fenDecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%ld", money]];
    NSDecimalNumber *divisor = [NSDecimalNumber decimalNumberWithString:@"100"];
    NSDecimalNumber *result = [fenDecimal decimalNumberByDividingBy:divisor];
    return [result doubleValue];
}

// 元转分
+ (NSInteger)toIntMoney:(NSString *)money {
    NSDecimalNumber *yuanDecimal = [NSDecimalNumber decimalNumberWithString:money];
    NSDecimalNumber *multiplier = [NSDecimalNumber decimalNumberWithString:@"100"];
    NSDecimalNumber *result = [yuanDecimal decimalNumberByMultiplyingBy:multiplier];
    return [result integerValue];
}

@end
