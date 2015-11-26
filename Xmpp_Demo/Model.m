//
//  SHBMessage.m
//  Xmpp_Demo
//
//  Created by 沈红榜 on 15/10/21.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import "Model.h"

@implementation Model

@end

@implementation SHBUser

+ (SHBUser *)selfUser {
    static SHBUser *user = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[SHBUser alloc] init];
    });
    return user;
}

@end