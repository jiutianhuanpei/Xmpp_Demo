//
//  RootViewController.m
//  Xmpp_Demo
//
//  Created by 沈红榜 on 15/10/21.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import "RootViewController.h"
#import "SHBXmppManager.h"
#import "SHBHttps.h"
#import "Model.h"
#import "XMPPMessage+SHBMessage.h"

@interface RootViewController ()<SHBXmppManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *to;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation RootViewController {
    
//    __weak IBOutlet UITextView *_textView;
//    __weak IBOutlet UITextField *_to;
    XMPPRoom        *_room;
    NSDictionary    *_roomDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    SHBXmppManager *manager = [SHBXmppManager defaultManager];
    manager.delegate = self;
    

    
    
    
    
    
}

- (IBAction)login:(id)sender {
    SHBHttps *https = [SHBHttps shared];
    [https loginWithName:@"18811363864" password:@"123456" complete:^(id object, NSError *error) {
        NSLog(@"object : %@", object);
        if (error) {
            
        } else {
            SHBUser *user = [SHBUser selfUser];
            id data = object[@"data"];
            
            user.account_type = [data[@"account_type"] integerValue];
            user.ios_token = data[@"ios_token"];
            user.jid = data[@"jid"];
            user.openfire_ip = data[@"openfire_ip"];
            user.name = data[@"realname"];
            user.token = data[@"token"];
            user.uid = [data[@"uid"] integerValue];
            user.photo = data[@"user_photo_url"];
            user.lastTime = [data[@"update_time"] doubleValue];
            
            SHBXmppManager *manager = [SHBXmppManager defaultManager];
            [manager connectWithJID:[XMPPJID jidWithString:user.jid] domain:user.openfire_ip];
            
        }
    }];
}


- (IBAction)sendMessage:(id)sender {
    if (_to.text.length == 0) {
        return;
    }
    
    SHBUser *user = [SHBUser selfUser];
    SHBXmppManager *manager = [SHBXmppManager defaultManager];
    
    XMPPJID *toJID = [XMPPJID jidWithUser:_to.text domain:user.openfire_ip resource:@"app"];
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:toJID];
    [message addMessage:@"这是一条消息"];
    [manager.stream sendElement:message];
}

- (IBAction)creatRoom:(id)sender {
    
    SHBXmppManager *manager = [SHBXmppManager defaultManager];
    SHBUser *user = [SHBUser selfUser];
//    NSString *roomJID = [NSString stringWithFormat:@"%.f@conference.111.67.206.168", [[NSDate date] timeIntervalSince1970]];
//    _room = [manager createRoomWithRoomJID:roomJID Nickname:user.jid];
    dispatch_async(dispatch_get_main_queue(), ^{
        _textView.text = [NSString stringWithFormat:@"%@\r%@", _textView.text, @"创建房间"];
    });
    
    SHBHttps *https = [SHBHttps shared];
    [https action:@"roomcreate" params:@{@"user_list" : @"72", @"room_type" : @(3)} complete:^(id object, NSError *error) {
        
        if (!error && [object[@"code"] integerValue] == 0) {
            _roomDic = object[@"data"];
            _room = [manager createRoomWithRoomJID:_roomDic[@"room_jid"] Nickname:user.jid];
        } else {
            
        }
    }];
    
    
}

- (IBAction)destoryRoom:(id)sender {
    
    [_room destroyRoom];
    dispatch_async(dispatch_get_main_queue(), ^{
        _textView.text = [NSString stringWithFormat:@"%@\r%@", _textView.text, @"销毁房间"];
    });
}

- (IBAction)inviteToRoom:(id)sender {
    SHBUser *user = [SHBUser selfUser];
    XMPPJID *jid = [XMPPJID jidWithUser:_to.text domain:user.openfire_ip resource:@"app"];
    [_room inviteUser:jid withMessage:@"从DEMO邀请"];
    dispatch_async(dispatch_get_main_queue(), ^{
        _textView.text = [NSString stringWithFormat:@"%@\r%@", _textView.text, @"邀请成员"];
    });
}

- (IBAction)sendMessageToRoom:(id)sender {
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"groupchat" to:[XMPPJID jidWithString:_room.roomJID.bare]];
    [message addMessage:@"从Demo来的群消息"];
    [_room sendMessage:message];
    
}

#pragma mark - SHBXmppManagerDelegate
- (void)didSendConnecting {
    NSLog(@"%s", __FUNCTION__);
}

- (void)didAuthenticate {
    NSLog(@"%s", __FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        _textView.text = @"登陆成功";
    });
}

- (void)didNotAuthenticate {
    NSLog(@"%s", __FUNCTION__);
}

- (void)didSendMessage:(id)message error:(NSError *)error {
    NSLog(@"message:%@  \r error: %@", message, error);
    dispatch_async(dispatch_get_main_queue(), ^{
        _textView.text = [NSString stringWithFormat:@"%@\r%@", _textView.text, @"发送了一条消息"];
    });
    
}

- (void)didReceivedMessage:(XMPPMessage *)message room:(XMPPRoom *)room fromOccupant:(XMPPJID *)fromJID {
    NSLog(@"%s", __FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _textView.text = [NSString stringWithFormat:@"%@\r%@", _textView.text, [NSString stringWithFormat:@"接收：%@", message.body]];
    });
}

// room
- (void)didCreatRoom:(XMPPRoom *)room {
    NSLog(@"%s\r%@", __FUNCTION__, room);
    
    [[SHBHttps shared] action:@"roomstatus" params:@{@"room_id" : @([_roomDic[@"room_id"] integerValue]), @"act_type" : @(1)} complete:^(id object, NSError *error) {
        if (!error) {
            
        }
    }];
}

- (void)shbRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence {
    NSLog(@"%s\roccupantJID:%@\rpresence:%@", __FUNCTION__ , occupantJID, presence);
}

- (void)shbRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID {
    NSLog(@"%s\rmessage:%@\roccupantJID:%@", __FUNCTION__, message, occupantJID);
}

- (void)didDisconnect:(NSError *)error {
    NSLog(@"%s\r%@", __FUNCTION__, error);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
