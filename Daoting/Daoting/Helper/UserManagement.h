//
//  UserManagement.h
//  Daoting
//
//  Created by Kevin on 15/7/1.
//  Copyright (c) 2015年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"

#define LoginTypeQQ         0
#define LoginTypeWeChat     1

@protocol IUserManagementDelegate <NSObject>

@optional
-(void) onUserDidLogin;

@end

@interface UserManagement : NSObject<WXApiDelegate>
{
    //TencentOAuth    *_tencentOAuth;
    NSString*   _accessToken;
    NSDate*     _expirationDate;
    NSString*   _openId;
    NSString*   _WXcode;
    NSString*   _nickName;
    UIImage*    _wxHeadImg;
}

@property (nonatomic, assign) BOOL       isLogined;
@property (nonatomic, retain) NSString  *nickName;
@property (nonatomic, retain) NSURL     *headerIconUrl;

@property (readwrite, unsafe_unretained) id<IUserManagementDelegate> delegate;

+ (UserManagement *)sharedManager;
- (void)login: (int)loginType;


@end
