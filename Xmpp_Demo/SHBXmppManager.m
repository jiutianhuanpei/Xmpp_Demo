//
//  SHBXmppManager.m
//  Xmpp_Demo
//
//  Created by 沈红榜 on 15/10/21.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import "SHBXmppManager.h"
#import "XMPPReconnect.h"
#import "XMPPMessage+SHBMessage.h"
#import "Model.h"
#import "XMPPRoomCoreDataStorage.h"

NSString *const IMResource          = @"app";
NSString *const IMPassword          = @"icr1bn";

static dispatch_queue_t queue = nil;

@interface SHBXmppManager ()<XMPPStreamDelegate, XMPPRoomDelegate>

@end

@implementation SHBXmppManager {
    
    NSString            *_token;
    
    XMPPReconnect       *_reconnect;
    
    
    
}

+ (SHBXmppManager *)defaultManager {
    static SHBXmppManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SHBXmppManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        queue = dispatch_queue_create("com.cribn.im", nil);
    }
    return self;
}

- (void)connectWithJID:(XMPPJID *)jid domain:(NSString *)domain {
    [self disConnect:nil];
    if (!_stream) {
        _stream = [[XMPPStream alloc] init];
        _stream.enableBackgroundingOnSocket = true;
        _stream.myJID = jid;
        _stream.hostName = domain;
        [_stream addDelegate:self delegateQueue:queue];
        
        NSError *error = nil;
        [_stream connectWithTimeout:5 error:&error];
        
        if (!_reconnect) {
            _reconnect = [[XMPPReconnect alloc] initWithDispatchQueue:queue];
            _reconnect.autoReconnect = true;
            _reconnect.reconnectDelay = 5;
            _reconnect.reconnectTimerInterval = 5;
        }
        
        [_reconnect activate:_stream];
        if ([_delegate respondsToSelector:@selector(didSendConnecting)]) {
            [_delegate didSendConnecting];
        }
    }
}

- (void)disConnect:(dispatch_block_t)complete {
    if ([_stream isConnected]) {
        NSXMLElement *away = [NSXMLElement elementWithName:@"presence" URI:@"jabber:client"];
        [away addChild:[DDXMLNode elementWithName:@"status" stringValue:@"离开"]];
        [away addChild:[DDXMLNode elementWithName:@"show" stringValue:@"away"]];
        [_stream sendElement:away];
        
        [_stream disconnectAfterSending];
        [_reconnect stop];
        [_reconnect deactivate];
        _stream = nil;
    } else {
        if (complete) {
            complete();
        }
    }
}

- (void)active {
//    NSXMLElement *away = [NSXMLElement elementWithName:@"persence" URI:@"jabber:client"];
//    [away addChild:[DDXMLNode elementWithName:@"status" stringValue:@"空闲"]];
//    [away addChild:[DDXMLNode elementWithName:@"show" stringValue:@"chat"]];
//    [_stream sendElement:away];
    
    if (_stream.isDisconnected) {
        [_stream connectWithTimeout:5.f error:nil];
    }else{
        XMPPPresence *presence =  [XMPPPresence presenceWithType:@"available"];
        [presence addChild:[DDXMLNode elementWithName:@"show" stringValue:@"chat"]];
        [_stream sendElement:presence];
    }
}

- (void)deactive {
    NSXMLElement *away = [NSXMLElement elementWithName:@"persence" URI:@"jabber:client"];
    [away addChild:[DDXMLNode elementWithName:@"status" stringValue:@"繁忙"]];
    [away addChild:[DDXMLNode elementWithName:@"show" stringValue:@"dnd"]];
    [_stream sendElement:away];
}



- (void)setToken:(NSString *)token {
    if (token) {
        _token = token;
        if (_stream.isAuthenticated) {
            [self updateToken];
        }
    }
}

- (void)updateToken {
    XMPPPresence *presence = [XMPPPresence presence];
    NSXMLElement *tokenNode = [NSXMLElement elementWithName:@"device" xmlns:@"com.cribn.cserv"];
    [tokenNode addChild:[DDXMLNode elementWithName:@"token" stringValue:_token]];
    [tokenNode addChild:[DDXMLNode elementWithName:@"type" stringValue:@"1"]];
    [tokenNode addChild:[DDXMLNode elementWithName:@"client" stringValue:@"0"]];
    [presence addChild:tokenNode];
    [_stream sendElement:presence];
}

