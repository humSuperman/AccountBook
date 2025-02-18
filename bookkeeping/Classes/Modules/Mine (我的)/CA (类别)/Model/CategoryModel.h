
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

+ (void)addCategory:(CategoryModel *)model;
+ (void)updateCategory:(CategoryModel *)model;
+ (NSArray<CategoryModel *> *)getAllCategories;
+ (CategoryModel *)getCategorieById:(NSInteger)Id;
+ (void)deleteCategorieById :(NSInteger)Id;
@end
