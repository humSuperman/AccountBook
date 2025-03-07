/**
 * 图表
 * @author 郑业强 2018-12-18 创建文件
 */

#import "BaseTableCell.h"
#import "AccountBook.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChartTableCell : BaseTableCell

@property (nonatomic, assign) CGFloat maxPrice;
@property (nonatomic, strong) AccountBook *model;
//@property (nonatomic, strong) BookGroupModel *model;

@end

NS_ASSUME_NONNULL_END