- (XMPPRoom *)createRoomWithRoomJID:(NSString *)JID Nickname:(NSString *)nick {
    XMPPJID *roomJID = [XMPPJID jidWithString:JID];
    
    XMPPRoomCoreDataStorage *roomstorage = [[XMPPRoomCoreDataStorage alloc] init];
    
    XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:roomstorage jid:roomJID dispatchQueue:queue];
    
    [room activate:_stream];
    [room joinRoomUsingNickname:nick history:nil];
    
    [room addDelegate:self delegateQueue:queue];
    return room;
}

#pragma mark - XMPPStreamDelegate
- (void)xmppStreamWillConnect:(XMPPStream *)sender {
    
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
    
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    [_stream authenticateWithPassword:IMPassword error:nil];
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    [_delegate didTimeout];
}

- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender {
    
    
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    [_delegate didDisconnect:error];
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    [_delegate didAuthenticate];
//    if (_token) {
//        [self updateToken];
//    }
    [self active];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    [_delegate didNotAuthenticate];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    [_delegate didReceivedMessage:message room:nil fromOccupant:message.from];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    NSLog(@"didReceivePresence:%@", presence);
    if ([_delegate respondsToSelector:@selector(didReceivePresence:)]) {
        [_delegate didReceivePresence:presence];
    }
    
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error {
    
}

- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq {
    NSLog(@"didSendIQ:%@", iq);
    if ([_delegate respondsToSelector:@selector(didSendIQ:)]) {
        [_delegate didSendIQ:iq];
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    NSLog(@"didReceiveIQ:%@", iq);
    if ([_delegate respondsToSelector:@selector(didReceiveIQ:)]) {
        [_delegate didReceiveIQ:iq];
    }
    return true;
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    [_delegate didSendMessage:message error:nil];
}

- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence {
    NSLog(@"didSendPresence:%@", presence);
    if ([_delegate respondsToSelector:@selector(didSendPresence:)]) {
        [_delegate didSendPresence:presence];
    }
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error {
    
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    [_delegate didSendMessage:message error:error];
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error {
    
}


#pragma mark - XMPPRoomDelegate
- (void)xmppRoomDidCreate:(XMPPRoom *)sender {
    NSLog(@"%s", __FUNCTION__);
    if ([_delegate respondsToSelector:@selector(didCreatRoom:)]) {
        [_delegate didCreatRoom:sender];
    }
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender {
    NSLog(@"%s", __FUNCTION__);
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender {
    NSLog(@"%s", __FUNCTION__);
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender {
    NSLog(@"%s", __FUNCTION__);
}

- (void)xmppRoom:(XMPPRoom *)sender didFailToDestroy:(XMPPIQ *)iqError {
    NSLog(@"%s %@", __FUNCTION__, iqError);
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    NSLog(@"%s \r %@ \r %@ ", __FUNCTION__, occupantJID, presence);
    if ([_delegate respondsToSelector:@selector(shbRoom:occupantDidJoin:withPresence:)]) {
        [_delegate shbRoom:sender occupantDidJoin:occupantJID withPresence:presence];
    }
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    NSLog(@"%s \r %@ \r %@ ", __FUNCTION__, occupantJID, presence);
    if ([_delegate respondsToSelector:@selector(shbRoom:occupantDidLeave:withPresence:)]) {
        [_delegate shbRoom:sender occupantDidLeave:occupantJID withPresence:presence];
    }
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    NSLog(@"%s \r %@ \r %@ ", __FUNCTION__, occupantJID, presence);
}

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID {
    NSLog(@"%s \r %@ \r %@ ", __FUNCTION__, message, occupantJID);
    if ([_delegate respondsToSelector:@selector(shbRoom:didReceiveMessage:fromOccupant:)]) {
        [_delegate shbRoom:sender didReceiveMessage:message fromOccupant:occupantJID];
    }
}


@end
