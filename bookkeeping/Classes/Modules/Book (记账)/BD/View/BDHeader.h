//
//  BDHeader.h
//  bookkeeping
//
//  Created by 郑业强 on 2019/1/5.
//  Copyright © 2019年 kk. All rights reserved.
//

#import "BaseView.h"
#import "AccountBook.h"

NS_ASSUME_NONNULL_BEGIN

@interface BDHeader : BaseView

@property (nonatomic, strong) AccountBook *model;

@end

NS_ASSUME_NONNULL_END
