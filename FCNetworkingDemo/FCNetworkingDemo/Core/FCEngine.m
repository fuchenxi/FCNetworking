//
//  FCEngine.m
//  FCNetworking
//
//  Created by 付晨曦 on 2017/8/9.
//  Copyright © 2017年 floruit. All rights reserved.
//

#import "FCEngine.h"
#import "FCRequest.h"
#import <AFNetworking.h>
#import <AFNetworkActivityIndicatorManager.h>
#import <objc/runtime.h>

static dispatch_queue_t fc_request_completion_callback_queue() {
    static dispatch_queue_t _fc_request_completion_callback_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fc_request_completion_callback_queue = dispatch_queue_create("fcnetworking.request.completion.callback.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return _fc_request_completion_callback_queue;
}


@implementation NSObject (BindingFCRequest)

static NSString * const kFCRequestBindingRequestKey = @"kFCRequestBindingRequestKey";

- (void)bindingRequest:(FCRequest *)request {
    
    objc_setAssociatedObject(self, (__bridge CFStringRef)(kFCRequestBindingRequestKey), request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FCRequest *)bindedRequest {
    
    return objc_getAssociatedObject(self, (__bridge CFStringRef)(kFCRequestBindingRequestKey));
}

@end

@interface FCEngine () {

    dispatch_semaphore_t _lock;
}

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) AFHTTPSessionManager *securitySessionManager;

@property (nonatomic, strong) AFHTTPRequestSerializer *afHTTPRequestSerializer;
@property (nonatomic, strong) AFJSONRequestSerializer *afJSONRequestSerializer;
@property (nonatomic, strong) AFPropertyListRequestSerializer *afPListRequestSerializer;

@property (nonatomic, strong) AFHTTPResponseSerializer *afHTTPResponseSerializer;
@property (nonatomic, strong) AFJSONResponseSerializer *afJSONResponseSerializer;
@property (nonatomic, strong) AFXMLParserResponseSerializer *afXMLResponseSerializer;
@property (nonatomic, strong) AFPropertyListResponseSerializer *afPListResponseSerializer;

@end

@implementation FCEngine

+ (void)load {
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)dealloc {
    
    if (_sessionManager) {
        [_sessionManager invalidateSessionCancelingTasks:YES];
    }
    if (_securitySessionManager) {
        [_securitySessionManager invalidateSessionCancelingTasks:YES];
    }
}

+ (instancetype)engine {
    return [[self alloc] init];
}

+ (instancetype)shareEngine {
    
    static FCEngine *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self engine];
    });
    return instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        _lock = dispatch_semaphore_create(1);
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

#pragma mark -
#pragma mark - Public Methods
- (void)sendRequest:(FCRequest *)request completionHandler:(FCCompletionHandler)completionHandler {
    
    if (request.requestType == kFCRequestTypeNormal) {
        
        [self fc_dataTaskWithRequest:request completionHandler:completionHandler];
    }
}

- (FCRequest *)cancelRequestByIdentifier:(NSString *)identifier {
    
    if (identifier.length == 0) return nil;
    
    FCLock();
    NSArray *tasks = nil;
    if ([identifier hasPrefix:@"+"]) {
        tasks = self.sessionManager.tasks;
    } else if ([identifier hasPrefix:@"-"]) {
        tasks = self.securitySessionManager.tasks;
    }
    
    __block FCRequest *request = nil;
    [tasks enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSLog(@"%@", task.bindedRequest);
        if ([task.bindedRequest.identifier isEqualToString:identifier]) {
            request = task.bindedRequest;
            [task cancel];
            *stop = YES;
        }
    }];
    FCUnlock();
    return request;
}

- (FCRequest *)getRequestByIdentifier:(NSString *)identifier {
    
    if (identifier.length == 0) return nil;
    
    FCLock();
    NSArray *tasks = nil;
    if ([identifier hasPrefix:@"+"]) {
        tasks = self.sessionManager.tasks;
    } else if ([identifier hasPrefix:@"-"]) {
        tasks = self.securitySessionManager.tasks;
    }
    
    __block FCRequest *request = nil;
    [tasks enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([[task bindedRequest].identifier isEqualToString:identifier]) {
            request = [task bindedRequest];
            *stop = YES;
        }
    }];
    FCUnlock();
    return request;
}

