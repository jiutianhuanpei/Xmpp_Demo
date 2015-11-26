//
//  XMPPMessage+SHBMessage.m
//  Xmpp_Demo
//
//  Created by 沈红榜 on 15/10/21.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import "XMPPMessage+SHBMessage.h"
#import "Model.h"

@implementation XMPPMessage (SHBMessage)

- (void)addMessage:(NSString *)message {
    
    SHBUser *user = [SHBUser selfUser];

    [self addBody:message];
    [self addAttributeWithName:@"id" stringValue:[self guidString]];
    
    NSXMLElement *userNode = [NSXMLElement elementWithName:@"user"];
    [userNode addNamespaceWithPrefix:nil stringValue:@"com:cribn:user"];
    [userNode addAttributeWithName:@"name" stringValue:user.name];
    [userNode addAttributeWithName:@"header" stringValue:user.photo];
    [userNode addAttributeWithName:@"at" integerValue:user.account_type];
    [userNode addAttributeWithName:@"time" integerValue:[[NSDate date] timeIntervalSince1970]];
    [userNode addAttributeWithName:@"badge" integerValue:0];
    [userNode addAttributeWithName:@"lut" doubleValue:user.lastTime];
    [self addChild:userNode];
    
  
    NSXMLElement *action = [NSXMLElement elementWithName:@"ext"];
    [action addNamespaceWithPrefix:nil stringValue:@"com:cribn:ext"];
    [action addAttributeWithName:@"actionType" integerValue:0];
    [action addAttributeWithName:@"contentType" integerValue:0];
    [action addAttributeWithName:@"listType" integerValue:3];
    
    [self addChild:action];

    

}

- (NSString *)guidString{
    CFUUIDRef    uuidObj = CFUUIDCreate(nil);
    NSString    *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString ;
}

@end
