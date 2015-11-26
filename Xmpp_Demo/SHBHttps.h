//
//  SHBHttps.h
//  Xmpp_Demo
//
//  Created by 沈红榜 on 15/11/25.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Success)(id objcet);
typedef void(^Failed)(NSError *error);

typedef void(^Complete)(id object, NSError *error);


@interface SHBHttps : NSObject

+ (SHBHttps *)shared;

- (void)loginWithName:(NSString *)name password:(NSString *)password complete:(Complete)complete;
- (void)action:(NSString *)action params:(NSDictionary *)param complete:(Complete)complete;

@end