- (void)fc_dataTaskWithRequest:(FCRequest *)request completionHandler:(FCCompletionHandler)completionHandler {
    
    NSString *httpMethod = nil;
    static dispatch_once_t onceToken;
    static NSArray *httpMethods = nil;
    dispatch_once(&onceToken, ^{
        
        httpMethods = @[@"GET", @"POST", @"HEAD", @"DELETE", @"PUT", @"PATCH"];
    });
    if (request.httpMethod >= 0 && request.httpMethod < httpMethods.count) {
        
        httpMethod = httpMethods[request.httpMethod];
    }
    NSAssert(httpMethod.length > 0, @"The HTTP method not found.");
    
    AFHTTPSessionManager *sessionManager = [self fc_getSessionManager];
    AFHTTPRequestSerializer *requestSerializer = [self fc_getRequestSerializer:request];
    NSError *serializationError = nil;
    
    NSMutableURLRequest *urlRequest = [requestSerializer requestWithMethod:httpMethod
                                                                 URLString:request.url
                                                                parameters:request.parameters
                                                                     error:&serializationError];
    if (serializationError) {
        
        if (completionHandler) {
            
            dispatch_async(fc_request_completion_callback_queue(), ^{
                
                completionHandler(nil, serializationError);
            });
        }
    }
    
    [self fc_processURLRequest:urlRequest byFCRequest:request];
    
    NSURLSessionDataTask *dataTask = nil;
    
    __weak typeof(self) weakSelf = self;
    dataTask = [sessionManager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
     
        __strong typeof(weakSelf)strongSelf = weakSelf;

        [strongSelf fc_processResponse:response
                        responseObject:responseObject
                                 error:error
                               request:request
                     completionHandler:completionHandler];
    }];
    [self fc_setIdentifierForRequest:request taskIdentifier:dataTask.taskIdentifier sessionManager:sessionManager];
    [dataTask bindingRequest:request];
    [dataTask resume];
}

/// 预处理请求
- (void)fc_processURLRequest:(NSMutableURLRequest *)urlRequest byFCRequest:(FCRequest *)request {
    
    if (request.headers.count > 0) {
        
        [request.headers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
           
            [urlRequest setValue:obj forHTTPHeaderField:key];
        }];
    }
    urlRequest.timeoutInterval = request.timeoutInterval;
}

/// 预处理响应
- (void)fc_processResponse:(NSURLResponse *)response
            responseObject:(id)responseObject
                     error:(NSError *)error
                   request:(FCRequest *)request
         completionHandler:(FCCompletionHandler)completionHandler {
    
    NSError *serializationError = nil;
    if (request.responseSerializerType != kFCResponseSerializerTypeRAW) {
        
        AFHTTPResponseSerializer *responseSerializer = [self fc_getResponseSerializer:request];
        responseObject = [responseSerializer responseObjectForResponse:response data:responseObject error:&serializationError];
    }
    if (completionHandler) {
        
        if (serializationError) {
            
            completionHandler(nil, serializationError);
        } else {
            completionHandler(responseObject, error);
        }
    }
}

- (void)fc_setIdentifierForRequest:(FCRequest *)request taskIdentifier:(NSUInteger)taskIdentifier sessionManager:(AFHTTPSessionManager *)sessionManager {
    
    NSString *identifier = nil;
    if (sessionManager == self.sessionManager) {
        
        identifier = [NSString stringWithFormat:@"+%lu", (unsigned long)taskIdentifier];
    }
    [request setValue:identifier forKey:@"_identifier"];
}

- (AFHTTPSessionManager *)fc_getSessionManager {
    
    return self.sessionManager;
}

