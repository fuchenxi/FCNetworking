//
//  FCNetworkingDemoTests.m
//  FCNetworkingDemoTests
//
//  Created by 付晨曦 on 2017/8/11.
//  Copyright © 2017年 fuchenxi. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FCNetworking.h"

@interface FCNetworkingDemoTests : XCTestCase


@property (nonatomic, assign) NSTimeInterval networkTimeout;


@end

@implementation FCNetworkingDemoTests

- (void)setUp {
    
    [super setUp];
    
    self.networkTimeout = 20.0;
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [FCCenter setupConfig:^(FCConfig * _Nonnull config) {
        
        config.generalServer = @"http://httpbin.org/";
        config.generalParameters = @{@"Global_Parameters_Key" : @"Global_Parameters_Value"};
        config.generalHeaders = @{@"Global_Headers_Key" : @"Global_Headers_Value"};
        config.consoleLog = YES;
    }];
    
    [FCCenter setRequestProcessBlock:^(FCRequest * _Nonnull request) {
       
        request.timeoutInterval = 20.0f;
    }];
}

- (void)testGetRequest {
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTestExpectation *expectation = [self expectationWithDescription:@"TestGetRequest should succeed."];
    
    [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
        
        request.api = @"get";
        request.httpMethod = kFCHTTPMethodTypeGET;
        request.parameters = @{@"test" : @"testGetRequest",
                               @"key" : @"value"};
        request.timeoutInterval = 20;
        request.retryCount = 2;
        
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertNotNil(responseObject);
        XCTAssertNil(error);
        XCTAssertTrue([responseObject[@"args"][@"test"] isEqualToString: @"testGetRequest"]);
        XCTAssertTrue([responseObject[@"args"][@"key"] isEqualToString:@"value"]);
        XCTAssertTrue([responseObject[@"args"][@"Global_Parameters_Key"] isEqualToString: @"Global_Parameters_Value"]);
        XCTAssertTrue([responseObject[@"headers"][@"Global-Headers-Key"] isEqualToString:@"Global_Headers_Value"]);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithCommonTimeout];
}

