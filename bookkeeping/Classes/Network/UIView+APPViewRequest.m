//
//  UIView+APPViewRequest.m
//  imiss-ios-master
//
//  Created by 郑业强 on 2018/10/27.
//  Copyright © 2018年 kk. All rights reserved.
//

#import "UIView+APPViewRequest.h"

static void *kUIView_APPViewRequest;

@implementation UIView (APPViewRequest)


#pragma mark - get
- (APPViewRequest *)afn_sharedManager {
    APPViewRequest *request = [APPViewRequest sharedManager];
    request.afn_frame = self.bounds;
    request.view = self;
    return request;
}


#pragma mark - 功能


#pragma mark - 请求
- (void)createRequest:(NSString *)url
               params:(NSDictionary * _Nullable )params
             complete:(AFNManagerCompleteBlock)complete {
    [self createRequest:url params:params progress:nil complete:complete];
}
- (void)createRequest:(NSString *)url
               params:(NSDictionary * _Nullable )params
             progress:(AFNManagerProgressBlock)progress
             complete:(AFNManagerCompleteBlock)complete {
    APPViewRequest *viewParameter = [self afn_request];
    NSLog(@"请求地址: %@", url);
    NSLog(@"请求参数: %@", params);

}


#pragma mark - runtime
- (void)setAfn_request:(APPViewRequest *)afn_request {
    objc_setAssociatedObject(self, &kUIView_APPViewRequest, afn_request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (APPViewRequest *)afn_request {
    if (!objc_getAssociatedObject(self, &kUIView_APPViewRequest)) {
        APPViewRequest *req = [self afn_sharedManager];
        [self setAfn_request:req];
    }
    return objc_getAssociatedObject(self, &kUIView_APPViewRequest);
}



@end
