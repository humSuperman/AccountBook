
#import "BaseModel.h"
#import <Foundation/Foundation.h>

@interface CategoryModel : BaseModel<NSCoding, NSCopying>

@property (nonatomic, assign) NSInteger Id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *updatedAt;

- (NSString *)getIconForSuffix:(NSString *)suffix;
+ (void)addCategory:(CategoryModel *)model;
+ (void)updateCategory:(CategoryModel *)model;
+ (NSArray<CategoryModel *> *)getAllCategories;
+ (CategoryModel *)getCategoryById:(NSInteger)Id;
+ (void)deleteCategoryById :(NSInteger)Id;
@end

