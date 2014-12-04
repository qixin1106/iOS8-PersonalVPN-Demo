
iOS8的Personal VPN 测试用例 
===================================  
  
    
注意事项 
-----------------------------------  
1.工程配置中确认Capabilities中的Personal VPN开启

2.导入NetworkExtension.framework(貌似开启就自动导入了)

3.@import NetworkExtension;





### 创建VPN描述文件
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



	


 