//
//  FCCenter.m
//  FCNetworking
//
//  Created by 付晨曦 on 2017/8/9.
//  Copyright © 2017年 floruit. All rights reserved.
//

#import "FCCenter.h"
#import "FCRequest.h"
#import "FCEngine.h"

@interface FCCenter () {
    
    dispatch_semaphore_t _lock;
}

@property (nonatomic, strong, readwrite) NSMutableDictionary <NSString *, id> *generalParameters;

@property (nonatomic, strong, readwrite) NSMutableDictionary <NSString *, NSString *> *generalHeaders;

@property (nonatomic, copy) FCCenterRequestProcessBlock requestProcessHandler;

@property (nonatomic, copy) FCCenterResponseProcessBlock responseProcessHandler;

@property (nonatomic, copy) FCCenterRequestEncryptBlock requestEncryptHandler;

@end

@implementation FCCenter

+ (instancetype)defaultCenter {
    
    static FCCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        _lock = dispatch_semaphore_create(1);
        _engine = [FCEngine shareEngine];
    }
    return self;
}

#pragma mark - Public Instance Methods
- (void)setupConfig:(void (^)(FCConfig * _Nonnull))configBlock {
    
    FCConfig *config = [[FCConfig alloc] init];
    config.consoleLog = NO;
    FC_SAFE_BLOCK(configBlock, config);
    if (config.generalServer.length > 0) {
        self.generalServer = config.generalServer;
    }
    if (config.generalParameters.count > 0) {
        [self.generalParameters addEntriesFromDictionary:config.generalParameters];
    }
    if (config.generalHeaders.count > 0) {
        [self.generalHeaders addEntriesFromDictionary:config.generalHeaders];
    }
    if (config.callbackQueue != NULL) {
        self.callbackQueue = config.callbackQueue;
    }
    if (config.generalUserInfo.count) {
        self.generalUserInfo = config.generalUserInfo;
    }
    if (config.engine) {
        self.engine = config.engine;
    }
    self.consoleLog = config.consoleLog;
}

- (void)setRequestProcessBlock:(FCCenterRequestProcessBlock)block {
    
    self.requestProcessHandler = block;
}

- (void)setResponseProcessBlock:(FCCenterResponseProcessBlock)block {
    
    self.responseProcessHandler = block;
}

- (void)setRequestEncryptBlock:(FCCenterRequestEncryptBlock)block {
    
    self.requestEncryptHandler = block;
}

- (void)setGeneralHeaderValue:(NSString *)value forField:(NSString *)field {
    
    [self.generalHeaders setValue:value forKey:field];
}

- (void)setGeneralParameterValue:(id)value forKey:(NSString *)key {
    
    [self.generalParameters setValue:value forKey:key];
}

#pragma mark -
- (NSString *)sendRequest:(FCRequestConfigBlock)configBlock {
    
    return [self sendRequest:configBlock progress:nil success:nil failure:nil finished:nil];
}

