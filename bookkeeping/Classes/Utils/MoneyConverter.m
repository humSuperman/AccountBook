#import "MoneyConverter.h"

@implementation MoneyConverter

// 分转元
+ (NSString *)toRealMoney:(NSInteger)money {
    NSDecimalNumber *fenDecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%ld", money]];
    NSDecimalNumber *divisor = [NSDecimalNumber decimalNumberWithString:@"100"];
    NSDecimalNumber *result = [fenDecimal decimalNumberByDividingBy:divisor];

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
    [formatter setGroupingSeparator:@","];

    return [formatter stringFromNumber:result];
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
