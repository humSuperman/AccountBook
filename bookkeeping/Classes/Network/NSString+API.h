/**
 * 地址
 * @author 郑业强 2018-12-21 创建文件
 */

#import <Foundation/Foundation.h>


//#define KHost @"http://127.0.0.1:8080"
#define KHost @"http://192.168.1.7:8080"
//#define KStatic(str) [NSString stringWithFormat:@"http://127.0.0.1:8080/media/%@", str]
#define KStatic(str) [NSString stringWithFormat:@"http://192.168.1.7:8080/media/%@", str]
#define kUser  @"kUser"
#define Request(A) [NSString stringWithFormat:@"%@%@", KHost, A]

// 用户类别列表
#define CustomerCategoryListRequest Request(@"/shayu/getCustomerCategoryListRequest.action")
// 添加用户类别
#define AddInsertCategoryListRequest Request(@"/shayu/addInsertCategoryRequest.action")

// 声音
#define SoundRequest Request(@"/shayu/soundRequest.action")
// 详情
#define DetailRequest Request(@"/shayu/detailRequest.action")