- (void)testPostRequestWithForm {
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTestExpectation *expectation = [self expectationWithDescription:@"TestPostRequestWithForm should succeed."];
    
    [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
        
        request.api = @"post";
        request.httpMethod = kFCHTTPMethodTypePOST;
        request.parameters = @{@"test" : @"testPostRequestWithForm"};
        request.timeoutInterval = 20;
        request.retryCount = 2;
        request.requestSerializerType = kFCRequestSerializerTypeRAW;
        request.responseSerializerType = kFCResponseSerializerTypeJSON;
        
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertNotNil(responseObject);
        XCTAssertNil(error);
        XCTAssertTrue([responseObject[@"form"][@"Global_Parameters_Key"] isEqualToString: @"Global_Parameters_Value"]);
        XCTAssertTrue([responseObject[@"form"][@"test"] isEqualToString:@"testPostRequestWithForm"]);
        XCTAssertTrue([responseObject[@"headers"][@"Global-Headers-Key"] isEqualToString:@"Global_Headers_Value"]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithCommonTimeout];
}

- (void)testPostWithJson {
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTestExpectation *expectation = [self expectationWithDescription:@"TestPostWithJson should succeed."];
    
    [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
        
        request.server = @"https://httpbin.org/";
        request.api = @"post";
        request.httpMethod = kFCHTTPMethodTypePOST;
        request.parameters = @{@"test" : @"testPostWithJson",
                               @"key" : @"value"};
        request.timeoutInterval = 20;
        request.retryCount = 2;
        request.requestSerializerType = kFCRequestSerializerTypeJSON;
        request.responseSerializerType = kFCResponseSerializerTypeJSON;
        
    } success:^(id  _Nullable responseObject) {
        
        XCTAssertNotNil(responseObject);
        XCTAssertTrue([responseObject[@"data"] isEqualToString:@"{\"Global_Parameters_Key\":\"Global_Parameters_Value\",\"key\":\"value\",\"test\":\"testPostWithJson\"}"]);
        XCTAssertTrue([responseObject[@"json"][@"test"] isEqualToString:@"testPostWithJson"]);
        XCTAssertTrue([responseObject[@"json"][@"key"] isEqualToString:@"value"]);
        XCTAssertTrue([responseObject[@"json"][@"Global_Parameters_Key"] isEqualToString:@"Global_Parameters_Value"]);
        XCTAssertTrue([responseObject[@"headers"][@"Global-Headers-Key"] isEqualToString:@"Global_Headers_Value"]);
        
    } failure:^(NSError * _Nullable error) {
        
        XCTAssertNil(error);
        
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertNotNil(responseObject);
        XCTAssertNil(error);
        XCTAssertTrue([responseObject[@"data"] isEqualToString:@"{\"Global_Parameters_Key\":\"Global_Parameters_Value\",\"key\":\"value\",\"test\":\"testPostWithJson\"}"]);
        XCTAssertTrue([responseObject[@"json"][@"test"] isEqualToString:@"testPostWithJson"]);
        XCTAssertTrue([responseObject[@"json"][@"key"] isEqualToString:@"value"]);
        XCTAssertTrue([responseObject[@"json"][@"Global_Parameters_Key"] isEqualToString:@"Global_Parameters_Value"]);
        XCTAssertTrue([responseObject[@"headers"][@"Global-Headers-Key"] isEqualToString:@"Global_Headers_Value"]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithCommonTimeout];
}


- (void)testPostWithPlist {
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTestExpectation *expectation = [self expectationWithDescription:@"TestPostWithPlist should succeed."];
    
    [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
        
        request.api = @"post";
        request.httpMethod = kFCHTTPMethodTypePOST;
        request.parameters = @{@"test" : @"testPostWithPlist",
                               @"key1" : @"value1",
                               @"key2" : @"value2"};
        
        request.headers = @{@"header_key" : @"header_value"};
        
        request.timeoutInterval = 20;
        request.retryCount = 2;
        request.requestSerializerType = kFCRequestSerializerTypePlist;
        
    } success:^(id  _Nullable responseObject) {
        
        XCTAssertTrue([responseObject[@"headers"][@"Global-Headers-Key"] isEqualToString:@"Global_Headers_Value"]);
        XCTAssertTrue([responseObject[@"headers"][@"Header-Key"] isEqualToString:@"header_value"]);
        XCTAssertTrue([responseObject[@"data"] isEqualToString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>Global_Parameters_Key</key>\n\t<string>Global_Parameters_Value</string>\n\t<key>key1</key>\n\t<string>value1</string>\n\t<key>key2</key>\n\t<string>value2</string>\n\t<key>test</key>\n\t<string>testPostWithPlist</string>\n</dict>\n</plist>\n"]);
        XCTAssertNotNil(responseObject);
        
    } failure:^(NSError * _Nullable error) {
        
        XCTAssertNil(error);
        
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertNotNil(responseObject);
        XCTAssertNil(error);
        XCTAssertTrue([responseObject[@"headers"][@"Global-Headers-Key"] isEqualToString:@"Global_Headers_Value"]);
        XCTAssertTrue([responseObject[@"headers"][@"Header-Key"] isEqualToString:@"header_value"]);
        XCTAssertTrue([responseObject[@"data"] isEqualToString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n\t<key>Global_Parameters_Key</key>\n\t<string>Global_Parameters_Value</string>\n\t<key>key1</key>\n\t<string>value1</string>\n\t<key>key2</key>\n\t<string>value2</string>\n\t<key>test</key>\n\t<string>testPostWithPlist</string>\n</dict>\n</plist>\n"]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithCommonTimeout];
}

- (void)testResponseWithRaw {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"TestResponseWithRaw should succeed."];
    
    [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
        
        request.server = @"https://httpbin.org/";
        request.api = @"html";
        request.httpMethod = kFCHTTPMethodTypeGET;
        request.responseSerializerType = kFCResponseSerializerTypeRAW;
        
    } success:^(id  _Nullable responseObject) {
        
        XCTAssertNotNil(responseObject);
        
    } failure:^(NSError * _Nullable error) {
        
        XCTAssertNil(error);
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertNotNil(responseObject);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithCommonTimeout];
}

- (void)testResponseWithJson {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testResponseWithJson should succeed."];
    
    [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
        
        request.server = @"https://httpbin.org/";
        request.api = @"post";
        request.parameters = @{@"key1" : @"value1", @"key2" : @"value2"};
        request.httpMethod = kFCHTTPMethodTypePOST;
        request.useGeneralHeaders = NO;
        request.useGeneralParameters = NO;
        request.responseSerializerType = kFCResponseSerializerTypeJSON;
        
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertNotNil(responseObject);
        XCTAssertTrue([responseObject[@"form"][@"key1"] isEqualToString:@"value1"]);
        XCTAssertTrue([responseObject[@"form"][@"key2"] isEqualToString:@"value2"]);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithCommonTimeout];
}

- (void)testResponseWithXML {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testResponseWithXML should succeed."];
    
    [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
        
        request.server = @"https://httpbin.org/";
        request.api = @"xml";
        request.httpMethod = kFCHTTPMethodTypeGET;
        request.responseSerializerType = kFCResponseSerializerTypeXML;
        
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertTrue([responseObject isKindOfClass:[NSXMLParser class]]);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithCommonTimeout];
}

- (void)testHeadRequest {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"TestHeadRequest should succeed"];
    
    [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
      
        request.url = @"https://httpbin.org/get";
        request.httpMethod = kFCHTTPMethodTypeHEAD;
        request.useGeneralHeaders = NO;
        request.useGeneralParameters = NO;
        
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithCommonTimeout];
}

- (void)testPutRequest {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"TestPutRequest should succeed"];
    
    [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
        
        request.url = @"https://httpbin.org/put";
        request.parameters = @{@"key1" : @"value1", @"key2" : @"value2"};
        request.httpMethod = kFCHTTPMethodTypePUT;
        request.useGeneralHeaders = NO;
        request.useGeneralParameters = NO;
        
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertTrue([responseObject[@"form"][@"key1"] isEqualToString:@"value1"]);
        XCTAssertTrue([responseObject[@"form"][@"key2"] isEqualToString:@"value2"]);
        XCTAssertNotNil(responseObject);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithCommonTimeout];
}

- (void)testDeleteRequest {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"TestDeleteRequest should succeed"];
    
    [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
        
        request.url = @"https://httpbin.org/delete";
        request.parameters = @{@"key1" : @"value1", @"key2" : @"value2"};
        request.httpMethod = kFCHTTPMethodTypeDELETE;
        request.useGeneralHeaders = NO;
        request.useGeneralParameters = NO;
        
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertTrue([responseObject[@"args"][@"key1"] isEqualToString:@"value1"]);
        XCTAssertTrue([responseObject[@"args"][@"key2"] isEqualToString:@"value2"]);
        XCTAssertNotNil(responseObject);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithCommonTimeout];
}

- (void)testPatchRequest {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"TestPatchRequest should succeed"];
    
    [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
        
        request.url = @"https://httpbin.org/patch";
        request.parameters = @{@"key1" : @"value1", @"key2" : @"value2"};
        request.httpMethod = kFCHTTPMethodTypePATCH;
        request.useGeneralHeaders = NO;
        request.useGeneralParameters = NO;
        
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertTrue([responseObject[@"form"][@"key1"] isEqualToString:@"value1"]);
        XCTAssertTrue([responseObject[@"form"][@"key2"] isEqualToString:@"value2"]);
        XCTAssertNotNil(responseObject);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithCommonTimeout];
}

- (void)testUserAgent {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"TestUserAgent should succeed"];
    
    [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
        
        request.url = @"https://httpbin.org/user-agent";
        request.headers = @{@"User-Agent" : @"FCNetworking custom user-agent"};
        request.httpMethod = kFCHTTPMethodTypeGET;
        request.useGeneralHeaders = NO;
        request.useGeneralParameters = NO;
        
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertTrue([responseObject[@"user-agent"] isEqualToString:@"FCNetworking custom user-agent"]);
        XCTAssertNotNil(responseObject);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithCommonTimeout];
}

- (void)testRequestWithFaliure {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"TestRequestWithFaliure should succeed"];
    
    [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
        
        request.url = @"https://httpbin.org/status/404";
        request.httpMethod = kFCHTTPMethodTypeGET;
        request.useGeneralHeaders = NO;
        request.useGeneralParameters = NO;
        
    } success:^(id  _Nullable responseObject) {
        
        XCTAssertNil(responseObject);
        
    } failure:^(NSError * _Nullable error) {
        
        XCTAssertNotNil(error);
        
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertNil(responseObject);
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithCommonTimeout];
}

