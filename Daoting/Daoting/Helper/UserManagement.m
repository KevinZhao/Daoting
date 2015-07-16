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
    
    _sharedAppData = [AppData sharedAppData];
    
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


#pragma mark <WXApiDelegate>

-(void)onResp:(BaseResp*)resp
{
    SendAuthResp *aresp = (SendAuthResp *)resp;
    if (aresp.errCode== WXSuccess) {
        
        _WXcode = aresp.code;
        
        [self getAccess_token];
    }
}

-(void)getAccess_token
{
    NSString *url =[NSString stringWithFormat:
                    @"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",
                    kWXAPP_ID, kWXAPP_SECRET, _WXcode];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
       
                _accessToken = [dic objectForKey:@"access_token"];
                _openId = [dic objectForKey:@"openid"];
                
                _sharedAppData.WX_OpenId = _openId;
                [_sharedAppData save];
                
                [self getUserInfo];
            }
        });
    });
}

-(void)getUserInfo
{
    NSString *url =[NSString stringWithFormat:
                    @"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",
                    _accessToken, _openId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                _nickName = [dic objectForKey:@"nickname"];
                _headerIconUrl = [NSURL URLWithString:[dic objectForKey:@"headimgurl"]];
                
                _sharedAppData.WX_NickName =_nickName;
                _sharedAppData.WX_HeadImgUrl = _headerIconUrl;
                [_sharedAppData save];
                
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
