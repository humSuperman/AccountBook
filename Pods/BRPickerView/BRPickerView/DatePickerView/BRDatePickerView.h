//
//  BRDatePickerView.h
//  BRPickerViewDemo
//
//  Created by 任波 on 2017/8/11.
//  Copyright © 2017年 91renb. All rights reserved.
//
//  最新代码下载地址：https://github.com/91renb/BRPickerView

#import "BRBaseView.h"
#import "NSDate+BRPickerView.h"

/// 日期选择器格式
typedef NS_ENUM(NSInteger, BRDatePickerMode) {
    // --- 以下4种是系统自带的样式 ---
    /** 【HH:mm】UIDatePickerModeTime */
    BRDatePickerModeTime = 1,
    /** 【yyyy-MM-dd】UIDatePickerModeDate */
    BRDatePickerModeDate,
    /** 【yyyy-MM-dd HH:mm】 UIDatePickerModeDateAndTime */
    BRDatePickerModeDateAndTime,
    /** 【HH:mm】UIDatePickerModeCountDownTimer */
    BRDatePickerModeCountDownTimer,
    
    // --- 以下7种是自定义样式 ---
    /** 【yyyy-MM-dd HH:mm】年月日时分 */
    BRDatePickerModeYMDHM,
    /** 【MM-dd HH:mm】月日时分 */
    BRDatePickerModeMDHM,
    /** 【yyyy-MM-dd】年月日 */
    BRDatePickerModeYMD,
    /** 【yyyy-MM】年月 */
    BRDatePickerModeYM,
    /** 【yyyy】年 */
    BRDatePickerModeY,
    /** 【MM-dd】月日 */
    BRDatePickerModeMD,
    /** 【HH:mm】时分 */
    BRDatePickerModeHM
};

typedef void(^BRDateResultBlock)(NSString *selectValue);

@interface BRDatePickerView : BRBaseView

/**
//////////////////////////////////////////////////////////////////////////
///
///   【用法1】：传统的创建对象设置属性方式（推荐！）
///    1. 初始化选择器（使用 initWithPickerMode: 方法）
///    2. 设置相关属性；一些公共的属性或方法参见基类文件 BRBaseView.h
///    3. 显示选择器（使用 show 方法）
///
////////////////////////////////////////////////////////////////////////*/

/** 默认选中的时间（默认选中当前时间） */
@property (nonatomic, copy) NSString *selectValue;
@property (nonatomic, copy) NSString *defaultSelValue BRPickerViewDeprecated("推荐使用 selectValue");

/** 最小时间（请使用 NSDate+BRPickerView 分类中和显示类型格式对应的方法创建 minDate）*/
@property (nonatomic, strong) NSDate *minDate;
/** 最大时间（请使用 NSDate+BRPickerView 分类中和显示类型格式对应的方法创建 maxDate）*/
@property (nonatomic, strong) NSDate *maxDate;

/** 隐藏日期单位，默认为NO（值为YES时，配合 addSubViewToPicker: 方法，可以自定义单位的显示样式）*/
@property (nonatomic, assign) BOOL hiddenDateUnit;

/** 选择结果的回调 */
@property (nonatomic, copy) BRDateResultBlock resultBlock;

/// 初始化时间选择器
/// @param pickerMode  日期选择器类型
- (instancetype)initWithPickerMode:(BRDatePickerMode)pickerMode;

/// 弹出选择器视图
- (void)show;

/// 关闭选择器视图
- (void)dismiss;




//======================================== 华丽的分割线（以下为旧版本用法） ========================================


/**
//////////////////////////////////////////////////////////////////////////
///
///   【用法2】：快捷使用，直接选择下面其中的一个方法进行使用
///
////////////////////////////////////////////////////////////////////////*/

/**
 *  1.显示时间选择器
 *
 *  @param title            标题
 *  @param dateType         日期显示类型
 *  @param defaultSelValue  默认选中的时间（值为空/值格式错误时，默认就选中现在的时间）
 *  @param resultBlock      选择结果的回调
 *
 */
+ (void)showDatePickerWithTitle:(NSString *)title
                       dateType:(BRDatePickerMode)dateType
                defaultSelValue:(NSString *)defaultSelValue
                    resultBlock:(BRDateResultBlock)resultBlock;

/**
 *  2.显示时间选择器（支持 设置自动选择 和 自定义主题颜色）
 *
 *  @param title            标题
 *  @param dateType         日期显示类型
 *  @param defaultSelValue  默认选中的时间（值为空/值格式错误时，默认就选中现在的时间）
 *  @param minDate          最小时间，可为空（请使用 NSDate+BRPickerView 分类中和显示类型格式对应的方法创建 minDate）
 *  @param maxDate          最大时间，可为空（请使用 NSDate+BRPickerView 分类中和显示类型格式对应的方法创建 maxDate）
 *  @param isAutoSelect     是否自动选择，即选择完(滚动完)执行结果回调，传选择的结果值
 *  @param themeColor       自定义主题颜色
 *  @param resultBlock      选择结果的回调
 *
 */
+ (void)showDatePickerWithTitle:(NSString *)title
                       dateType:(BRDatePickerMode)dateType
                defaultSelValue:(NSString *)defaultSelValue
                        minDate:(NSDate *)minDate
                        maxDate:(NSDate *)maxDate
                   isAutoSelect:(BOOL)isAutoSelect
                     themeColor:(UIColor *)themeColor
                    resultBlock:(BRDateResultBlock)resultBlock BRPickerViewDeprecated("请使用【用法1】，支持更多的自定义样式");

/**
 *  3.显示时间选择器（支持 设置自动选择、自定义主题颜色、取消选择的回调）
 *
 *  @param title            标题
 *  @param dateType         日期显示类型
 *  @param defaultSelValue  默认选中的时间（值为空/值格式错误时，默认就选中现在的时间）
 *  @param minDate          最小时间，可为空（请使用 NSDate+BRPickerView 分类中和显示类型格式对应的方法创建 minDate）
 *  @param maxDate          最大时间，可为空（请使用 NSDate+BRPickerView 分类中和显示类型格式对应的方法创建 maxDate）
 *  @param isAutoSelect     是否自动选择，即选择完(滚动完)执行结果回调，传选择的结果值
 *  @param themeColor       自定义主题颜色
 *  @param resultBlock      选择结果的回调
 *  @param cancelBlock      取消选择的回调
 *
 */
+ (void)showDatePickerWithTitle:(NSString *)title
                       dateType:(BRDatePickerMode)dateType
                defaultSelValue:(NSString *)defaultSelValue
                        minDate:(NSDate *)minDate
                        maxDate:(NSDate *)maxDate
                   isAutoSelect:(BOOL)isAutoSelect
                     themeColor:(UIColor *)themeColor
                    resultBlock:(BRDateResultBlock)resultBlock
                    cancelBlock:(BRCancelBlock)cancelBlock BRPickerViewDeprecated("请使用【用法1】，支持更多的自定义样式");


@end
