//
//  BDTable.h
//  bookkeeping
//
//  Created by 郑业强 on 2019/1/6.
//  Copyright © 2019年 kk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountBook.h"


NS_ASSUME_NONNULL_BEGIN

@interface BDTable : UITableView

@property (nonatomic, strong) AccountBook *model;

@end

NS_ASSUME_NONNULL_END
