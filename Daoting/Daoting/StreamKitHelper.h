//
//  StreamKitHelper.h
//  Daoting
//
//  Created by Kevin on 14-5-23.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKAudioPlayer.h"

@interface StreamKitHelper : NSObject

+ (STKAudioPlayer *)sharedInstance;

@end
