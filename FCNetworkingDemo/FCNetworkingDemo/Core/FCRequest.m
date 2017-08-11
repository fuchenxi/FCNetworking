//
//  FCRequest.m
//  FCNetworking
//
//  Created by 付晨曦 on 2017/8/9.
//  Copyright © 2017年 floruit. All rights reserved.
//

#import "FCRequest.h"

@implementation FCRequest

+ (instancetype)request {
    
    return [[self alloc] init];
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        _requestType = kFCRequestTypeNormal;
        _httpMethod = kFCHTTPMethodTypePOST;
        _requestSerializerType = kFCRequestSerializerTypeRAW;
        _responseSerializerType = kFCResponseSerializerTypeJSON;
        _timeoutInterval = 30.0;
        _autoAlertMessage = NO;
        
        _useGeneralServer = YES;
        _useGeneralHeaders = YES;
        _useGeneralParameters = YES;
        
        _retryCount = 0;
    }
    return self;
}

- (void)cleanCallbackBlocks {
    
    _successBlock = nil;
    _failureBlock = nil;
    _finishedBlock = nil;
    _progressBlock = nil;
}

@end
