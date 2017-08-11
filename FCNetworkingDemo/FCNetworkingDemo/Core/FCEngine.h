//
//  FCEngine.h
//  FCNetworking
//
//  Created by 付晨曦 on 2017/8/9.
//  Copyright © 2017年 floruit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FCRequest;

typedef void(^FCCompletionHandler)(id _Nullable responseObject, NSError * _Nullable error);

@interface FCEngine : NSObject

+ (instancetype)engine;

+ (instancetype)shareEngine;

- (void)sendRequest:(FCRequest *)request completionHandler:(nullable FCCompletionHandler)completionHandler;

- (nullable FCRequest *)cancelRequestByIdentifier:(NSString *)identifier;

- (nullable FCRequest *)getRequestByIdentifier:(NSString *)identifier;

@end


NS_ASSUME_NONNULL_END
