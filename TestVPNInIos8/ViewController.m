//
//  ViewController.m
//  TestVPNInIos8
//
//  Created by Qixin on 14/11/26.
//  Copyright (c) 2014年 Qixin. All rights reserved.
//

#import "ViewController.h"
@import NetworkExtension;

//DEBUG
#define ALERT(title,msg) dispatch_async(dispatch_get_main_queue(), ^{UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];[alert show];});


//VPN
/*************************************************/
//#error 确认输入对应的字段值
#define kVPNName @"你的VPN用户名"
#define kServerAddress @"你的VPN地址"
#define kLocalIdentifier @"你的localIdentifier"
#define kRemoteIdentifier @"你的remoteIdentifier"
/*************************************************/



//Keychain
#define kKeychainServiceName @"com.qixin.vpntest";//可以改成你需要的
//从Keychain取密码对应的key
#define kPasswordReference @"passwordReference"
#define kSharedSecretReference @"sharedSecretReference"












@implementation ViewController


#pragma mark - Keychain
//获取Keychain里的对应密码
- (NSData *)searchKeychainCopyMatching:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    
    searchDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    searchDictionary[(__bridge id)kSecAttrGeneric] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrAccount] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrService] = kKeychainServiceName;
    searchDictionary[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    searchDictionary[(__bridge id)kSecReturnPersistentRef] = @YES;//这很重要
    
    CFTypeRef result = NULL;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &result);
    return (__bridge_transfer NSData *)result;
}

/*
 //TODO:插入密码到Keychain
 //MARK:本项目暂时用不到,本想可以直接通过插入不需要在外面在输入一遍密码了,目前测试,似乎是不行
 - (void)addKeychainItem:(NSString *)identifier password:(NSString*)password
 {
 NSData *passData = [password dataUsingEncoding:NSUTF8StringEncoding];
 NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
 
 NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
 
 searchDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
 searchDictionary[(__bridge id)kSecAttrGeneric] = encodedIdentifier;
 searchDictionary[(__bridge id)kSecAttrAccount] = encodedIdentifier;
 searchDictionary[(__bridge id)kSecAttrService] = kKeychainServiceName;
 searchDictionary[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
 searchDictionary[(__bridge id)kSecValueData] = passData;
 
 CFTypeRef result = NULL;
 OSStatus status = SecItemAdd((__bridge CFDictionaryRef)(searchDictionary), &result);
 if (status != noErr)
 {
 NSLog(@"Keychain插入错误!");
 ALERT(@"Keychain", @"插入错误!");
 }
 }
 */














#pragma mark - IPSec
- (void)setupIPSec
{
    NEVPNProtocolIPSec *p = [[NEVPNProtocolIPSec alloc] init];
    p.username = kVPNName;
    p.passwordReference = [self searchKeychainCopyMatching:kPasswordReference];
    p.serverAddress = kServerAddress;
    p.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;
    p.sharedSecretReference = [self searchKeychainCopyMatching:kSharedSecretReference];
    p.disconnectOnSleep = NO;
    
    //需要扩展鉴定(群组)
    p.localIdentifier = kLocalIdentifier;
    p.remoteIdentifier = kRemoteIdentifier;
    p.useExtendedAuthentication = YES;
    
    [[NEVPNManager sharedManager] setProtocol:p];
    [[NEVPNManager sharedManager] setOnDemandEnabled:NO];
    [[NEVPNManager sharedManager] setLocalizedDescription:@"个人-VPN测试"];//VPN自定义名字
    [[NEVPNManager sharedManager] setEnabled:YES];
}





















#pragma mark - IBAction
- (IBAction)buttonPressed:(UIButton *)sender
{
    switch (sender.tag)
    {
        case 0://创建VPN描述文件
        {
            [[NEVPNManager sharedManager] loadFromPreferencesWithCompletionHandler:^(NSError *error){
                if(error)
                {
                    NSLog(@"Load error: %@", error);
                }
                else
                {
                    //配置IPSec
                    [self setupIPSec];
                    
                    //保存VPN到系统->通用->VPN->个人VPN
                    [[NEVPNManager sharedManager] saveToPreferencesWithCompletionHandler:^(NSError *error){
                        if(error)
                        {
                            ALERT(@"saveToPreferences", error.description);
                            NSLog(@"Save error: %@", error);
                        }
                        else
                        {
                            NSLog(@"Saved!");
                            ALERT(@"Saved", @"Saved");
                        }
                    }];
                }
            }];
            break;
        }
        case 1://TODO:删除VPN描述文件
        {
            [[NEVPNManager sharedManager] loadFromPreferencesWithCompletionHandler:^(NSError *error){
                if (!error)
                {
                    [[NEVPNManager sharedManager] removeFromPreferencesWithCompletionHandler:^(NSError *error){
                        if(error)
                        {
                            NSLog(@"Remove error: %@", error);
                            ALERT(@"removeFromPreferences", error.description);
                        }
                        else
                        {
                            ALERT(@"removeFromPreferences", @"删除成功");
                        }
                    }];
                }
            }];
            
            break;
        }
        case 2://TODO:连接VPN(前提是必须有描述文件)
        {
            [[NEVPNManager sharedManager] loadFromPreferencesWithCompletionHandler:^(NSError *error){
                if (!error)
                {
                    //配置IPSec
                    [self setupIPSec];
                    [[NEVPNManager sharedManager].connection startVPNTunnelAndReturnError:nil];
                }
            }];
            break;
        }
        case 3://TODO:断开VPN
        {
            [[NEVPNManager sharedManager] loadFromPreferencesWithCompletionHandler:^(NSError *error){
                if (!error)
                {
                    [[NEVPNManager sharedManager].connection stopVPNTunnel];
                }
            }];
            break;
        }
            
        default:
            break;
    }
}

























#pragma mark - VPN状态切换通知
- (void)VPNStatusDidChangeNotification
{
    switch ([NEVPNManager sharedManager].connection.status)
    {
        case NEVPNStatusInvalid:
        {
            NSLog(@"NEVPNStatusInvalid");
            break;
        }
        case NEVPNStatusDisconnected:
        {
            NSLog(@"NEVPNStatusDisconnected");
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            break;
        }
        case NEVPNStatusConnecting:
        {
            NSLog(@"NEVPNStatusConnecting");
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            break;
        }
        case NEVPNStatusConnected:
        {
            NSLog(@"NEVPNStatusConnected");
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            break;
        }
        case NEVPNStatusReasserting:
        {
            NSLog(@"NEVPNStatusReasserting");
            break;
        }
        case NEVPNStatusDisconnecting:
        {
            NSLog(@"NEVPNStatusDisconnecting");
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            break;
        }
        default:
            break;
    }
}
























#pragma mark - 生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VPNStatusDidChangeNotification) name:NEVPNStatusDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEVPNStatusDidChangeNotification object:nil];
}

@end
