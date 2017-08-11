//
//  FCRequest.h
//  FCNetworking
//
//  Created by 付晨曦 on 2017/8/9.
//  Copyright © 2017年 floruit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface FCRequest : NSObject

+ (instancetype)request;

@property (nonatomic, copy, readonly) NSString *identifier;
/// 服务端地址
@property (nonatomic, copy, nullable) NSString *server;
/// 路径
@property (nonatomic, copy, nullable) NSString *api;
/// 域名 + 路径  优先级最高, 使用 url 会忽略 server 和 api
@property (nonatomic, copy, nullable) NSString *url;
/// 请求参数
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *parameters;
/// 请求头
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *headers;
/// 是否使用公共服务端地址
@property (nonatomic, assign) BOOL useGeneralServer;
/// 是否使用公共请求头
@property (nonatomic, assign) BOOL useGeneralHeaders;
/// 是否使用公共参数
@property (nonatomic, assign) BOOL useGeneralParameters;
/// 请求类型
@property (nonatomic, assign) FCRequestType requestType;
/// 请求方法
@property (nonatomic, assign) FCHTTPMethodType httpMethod;
/// 请求序列化类型
@property (nonatomic, assign) FCRequestSerializerType requestSerializerType;
/// 响应序列化类型
@property (nonatomic, assign) FCResponseSerializerType responseSerializerType;
/// 超时时长
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
/// 重试次数
@property (nonatomic, assign) NSUInteger retryCount;
/// 待实现
@property (nonatomic, assign, getter = isAutoAlertMessage) BOOL autoAlertMessage;
/// 请求用户信息
@property (nonatomic, strong, nullable) NSDictionary *userInfo;
/// 成功回调
@property (nonatomic, copy, readonly, nullable) FCSuccessBlock successBlock;
/// 失败回调
@property (nonatomic, copy, readonly, nullable) FCFailureBlock failureBlock;
/// 结束回调
@property (nonatomic, copy, readonly, nullable) FCFinishedBlock finishedBlock;
/// 进度回调  待实现
@property (nonatomic, copy, readonly, nullable) FCProgressBlock progressBlock;
/// 清除回调
- (void)cleanCallbackBlocks;

@end

NS_ASSUME_NONNULL_END
