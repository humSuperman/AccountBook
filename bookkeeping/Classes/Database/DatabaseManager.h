#import <Foundation/Foundation.h>
#import <fmdb/FMDB.h>
#import "BKModel.h"

@interface DatabaseManager : NSObject

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, assign) NSInteger currentVersion;

+ (instancetype)sharedManager;
- (void)openDatabase;
- (void)checkAndMigrateDatabase;
- (void)createTable;
- (void)saveModel:(BKModel *)model;
- (NSArray<BKModel *> *)getAllModels;
- (NSArray<BKModel *> *)getAllModelsWithConditions:(NSDictionary<NSString *,id> *)conditions;
- (void)updateModel:(BKModel *)model;
- (BKModel *)getModelById:(NSInteger)modelId;
- (void)deleteModelById:(NSInteger)modelId;

@end