- (AFHTTPRequestSerializer *)fc_getRequestSerializer:(FCRequest *)request {
    
    if (request.requestSerializerType == kFCRequestSerializerTypeRAW) {
        return self.afHTTPRequestSerializer;
    } else if(request.requestSerializerType == kFCRequestSerializerTypeJSON) {
        return self.afJSONRequestSerializer;
    } else if (request.requestSerializerType == kFCRequestSerializerTypePlist) {
        return self.afPListRequestSerializer;
    } else {
        NSAssert(NO, @"Unknown request serializer type.");
        return nil;
    }
}

- (AFHTTPResponseSerializer *)fc_getResponseSerializer:(FCRequest *)request {
    
    if (request.responseSerializerType == kFCResponseSerializerTypeRAW) {
        return self.afHTTPResponseSerializer;
    } else if (request.responseSerializerType == kFCResponseSerializerTypeJSON) {
        return self.afJSONResponseSerializer;
    } else if (request.responseSerializerType == kFCResponseSerializerTypePlist) {
        return self.afPListResponseSerializer;
    } else if (request.responseSerializerType == kFCResponseSerializerTypeXML) {
        return self.afXMLResponseSerializer;
    } else {
        NSAssert(NO, @"Unknown response serializer type.");
        return nil;
    }
}

- (NSInteger)reachabilityStatus {
    
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}

#pragma mark -
#pragma mark - Accessor
- (AFHTTPSessionManager *)sessionManager {
    
    if (!_sessionManager) {
        
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer = self.afHTTPRequestSerializer;
        _sessionManager.responseSerializer = self.afHTTPResponseSerializer;
        _sessionManager.operationQueue.maxConcurrentOperationCount = 5;
        _sessionManager.completionQueue = fc_request_completion_callback_queue();
    }
    return _sessionManager;
}

- (AFHTTPSessionManager *)securitySessionManager {
    
    if (!_securitySessionManager) {
        
        _securitySessionManager = [AFHTTPSessionManager manager];
        _securitySessionManager.requestSerializer = self.afHTTPRequestSerializer;
        _securitySessionManager.responseSerializer = self.afHTTPResponseSerializer;
        _securitySessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        _securitySessionManager.operationQueue.maxConcurrentOperationCount = 5;
        _securitySessionManager.completionQueue = fc_request_completion_callback_queue();
    }
    return _securitySessionManager;
}

- (AFHTTPRequestSerializer *)afHTTPRequestSerializer {
    
    if (!_afHTTPRequestSerializer) {
        
        _afHTTPRequestSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _afHTTPRequestSerializer;
}

- (AFJSONRequestSerializer *)afJSONRequestSerializer {
    
    if (!_afJSONRequestSerializer) {
        
        _afJSONRequestSerializer = [AFJSONRequestSerializer serializer];
    }
    return _afJSONRequestSerializer;
}

- (AFPropertyListRequestSerializer *)afPListRequestSerializer {
    
    if (!_afPListRequestSerializer) {
        
        _afPListRequestSerializer = [AFPropertyListRequestSerializer serializer];
    }
    return _afPListRequestSerializer;
}

- (AFHTTPResponseSerializer *)afHTTPResponseSerializer {
    
    if (!_afHTTPResponseSerializer) {
        
        _afHTTPResponseSerializer = [AFHTTPResponseSerializer serializer];
//        _afHTTPResponseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    }
    return _afHTTPResponseSerializer;
}

- (AFJSONResponseSerializer *)afJSONResponseSerializer {
    
    if (!_afJSONResponseSerializer) {
        
        _afJSONResponseSerializer = [AFJSONResponseSerializer serializer];
        _afJSONResponseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    }
    return _afJSONResponseSerializer;
}

- (AFXMLParserResponseSerializer *)afXMLResponseSerializer {
    
    if (!_afXMLResponseSerializer) {
        
        _afXMLResponseSerializer = [AFXMLParserResponseSerializer serializer];
    }
    return _afXMLResponseSerializer;
}

- (AFPropertyListResponseSerializer *)afPListResponseSerializer {
    
    if (!_afPListResponseSerializer) {
        
        _afPListResponseSerializer = [AFPropertyListResponseSerializer serializer];
    }
    return _afPListResponseSerializer;
}

@end
