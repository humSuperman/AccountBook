/**
 * 列表Cell
 * @author 郑业强 2018-12-18 创建文件
 */

#import "BaseTableCell.h"
#import "AccountBook.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeListSubCell : MGSwipeTableCell

@property (nonatomic, strong) AccountBook *model;

@end

NS_ASSUME_NONNULL_END