- (void)testRequestTimedOut {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"TestRequestTimedOut should succeed"];
    
    [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
        
        request.url = @"https://kangzubin.cn/test/timeout.php";
        request.httpMethod = kFCHTTPMethodTypeGET;
        request.useGeneralHeaders = NO;
        request.useGeneralParameters = NO;
        request.timeoutInterval = 5;
        
    } success:^(id  _Nullable responseObject) {
        
        XCTAssertNil(responseObject);
        
    } failure:^(NSError * _Nullable error) {
        
        XCTAssertTrue(error.code == NSURLErrorTimedOut);
        XCTAssertNotNil(error);
        
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertNil(responseObject);
        XCTAssertTrue(error.code == NSURLErrorTimedOut);
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithCommonTimeout];
}

- (void)testCancelRequest {
    
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"TestCancelRequest should fail due to manually cancelled."];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"Cancel block should be called."];
    NSString *identifier = [FCCenter sendRequest:^(FCRequest * _Nonnull request) {
        
        request.url = @"https://kangzubin.cn/test/timeout.php";
        request.httpMethod = kFCHTTPMethodTypeGET;
        request.useGeneralHeaders = NO;
        request.useGeneralParameters = NO;
        request.timeoutInterval = 30;
        
    } success:^(id  _Nullable responseObject) {
        
        XCTAssertNil(responseObject);
        
    } failure:^(NSError * _Nullable error) {
        
        XCTAssertTrue(error.code == NSURLErrorCancelled);
        XCTAssertNotNil(error);
        
    } finished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
        XCTAssertNil(responseObject);
        XCTAssertTrue(error.code == NSURLErrorCancelled);
        XCTAssertNotNil(error);
        [expectation1 fulfill];
    }];
    
    sleep(2);
    
    [FCCenter cancelRequest:identifier cancel:^(FCRequest * _Nonnull request) {
       
        XCTAssertNotNil(request);
        XCTAssertTrue([request.url isEqualToString:@"https://kangzubin.cn/test/timeout.php"]);
        [expectation2 fulfill];
    }];
    [self waitForExpectationsWithCommonTimeout];
}






- (void)waitForExpectationsWithCommonTimeout {
    
    [self waitForExpectationsWithCommonTimeoutUsingHandler:nil];
}

- (void)waitForExpectationsWithCommonTimeoutUsingHandler:(XCWaitCompletionHandler)handler {
    
    [self waitForExpectationsWithTimeout:self.networkTimeout handler:handler];
}

- (void)testPerformanceExample {
    
    // This is an example of a performance test case.
    [self measureBlock:^{
    
        // Put the code you want to measure the time of here.
    }];
}

- (void)tearDown {
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

@end