- (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                           success:(FCSuccessBlock)successBlock {
    
    return [self sendRequest:configBlock progress:nil success:successBlock failure:nil finished:nil];
}

- (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                           failure:(FCFailureBlock)failureBlock {
    
    return [self sendRequest:configBlock progress:nil success:nil failure:failureBlock finished:nil];
}

- (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                           success:(FCSuccessBlock)successBlock
                           failure:(FCFailureBlock)failureBlock {
    
    return [self sendRequest:configBlock progress:nil success:successBlock failure:failureBlock finished:nil];
}

- (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                          finished:(FCFinishedBlock)finishedBlock {
    
    return [self sendRequest:configBlock progress:nil success:nil failure:nil finished:finishedBlock];
}

- (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                           success:(FCSuccessBlock)successBlock
                           failure:(FCFailureBlock)failureBlock
                          finished:(FCFinishedBlock)finishedBlock {
    
    return [self sendRequest:configBlock progress:nil success:successBlock failure:failureBlock finished:finishedBlock];
}

- (NSString *)senFCequest:(FCRequestConfigBlock)configBlock
                          progress:(FCProgressBlock)progressBlock
                           success:(FCSuccessBlock)successBlock
                           failure:(FCFailureBlock)failureBlock {
    
    return [self sendRequest:configBlock progress:progressBlock success:successBlock failure:failureBlock finished:nil];
}

- (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                          progress:(FCProgressBlock)progressBlock
                          finished:(FCFinishedBlock)finishedBlock {
    
    return [self sendRequest:configBlock progress:progressBlock success:nil failure:nil finished:finishedBlock];
}

- (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                 progress:(FCProgressBlock)progressBlock
                  success:(FCSuccessBlock)successBlock
                  failure:(FCFailureBlock)failureBlock
                 finished:(FCFinishedBlock)finishedBlock {
    
    FCRequest *request = [FCRequest request];
    FC_SAFE_BLOCK(self.requestProcessHandler, request);
    FC_SAFE_BLOCK(configBlock, request);
    [self fc_processRequest:request progress:progressBlock success:successBlock failure:failureBlock finished:finishedBlock];
    FC_SAFE_BLOCK(self.requestEncryptHandler, request);
    [self fc_sendRequest:request];
    return request.identifier;
}

- (void)cancelRequest:(NSString *)identifier {
    
    [self cancelRequest:identifier cancel:nil];
}

- (void)cancelRequest:(NSString *)identifier cancel:(FCCancelBlock)cancelBlock {
    
    FCRequest *request = nil;
    if (identifier.length > 0) {
        request = [self.engine cancelRequestByIdentifier:identifier];
    }
    FC_SAFE_BLOCK(cancelBlock, request);
}

- (FCRequest *)getRequest:(NSString *)identifier {
    
    FCRequest *request = nil;
    if (identifier.length > 0) {
        request = [self.engine getRequestByIdentifier:identifier];
    }
    return request;
}

#pragma mark - 
#pragma mark - Public Class Methods
+ (void)setupConfig:(void (^)(FCConfig * _Nonnull))configBlock {
 
    [[self defaultCenter] setupConfig:configBlock];
}

+ (void)setRequestProcessBlock:(FCCenterRequestProcessBlock)block {
    
    [[self defaultCenter] setRequestProcessBlock:block];
}

+ (void)setResponseProcessBlock:(FCCenterResponseProcessBlock)block {
    
    [[self defaultCenter] setResponseProcessBlock:block];
}

+ (void)setRequestEncryptBlock:(FCCenterRequestEncryptBlock)block {
    
    [[self defaultCenter] setRequestEncryptBlock:block];
}

+ (void)setGeneralHeaderValue:(NSString *)value forField:(NSString *)field {
    
    [[self defaultCenter] setGeneralHeaderValue:value forField:field];
}

+ (void)setGeneralParameterValue:(id)value forKey:(NSString *)key {
    
    [[self defaultCenter] setGeneralParameterValue:value forKey:key];
}

#pragma mark -
+ (NSString *)sendRequest:(FCRequestConfigBlock)configBlock {
    
    return [[self defaultCenter] sendRequest:configBlock];
}

+ (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                  success:(FCSuccessBlock)successBlock {
    
    return [[self defaultCenter] sendRequest:configBlock success:successBlock];
}

+ (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                  failure:(FCFailureBlock)failureBlock {
    
    return [[self defaultCenter] sendRequest:configBlock failure:failureBlock];
}

+ (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                  success:(FCSuccessBlock)successBlock
                  failure:(FCFailureBlock)failureBlock {
    
    return [[self defaultCenter] sendRequest:configBlock success:successBlock failure:failureBlock];
}

+ (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                 finished:(FCFinishedBlock)finishedBlock {
    
    return [[self defaultCenter] sendRequest:configBlock finished:finishedBlock];
}

+ (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                  success:(FCSuccessBlock)successBlock
                  failure:(FCFailureBlock)failureBlock
                 finished:(FCFinishedBlock)finishedBlock {
    
    return [[self defaultCenter] sendRequest:configBlock success:successBlock failure:failureBlock finished:finishedBlock];
}

+ (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                 progress:(FCProgressBlock)progressBlock
                  success:(FCSuccessBlock)successBlock
                  failure:(FCFailureBlock)failureBlock {
    
    return [[self defaultCenter] sendRequest:configBlock progress:progressBlock success:successBlock failure:failureBlock];
}

+ (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                 progress:(FCProgressBlock)progressBlock
                 finished:(FCFinishedBlock)finishedBlock {
    
    return [[self defaultCenter] sendRequest:configBlock progress:progressBlock finished:finishedBlock];
}

+ (NSString *)sendRequest:(FCRequestConfigBlock)configBlock
                 progress:(FCProgressBlock)progressBlock
                  success:(FCSuccessBlock)successBlock
                  failure:(FCFailureBlock)failureBlock
                 finished:(FCFinishedBlock)finishedBlock {
    
    return [[self defaultCenter] sendRequest:configBlock progress:progressBlock success:successBlock failure:failureBlock finished:finishedBlock];
}

+ (void)cancelRequest:(NSString *)identifier {
    
    [[self defaultCenter] cancelRequest:identifier];
}

+ (void)cancelRequest:(NSString *)identifier cancel:(FCCancelBlock)cancelBlock {
    
    [[self defaultCenter] cancelRequest:identifier cancel:cancelBlock];
}

+ (FCRequest *)getRequest:(NSString *)identifier {
    
    return [[self defaultCenter] getRequest:identifier];
}

#pragma mark -
#pragma mark - Private Methods for FCCenter
- (void)fc_processRequest:(FCRequest *)request
                 progress:(FCProgressBlock)progressBlock
                  success:(FCSuccessBlock)successBlock
                  failure:(FCFailureBlock)failureBlock
                 finished:(FCFinishedBlock)finishedBlock {
    
    if (successBlock) {
        [request setValue:successBlock forKey:@"_successBlock"];
    }
    
    if (failureBlock) {
        [request setValue:failureBlock forKey:@"_failureBlock"];
    }
    
    if (finishedBlock) {
        [request setValue:finishedBlock forKey:@"_finishedBlock"];
    }
    
    if (progressBlock && request.requestType != kFCRequestTypeNormal) {
        [request setValue:progressBlock forKey:@"_progressBlock"];
    }
    
    if (!request.userInfo && self.generalUserInfo) {
        
        request.userInfo = self.generalUserInfo;
    }
    
    if (request.useGeneralParameters && self.generalParameters.count > 0) {
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters addEntriesFromDictionary:self.generalParameters];
        if (request.parameters.count > 0) {
            [parameters addEntriesFromDictionary:request.parameters];
        }
        request.parameters = parameters;
    }
    
    if (request.useGeneralHeaders && self.generalHeaders.count > 0) {
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters addEntriesFromDictionary:self.generalHeaders];
        if (request.headers.count > 0) {
            [parameters addEntriesFromDictionary:request.headers];
        }
        request.headers = parameters;
    }
    
    if (request.url.length == 0) {
        
        if (request.server.length == 0 && request.useGeneralServer && self.generalServer.length > 0) {
            request.server = self.generalServer;
        }
        if (request.api.length > 0) {
            NSURL *baseURL = [NSURL URLWithString:request.server];
            if ([[baseURL path] length] > 0 && ![[baseURL absoluteString] hasSuffix:@"/"]) {
                baseURL = [baseURL URLByAppendingPathComponent:@""];
            }
            request.url = [[NSURL URLWithString:request.api relativeToURL:baseURL] absoluteString];
        } else {
            request.url = request.server;
        }
    }
    NSAssert(request.url.length > 0, @"The request url can't be null.");
}

- (void)fc_sendRequest:(FCRequest *)request {
    
    if (self.consoleLog) {
        
        NSLog(@"\n============ [FCRequest Info] ============\nrequest url: %@ \nrequest headers: \n%@ \nrequest parameters: \n%@ \n==========================================\n", request.url, request.headers, request.parameters);
    }
    
    [self.engine sendRequest:request completionHandler:^(id  _Nullable responseObject, NSError * _Nullable error) {
       
        if (error) {
            [self fc_failureWithError:error forRequest:request];
        } else {
            [self fc_successWithResponse:responseObject forRequest:request];
        }
    }];
}

#pragma mark - 
#pragma mark - Process CompletionHandler
- (void)fc_successWithResponse:(id)responseObject forRequest:(FCRequest *)request {
    
    NSError *processError = nil;
    FC_SAFE_BLOCK(self.responseProcessHandler, request, responseObject, &processError);
    if (processError) {
        
        [self fc_failureWithError:processError forRequest:request];
        return;
    }
    
    if (self.consoleLog) {
        if (request.requestType == kFCRequestTypeDownload) {
            NSLog(@"\n============ [FCResponse Data] ===========\nrequest download url: %@\nresponse data: %@\n==========================================\n", request.url, responseObject);
        } else {
            if (request.responseSerializerType == kFCResponseSerializerTypeRAW) {
                NSLog(@"\n============ [FCResponse Data] ===========\nrequest url: %@ \nresponse data: \n%@\n==========================================\n", request.url, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            } else {
                NSLog(@"\n============ [FCResponse Data] ===========\nrequest url: %@ \nresponse data: \n%@\n==========================================\n", request.url, responseObject);
            }
        }
    }

    if (self.callbackQueue) {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(self.callbackQueue, ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf fc_execureSuccessBlockWithResponse:responseObject forRequest:request];
        });
    } else {
        
        [self fc_execureSuccessBlockWithResponse:responseObject forRequest:request];
    }
}

- (void)fc_failureWithError:(NSError *)error forRequest:(FCRequest *)request {
    
    if (self.consoleLog) {
        NSLog(@"\n=========== [FCResponse Error] ===========\nrequest url: %@ \nerror info: \n%@\n==========================================\n", request.url, error);
    }
    
    if (request.retryCount > 0) {
        request.retryCount --;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self fc_sendRequest:request];
        });
        return;
    }
    
    if (self.callbackQueue) {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(self.callbackQueue, ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf fc_execureFailureBlockWithError:error forRequest:request];
        });
    } else {
        
        [self fc_execureFailureBlockWithError:error forRequest:request];
    }
}

#pragma mark - 
#pragma mark - ExecureBlock
- (void)fc_execureSuccessBlockWithResponse:(id)responseObject forRequest:(FCRequest *)request {
    
    FC_SAFE_BLOCK(request.successBlock, responseObject);
    FC_SAFE_BLOCK(request.finishedBlock, responseObject, nil);
    [request cleanCallbackBlocks];
}


- (void)fc_execureFailureBlockWithError:(id)error forRequest:(FCRequest *)request {
    
    FC_SAFE_BLOCK(request.failureBlock, error);
    FC_SAFE_BLOCK(request.finishedBlock, nil, error);
    [request cleanCallbackBlocks];
}

#pragma mark -
#pragma mark - Accessor
- (NSMutableDictionary<NSString *, id> *)generalParameters {
    if (!_generalParameters) {
        _generalParameters = [NSMutableDictionary dictionary];
    }
    return _generalParameters;
}

- (NSMutableDictionary<NSString *, NSString *> *)generalHeaders {
    if (!_generalHeaders) {
        _generalHeaders = [NSMutableDictionary dictionary];
    }
    return _generalHeaders;
}

@end


@implementation FCConfig

@end
