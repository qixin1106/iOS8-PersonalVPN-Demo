
iOS8的Personal VPN 测试用例 
===================================  
  
    
注意事项 
-----------------------------------  
1.工程配置中确认Capabilities中的Personal VPN开启

2.导入NetworkExtension.framework(貌似开启就自动导入了)

3.@import NetworkExtension;


创建VPN描述文件
---------------------------------

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



删除VPN描述文件
---------------------------------

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



连接VPN
---------------------------------

            [[NEVPNManager sharedManager] loadFromPreferencesWithCompletionHandler:^(NSError *error){
                if (!error)
                {
                    //配置IPSec
                    [self setupIPSec];
                    [[NEVPNManager sharedManager].connection startVPNTunnelAndReturnError:nil];
                }
            }];



断开VPN
---------------------------------

            [[NEVPNManager sharedManager] loadFromPreferencesWithCompletionHandler:^(NSError *error){
                if (!error)
                {
                    [[NEVPNManager sharedManager].connection stopVPNTunnel];
                }
            }];


配置IPSec
---------------------------------


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



