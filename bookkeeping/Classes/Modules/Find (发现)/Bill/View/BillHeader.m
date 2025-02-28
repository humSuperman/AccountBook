/**
 * 头视图
 * @author 郑业强 2019-01-09 创建文件
 */

#import "BillHeader.h"
#import "MoneyConverter.h"

#pragma mark - 声明
@interface BillHeader()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labConstraintL;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UILabel *lab1;
@property (weak, nonatomic) IBOutlet UILabel *lab2;
@property (weak, nonatomic) IBOutlet UILabel *lab3;
@property (weak, nonatomic) IBOutlet UILabel *money1Lab;
@property (weak, nonatomic) IBOutlet UILabel *money2Lab;
@property (weak, nonatomic) IBOutlet UILabel *money3Lab;
@property (weak, nonatomic) IBOutlet UIView *content;

@end


#pragma mark - 实现
@implementation BillHeader


- (void)initUI {
    [self.content setBackgroundColor:kColor_Main_Color];
    [self.line setBackgroundColor:kColor_BG];
    [self.line1 setBackgroundColor:[kColor_Text_Black colorWithAlphaComponent:0.5]];
    [self.labConstraintL setConstant:countcoordinatesX(20)];
    
    for (id obj in self.subviews) {
        if ([obj isKindOfClass:[UILabel class]]) {
            UILabel *lab = obj;
            lab.font = [UIFont systemFontOfSize:AdjustFont(10)];
            lab.textColor = kColor_Text_Gary;
        }
    }
    [self.lab1 setFont:[UIFont systemFontOfSize:AdjustFont(10) weight:UIFontWeightLight]];
    [self.lab1 setTextColor:kColor_Text_Black];
    [self.lab2 setFont:[UIFont systemFontOfSize:AdjustFont(10) weight:UIFontWeightLight]];
    [self.lab2 setTextColor:kColor_Text_Black];
    [self.lab3 setFont:[UIFont systemFontOfSize:AdjustFont(10) weight:UIFontWeightLight]];
    [self.lab3 setTextColor:kColor_Text_Black];
    [self.money1Lab setFont:[UIFont systemFontOfSize:AdjustFont(30) weight:UIFontWeightLight]];
    [self.money1Lab setTextColor:kColor_Text_Black];
    
}


#pragma mark - set
// todo 这里有bug
- (void)setIncome:(NSInteger )income {
    _income = income;
    self.money2Lab.text = [MoneyConverter toRealMoney:income];
    self.money1Lab.text = [MoneyConverter toRealMoney:(income-_pay)];
}
- (void)setPay:(NSInteger )pay {
    _pay = pay;
    self.money3Lab.text = [MoneyConverter toRealMoney:pay];
    self.money1Lab.text = [MoneyConverter toRealMoney:(_income-pay)];
}



@end
