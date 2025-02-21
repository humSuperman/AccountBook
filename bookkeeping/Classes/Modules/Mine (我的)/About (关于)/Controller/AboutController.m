/**
 * 关于
 * @author Hum 2025-02-21 创建文件
 */

#import "AboutController.h"

#pragma mark - 声明
@interface AboutController()

@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UIButton *share;

@end


#pragma mark - 实现
@implementation AboutController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setJz_navigationBarHidden:NO];
    [self setJz_navigationBarTintColor:kColor_Main_Color];
    [self setNavTitle:@"关于私馕"];
    [self image];
    [self nameLab];
}


#pragma mark - get
- (UIImageView *)image {
    if (!_image) {
        _image = [[UIImageView alloc] initWithFrame:({
            CGFloat left = countcoordinatesX(30);
            CGFloat width = SCREEN_WIDTH - left * 2;
            CGRectMake(left, countcoordinatesX(30) + NavigationBarHeight, width, width);
        })];
        _image.contentMode = UIViewContentModeScaleAspectFit;
        _image.image = [UIImage imageNamed:@"about"];
        [self.view addSubview:_image];
    }
    return _image;
}
- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, _image.bottom, SCREEN_WIDTH, countcoordinatesX(20))];
        _nameLab.text = @"隐私保护从私馕开始";
        _nameLab.textAlignment = NSTextAlignmentCenter;
        _nameLab.font = [UIFont systemFontOfSize:AdjustFont(14) weight:UIFontWeightLight];
        [self.view addSubview:_nameLab];
    }
    return _nameLab;
}
- (UIButton *)share {
    return _share;
}



@end
