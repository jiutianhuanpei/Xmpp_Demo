//
//  SHBHttps.m
//  Xmpp_Demo
//
//  Created by 沈红榜 on 15/11/25.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import "SHBHttps.h"
#import <AFNetworking.h>

NSString    *const kHttpBaseUrl = @"http://10.254.192.181/";

NSString    *const  kAPIType = @"mobile";
CGFloat     const  kAPIVersion = 3.0;

@interface SHBHttps ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation SHBHttps

+ (SHBHttps *)shared {
    static SHBHttps *shb = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shb = [[SHBHttps alloc] init];
    });
    return shb;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 30.f;
        config.timeoutIntervalForResource = 30.f;
        config.TLSMaximumSupportedProtocol = kTLSProtocol12;
        config.allowsCellularAccess = true;
        
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@/v%0.1f",kHttpBaseUrl,kAPIType,kAPIVersion]] sessionConfiguration:config];
        [_manager.requestSerializer setValue:@"3.2" forHTTPHeaderField:@"api-version"];
        
        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        policy.allowInvalidCertificates = YES;
        policy.validatesDomainName = YES;
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"ssl_pro" ofType:@"cer"];
        NSData *certData = [NSData dataWithContentsOfFile:cerPath];
        policy.pinnedCertificates = @[certData];
        
        _manager.securityPolicy = policy;
        
        
    }
    return self;
}

- (void)loginWithName:(NSString *)name password:(NSString *)password complete:(Complete)complete {
    
    [self post:@"doctor/login" parameters:@{@"name":name,@"password":password,@"account_type":@(2)} complete:^(id object, NSError *error) {
        if (complete) {
            complete(object, error);
        }
    }];
}

- (void)action:(NSString *)action params:(NSDictionary *)param complete:(Complete)complete {
    [self post:[NSString stringWithFormat:@"doctor/%@", action] parameters:param complete:^(id object, NSError *error) {
        NSLog(@"object:%@\r error:%@", object, error);
        if (complete) {
            complete(object, error);
        }
    }];
}

- (void)post:(NSString *)post parameters:(NSDictionary *)dic complete:(Complete)complete {
    [_manager POST:post parameters:[self parame:dic] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (complete) {
            complete(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (complete) {
            complete(nil, error);
        }
    }];
}

- (NSDictionary *)parame:(NSDictionary *)tempDic {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:tempDic];
    
    BOOL isRed = true;
    NSString *token = nil;
    if (isRed) {
        token = @"cef7f9f5b26d9f4a428da337b9bef0733a5308177caaee950e96193948c45d1d";
    } else {
        token = @"69dfeefcd5771d6dc2de2eb91eacdfdf2398cfcf457d222438ac1c96972b51d3";
    }
    //红5c：@"cef7f9f5b26d9f4a428da337b9bef0733a5308177caaee950e96193948c45d1d"
    //波pod：@"69dfeefcd5771d6dc2de2eb91eacdfdf2398cfcf457d222438ac1c96972b51d3"
    [dic setValue:token forKey:@"source_token"];
    [dic setValue:token forKey:@"token"];
    return dic;
}

@end
