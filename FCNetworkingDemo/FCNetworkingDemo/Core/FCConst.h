//
//  FCConst.h
//  FCNetworking
//
//  Created by 付晨曦 on 2017/8/9.
//  Copyright © 2017年 floruit. All rights reserved.
//

#ifndef FCConst_h
#define FCConst_h

#define FC_SAFE_BLOCK(BlockName, ...) ({ !BlockName ? nil : BlockName(__VA_ARGS__); })
#define FCLock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define FCUnlock() dispatch_semaphore_signal(self->_lock)

NS_ASSUME_NONNULL_BEGIN

@class FCRequest;

typedef NS_ENUM(NSInteger, FCRequestType) {
    
    kFCRequestTypeNormal    = 0,
    kFCRequestTypeUpload    = 1,
    kFCRequestTypeDownload  = 2
};

typedef NS_ENUM(NSInteger, FCHTTPMethodType) {
    
    kFCHTTPMethodTypeGET    = 0,
    kFCHTTPMethodTypePOST   = 1,
    kFCHTTPMethodTypeHEAD   = 2,
    kFCHTTPMethodTypeDELETE = 3,
    kFCHTTPMethodTypePUT    = 4,
    kFCHTTPMethodTypePATCH  = 5
};

typedef NS_ENUM(NSInteger, FCRequestSerializerType) {
    
    kFCRequestSerializerTypeRAW     = 0,
    kFCRequestSerializerTypeJSON    = 1,
    kFCRequestSerializerTypePlist   = 2,
};

typedef NS_ENUM(NSInteger, FCResponseSerializerType) {
    
    kFCResponseSerializerTypeRAW     = 0,
    kFCResponseSerializerTypeJSON    = 1,
    kFCResponseSerializerTypePlist   = 2,
    kFCResponseSerializerTypeXML     = 3
};

typedef void(^FCRequestConfigBlock)(FCRequest *request);

typedef void(^FCProgressBlock)(NSProgress *progress);

typedef void(^FCSuccessBlock)(id _Nullable responseObject);
typedef void(^FCFailureBlock)(NSError  * _Nullable error);
typedef void(^FCFinishedBlock)(id _Nullable responseObject, NSError  * _Nullable error);
typedef void(^FCCancelBlock)(FCRequest *request);
typedef void (^FCCenterRequestProcessBlock)(FCRequest *request);
typedef void (^FCCenterResponseProcessBlock)(FCRequest *request, id _Nullable responseObject, NSError * _Nullable __autoreleasing *error);
NS_ASSUME_NONNULL_END


#endif /* FCConst_h */
