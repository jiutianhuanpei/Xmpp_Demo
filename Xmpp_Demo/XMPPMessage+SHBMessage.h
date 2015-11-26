//
//  XMPPMessage+SHBMessage.h
//  Xmpp_Demo
//
//  Created by 沈红榜 on 15/10/21.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import "XMPPMessage.h"
#import "Model.h"
#import <XMPP.h>

@interface XMPPMessage (SHBMessage)

- (void)addMessage:(NSString *)message;

@end
