/**
 * 图表弹框
 * @author 郑业强 2018-12-30 创建文件
 */

#import "BaseView.h"
#import "AccountBook.h"

NS_ASSUME_NONNULL_BEGIN

@interface BookChartHUD : BaseView

@property (nonatomic, assign) CGRect pointFrame;
@property (nonatomic, strong) NSMutableArray<AccountBook *> *models;

+ (instancetype)init;

@end

NS_ASSUME_NONNULL_END
