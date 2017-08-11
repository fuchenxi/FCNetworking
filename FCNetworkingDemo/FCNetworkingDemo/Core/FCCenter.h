//
//  FCCenter.h
//  FCNetworking
//
//  Created by 付晨曦 on 2017/8/9.
//  Copyright © 2017年 floruit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCConst.h"

NS_ASSUME_NONNULL_BEGIN

@class FCConfig, FCEngine;

@interface FCCenter : NSObject

+ (instancetype)defaultCenter;
/// 公共服务端地址
@property (nonatomic, copy, nullable) NSString *generalServer;
/// 公共请求参数
@property (nonatomic, strong, nullable, readonly) NSMutableDictionary <NSString *, id> *generalParameters;
/// 公共请求头
@property (nonatomic, strong, nullable, readonly) NSMutableDictionary <NSString *, NSString *> *generalHeaders;
/// 公共用户信息
@property (nonatomic, strong, nullable) NSDictionary *generalUserInfo;
/// 请求的回调执行线程
@property (nonatomic, strong, nullable) dispatch_queue_t callbackQueue;
/// 底层请求的引擎
@property (nonatomic, strong) FCEngine *engine;
/// 是否打印 log
@property (nonatomic, assign) BOOL consoleLog;

#pragma mark - Public Instance Methods for FCCenter
/// 全局网络配置
- (void)setupConfig:(void(^)(FCConfig *config))configBlock;
/// 自定义请求预处理
- (void)setRequestProcessBlock:(FCCenterRequestProcessBlock)block;
/// 自定义响应结果的处理逻辑 如果 `*error` 被赋值，则接下来会执行 failure block。
- (void)setResponseProcessBlock:(FCCenterResponseProcessBlock)block;
/// 配置或修改公共请求头
- (void)setGeneralHeaderValue:(nullable NSString *)value forField:(NSString *)field;
/// 配置或修改公共请求参数
- (void)setGeneralParameterValue:(nullable id)value forKey:(NSString *)key;

/// 发送请求
- (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock;

- (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                           success:(nullable FCSuccessBlock)successBlock;

- (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                           failure:(nullable FCFailureBlock)failureBlock;

- (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                           success:(nullable FCSuccessBlock)successBlock
                           failure:(nullable FCFailureBlock)failureBlock;

- (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                          finished:(nullable FCFinishedBlock)finishedBlock;

- (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                           success:(nullable FCSuccessBlock)successBlock
                           failure:(nullable FCFailureBlock)failureBlock
                          finished:(nullable FCFinishedBlock)finishedBlock;

- (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                          progress:(nullable FCProgressBlock)progressBlock
                           success:(nullable FCSuccessBlock)successBlock
                           failure:(nullable FCFailureBlock)failureBlock;

- (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                          progress:(nullable FCProgressBlock)progressBlock
                          finished:(nullable FCFinishedBlock)finishedBlock;

- (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                          progress:(nullable FCProgressBlock)progressBlock
                           success:(nullable FCSuccessBlock)successBlock
                           failure:(nullable FCFailureBlock)failureBlock
                          finished:(nullable FCFinishedBlock)finishedBlock;
/// 取消请求
- (void)cancelRequest:(NSString *)identifier;

- (void)cancelRequest:(NSString *)identifier cancel:(nullable FCCancelBlock)cancelBlock;
/// 获取请求
- (nullable FCRequest *)getRequest:(NSString *)identifier;

#pragma mark - Public Class Methods for XMCenter

+ (void)setupConfig:(void(^)(FCConfig *config))configBlock;

+ (void)setRequestProcessBlock:(FCCenterRequestProcessBlock)block;

+ (void)setResponseProcessBlock:(FCCenterResponseProcessBlock)block;

+ (void)setGeneralHeaderValue:(nullable NSString *)value forField:(NSString *)field;

+ (void)setGeneralParameterValue:(nullable id)value forKey:(NSString *)key;

+ (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock;

+ (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                           success:(nullable FCSuccessBlock)successBlock;

+ (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                           failure:(nullable FCFailureBlock)failureBlock;

+ (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                           success:(nullable FCSuccessBlock)successBlock
                           failure:(nullable FCFailureBlock)failureBlock;

+ (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                          finished:(nullable FCFinishedBlock)finishedBlock;

+ (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                           success:(nullable FCSuccessBlock)successBlock
                           failure:(nullable FCFailureBlock)failureBlock
                          finished:(nullable FCFinishedBlock)finishedBlock;

+ (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                          progress:(nullable FCProgressBlock)progressBlock
                           success:(nullable FCSuccessBlock)successBlock
                           failure:(nullable FCFailureBlock)failureBlock;

+ (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                          progress:(nullable FCProgressBlock)progressBlock
                          finished:(nullable FCFinishedBlock)finishedBlock;

+ (nullable NSString *)sendRequest:(nullable FCRequestConfigBlock)configBlock
                          progress:(nullable FCProgressBlock)progressBlock
                           success:(nullable FCSuccessBlock)successBlock
                           failure:(nullable FCFailureBlock)failureBlock
                          finished:(nullable FCFinishedBlock)finishedBlock;

+ (void)cancelRequest:(NSString *)identifier;

+ (void)cancelRequest:(NSString *)identifier cancel:(nullable FCCancelBlock)cancelBlock;

+ (nullable FCRequest *)getRequest:(NSString *)identifier;

@end


@interface FCConfig : NSObject

@property (nonatomic, copy, nullable) NSString *generalServer;

@property (nonatomic, strong, nullable) NSDictionary <NSString *, id> *generalParameters;

@property (nonatomic, strong, nullable) NSDictionary <NSString *, NSString *> *generalHeaders;

@property (nonatomic, strong, nullable) NSDictionary *generalUserInfo;

@property (nonatomic, strong, nullable) dispatch_queue_t callbackQueue;

@property (nonatomic, strong) FCEngine *engine;

@property (nonatomic, assign) BOOL consoleLog;

@end

NS_ASSUME_NONNULL_END
