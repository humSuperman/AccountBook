/**
 * 发现
 * @author Hum 2025-02-28
 */

#import "FindCell.h"
#import "AccountBook.h"
#import "MoneyConverter.h"

#pragma mark - 声明
@interface FindCell()

@property (weak, nonatomic) IBOutlet UIImageView *line;
@property (weak, nonatomic) IBOutlet UILabel *billLab;
@property (weak, nonatomic) IBOutlet UIImageView *nextBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *billConstraintL;
@property (weak, nonatomic) IBOutlet UILabel *monthLab;
@property (weak, nonatomic) IBOutlet UILabel *monthDescLab;
@property (weak, nonatomic) IBOutlet UILabel *moneyDescLab1;
@property (weak, nonatomic) IBOutlet UILabel *moneyDescLab2;
@property (weak, nonatomic) IBOutlet UILabel *moneyDescLab3;
@property (weak, nonatomic) IBOutlet UILabel *moneyLab1;
@property (weak, nonatomic) IBOutlet UILabel *moneyLab2;
@property (weak, nonatomic) IBOutlet UILabel *moneyLab3;

@end


#pragma mark - 实现
@implementation FindCell


- (void)initUI {
    NSDate *date = [NSDate date];
    [self.billLab setFont:[UIFont systemFontOfSize:AdjustFont(12) weight:UIFontWeightLight]];
    [self.billLab setTextColor:kColor_Text_Black];
    [self.monthLab setText:[NSString stringWithFormat:@"%ld",date.month]];
    [self.monthLab setFont:[UIFont systemFontOfSize:AdjustFont(18)]];
    [self.monthLab setTextColor:kColor_Text_Black];
    [self.monthDescLab setFont:[UIFont systemFontOfSize:AdjustFont(12) weight:UIFontWeightLight]];
    [self.monthDescLab setTextColor:kColor_Text_Black];
    [self.moneyDescLab1 setFont:[UIFont systemFontOfSize:AdjustFont(12) weight:UIFontWeightLight]];
    [self.moneyDescLab1 setTextColor:kColor_Text_Black];
    [self.moneyDescLab2 setFont:[UIFont systemFontOfSize:AdjustFont(12) weight:UIFontWeightLight]];
    [self.moneyDescLab2 setTextColor:kColor_Text_Black];
    [self.moneyDescLab3 setFont:[UIFont systemFontOfSize:AdjustFont(12) weight:UIFontWeightLight]];
    [self.moneyDescLab3 setTextColor:kColor_Text_Black];
    [self.moneyLab1 setAttributedText:[NSAttributedString createMath:@"00.00" integer:[UIFont systemFontOfSize:AdjustFont(14)] decimal:[UIFont systemFontOfSize:AdjustFont(12)]]];
    [self.moneyLab2 setAttributedText:[NSAttributedString createMath:@"00.00" integer:[UIFont systemFontOfSize:AdjustFont(14)] decimal:[UIFont systemFontOfSize:AdjustFont(12)]]];
    [self.moneyLab3 setAttributedText:[NSAttributedString createMath:@"00.00" integer:[UIFont systemFontOfSize:AdjustFont(14)] decimal:[UIFont systemFontOfSize:AdjustFont(12)]]];
    [self.line setImage:[UIColor createImageWithColor:kColor_BG]];
    [self.billConstraintL setConstant:countcoordinatesX(15)];

    // 过滤
    NSMutableDictionary *conditions = [NSMutableDictionary dictionary];
    [conditions setObject:@(date.year) forKey:@"year ="];
    [conditions setObject:@(date.month) forKey:@"month ="];
    NSArray<AccountBook *> *list = [AccountBook getAllModelsWithConditions:conditions];
    
    NSInteger income = 0;
    NSInteger pay = 0;
    for (AccountBook *item in list) {
        if(item.type == 1){
            income += item.price;
        }else if(item.type == 0){
            pay += item.price;
        }
    }
    [self.moneyLab1 setAttributedText:[NSAttributedString createMath:[MoneyConverter toRealMoney:income] integer:[UIFont systemFontOfSize:AdjustFont(14)] decimal:[UIFont systemFontOfSize:AdjustFont(12)]]];

    [self.moneyLab2 setAttributedText:[NSAttributedString createMath:[MoneyConverter toRealMoney:pay] integer:[UIFont systemFontOfSize:AdjustFont(14)] decimal:[UIFont systemFontOfSize:AdjustFont(12)]]];

    [self.moneyLab3 setAttributedText:[NSAttributedString createMath:[MoneyConverter toRealMoney:(income-pay)] integer:[UIFont systemFontOfSize:AdjustFont(14)] decimal:[UIFont systemFontOfSize:AdjustFont(12)]]];

}


@end
