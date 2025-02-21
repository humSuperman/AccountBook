/**
 * 我的头视图
 * @author 郑业强 2018-12-16 创建文件
 */

#import "MineTableHeader.h"
#import "MINE_EVENT_MANAGER.h"

#pragma mark - 声明
@interface MineTableHeader()

@property (weak, nonatomic) IBOutlet UIImageView *icon;     // 头像
@property (weak, nonatomic) IBOutlet UILabel *nameLab;      // 姓名
@property (weak, nonatomic) IBOutlet UIView *infoView;      // 个人信息
@property (weak, nonatomic) IBOutlet UILabel *dayLab;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconConstraintW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoConstraintT;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *numberConstraintT;

@end


#pragma mark - 实现
@implementation MineTableHeader


- (void)initUI {
    [self setBackgroundColor:kColor_Main_Color];
    [self createLabel:self];
    [self.infoView setClipsToBounds:false];
    [self.infoView setBackgroundColor:[UIColor clearColor]];
    [self.nameLab setFont:[UIFont systemFontOfSize:AdjustFont(14) weight:UIFontWeightLight]];
    [self.nameLab setTextColor:kColor_Text_Black];

    [self.icon.layer setCornerRadius:countcoordinatesX(70) / 2];
    [self.icon.layer setMasksToBounds:true];


    @weakify(self)
    // 头像
    [self.infoView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self)
        [self routerEventWithName:MINE_HEADER_ICON_CLICK data:nil];
    }];

}
- (void)createLabel:(UIView *)view {
    for (UIView *subview in view.subviews) {
        [self createLabel:subview];
        if ([subview isKindOfClass:[UILabel class]]) {
            if (subview.tag == 10) {
                UILabel *lab = (UILabel *)subview;
                lab.font = [UIFont systemFontOfSize:AdjustFont(14) weight:UIFontWeightLight];
                lab.textColor = kColor_Text_Black;
            }
            else if (subview.tag == 11) {
                UILabel *lab = (UILabel *)subview;
                lab.font = [UIFont systemFontOfSize:AdjustFont(10) weight:UIFontWeightLight];
                lab.textColor = kColor_Text_Black;
            }
        }
    }
}


#pragma mark - set
- (void)setModel:(UserModel *)model {
    _model = model;

    [_icon setImage:[UIImage imageNamed:@"default_header"]];
    [_nameLab setText:@"私馕记账"];
}


#pragma mark - 点击


@end
