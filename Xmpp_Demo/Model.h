//
//  SHBMessage.h
//  Xmpp_Demo
//
//  Created by 沈红榜 on 15/10/21.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (nonatomic, copy) NSString *content;

@end

@interface SHBUser : NSObject

+ (SHBUser *)selfUser;

@property (nonatomic, assign) NSInteger account_type;
@property (nonatomic, copy) NSString    *ios_token;
@property (nonatomic, copy) NSString    *jid;
@property (nonatomic, copy) NSString    *openfire_ip;
@property (nonatomic, copy) NSString    *name;
@property (nonatomic, copy) NSString    *token;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy) NSString    *photo;
@property (nonatomic, assign) NSTimeInterval    lastTime;

@end
