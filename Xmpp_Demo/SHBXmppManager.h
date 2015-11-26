//
//  SHBXmppManager.h
//  Xmpp_Demo
//
//  Created by 沈红榜 on 15/10/21.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPP.h>
#import "XMPPRoom.h"

@protocol SHBXmppManagerDelegate <NSObject>
@optional

/**
 *   已连接
 */
- (void)didSendConnecting;
/**
 *   已认证
 */
- (void)didAuthenticate;
/**
 *   未认证
 */
- (void)didNotAuthenticate;

/**
 *   发送消息
 *
 *   @param message
 *   @param error
 */
- (void)didSendMessage:(id)message error:(NSError *)error;

/**
 *   接收消息
 *
 *   @param message
 *   @param room    房间
 *   @param fromJID 发送者jid
 */
- (void)didReceivedMessage:(XMPPMessage *)message room:(XMPPRoom *)room fromOccupant:(XMPPJID *)fromJID;

- (void)didDisconnect:(NSError *)error;
- (void)didTimeout;

- (void)didSendPresence:(XMPPPresence *)presence;
- (void)didReceivePresence:(XMPPPresence *)presence;

- (void)didSendIQ:(XMPPIQ *)iq;
- (void)didReceiveIQ:(XMPPIQ *)iq;

//room
- (void)didCreatRoom:(XMPPRoom *)room;
- (void)shbRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence;
- (void)shbRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence;

- (void)shbRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID;

@end

@interface SHBXmppManager : NSObject

@property (nonatomic, assign) id<SHBXmppManagerDelegate>    delegate;
@property (nonatomic, readonly) BOOL                        isConnected;
@property (nonatomic, copy)     NSString                    *host;
@property (nonatomic, copy)     NSString                    *token;
@property (nonatomic, strong)   XMPPStream                  *stream;

+ (SHBXmppManager *)defaultManager;

/**
 *   连接 服务器
 *
 *   @param jid    用户jid
 *   @param domain 服务器地址
 */
- (void)connectWithJID:(XMPPJID *)jid domain:(NSString *)domain;

/**
 *   断开连接
 *
 *   @param complete 失败回调
 */
- (void)disConnect:(dispatch_block_t)complete;

/**
 *   让用户重新进入聊天状态
 */
- (void)active;
/**
 *   退出聊天状态
 */
- (void)deactive;

- (XMPPRoom *)createRoomWithRoomJID:(NSString *)roomJID Nickname:(NSString *)nick;


@end
