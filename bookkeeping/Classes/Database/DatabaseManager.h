#import <Foundation/Foundation.h>
#import <fmdb/FMDB.h>

@interface DatabaseManager : NSObject

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, assign) NSInteger currentVersion;

+ (instancetype)sharedManager;
- (void)closeDatabase;
- (void)openDatabase;
- (void)checkAndMigrateDatabase;

@end
