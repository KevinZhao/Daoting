//
//  UserManagement.m
//  Daoting
//
//  Created by Kevin on 15/7/1.
//  Copyright (c) 2015年 赵 克鸣. All rights reserved.
//

#import "UserManagement.h"

#define kWXAPP_ID       @"wx134b0f70f3612fe8"
#define kWXAPP_SECRET   @"55435a9c06593675d9d35a6dccb6e9e4"

@implementation UserManagement

#pragma mark Init

+ (UserManagement *)sharedManager {
    static dispatch_once_t once;
    static UserManagement * sharedInstance;
    dispatch_once(&once, ^{
        
        sharedInstance = [[UserManagement alloc]init];
        
    });
    return sharedInstance;
}

- (instancetype) init
{
    //QQ login
    //_tencentOAuth = [[TencentOAuth alloc]initWithAppId:@"1104667975" andDelegate:self];
    
    //[WXApi registerApp:@"wx134b0f70f3612fe8"];
    
    //WXApi
    
    return self;
}

#pragma mark Public Methods

- (void)login: (int)loginType
{
    if (loginType == LoginTypeQQ) {
        
        /*NSArray *_permissions =  [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO, kOPEN_PERMISSION_GET_USER_INFO,kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
        
        [_tencentOAuth authorize:_permissions inSafari:NO];*/
    }
    
    if (loginType == LoginTypeWeChat) {
        
        //构造SendAuthReq结构体
        SendAuthReq* req =[[SendAuthReq alloc ]init];
        req.scope = @"snsapi_userinfo" ;
        req.state = @"123" ;
        //第三方向微信终端发送一个SendAuthReq消息结构
        [WXApi sendReq:req];
    }
}

-(void) onResp:(BaseResp*)resp
{
    /*
     ErrCode ERR_OK = 0(用户同意)
     ERR_AUTH_DENIED = -4（用户拒绝授权）
     ERR_USER_CANCEL = -2（用户取消）
     code    用户换取access_token的code，仅在ErrCode为0时有效
     state   第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
     lang    微信客户端当前语言
     country 微信用户当前国家信息
     */
    
    SendAuthResp *aresp = (SendAuthResp *)resp;
    if (aresp.errCode== 0) {
        //NSString *code = aresp.code;
        //NSDictionary *dic = @{@"code":code};
        
        _WXcode = aresp.code;
        
        [self getAccess_token];
    }
}

-(void)getAccess_token
{
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWXAPP_ID,kWXAPP_SECRET,_WXcode];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
       
                _accessToken = [dic objectForKey:@"access_token"];
                _openId = [dic objectForKey:@"openid"];
                
                [self getUserInfo];
            }
        });
    });
}

-(void)getUserInfo
{
    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",_accessToken, _openId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 city = Haidian;
                 country = CN;
                 headimgurl = "http://wx.qlogo.cn/mmopen/FrdAUicrPIibcpGzxuD0kjfnvc2klwzQ62a1brlWq1sjNfWREia6W8Cf8kNCbErowsSUcGSIltXTqrhQgPEibYakpl5EokGMibMPU/0";
                 language = "zh_CN";
                 nickname = "xxx";
                 openid = oyAaTjsDx7pl4xxxxxxx;
                 privilege =     (
                 );
                 province = Beijing;
                 sex = 1;
                 unionid = oyAaTjsxxxxxxQ42O3xxxxxxs;
                 }
                 */
                
                self.nickName = [dic objectForKey:@"nickname"];
                self.headerIconUrl = [NSURL URLWithString:[dic objectForKey:@"headimgurl"]];
                
                if (self.delegate) {
                    [self.delegate onUserDidLogin];
                }
            }
        });
        
    });
}

#pragma mark @protocol TencentSessionDelegate <NSObject>
/*- (void)tencentDidLogin
{
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
    {
        // 记录登录用户的OpenID、Token以及过期时间
        _openId = _tencentOAuth.openId;
        _expirationDate = _tencentOAuth.expirationDate;
        _accessToken = _tencentOAuth.accessToken;
        _isLogined = YES;
        
        [_tencentOAuth getUserInfo];
    }
    else
    {
        _isLogined = NO;
    }
}

-(void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled)
    {
        NSLog(@"用户取消登录");
    }
    else
    {
        NSLog(@"登录失败");
    }
}

-(void)tencentDidNotNetWork
{
    NSLog(@"登录失败");
}

- (void)getUserInfoResponse:(APIResponse*) response
{
    self.headerIconUrl = [NSURL URLWithString:[response.jsonResponse objectForKey:@"figureurl_qq_2"]];
    
    self.nickName = [response.jsonResponse objectForKey:@"nickname"];
    
    [self.delegate onUserDidLogin];
}*/
@end
