/**
 * 列表cell
 * @author 郑业强 2018-12-17 创建文件
 */

#import "BaseTableCell.h"
#import "AccountBook.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeListCell : BaseTableCell

//@property (nonatomic, strong) AccountBook *model;
@property (nonatomic, strong) NSMutableArray<BKMonthModel *> *models;

- (void)endRefresh;

@end

NS_ASSUME_NONNULL_END
