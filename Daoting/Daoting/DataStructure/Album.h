//
//  Album.h
//  Daoting
//
//  Created by Kevin on 14-5-15.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Album : NSObject<NSCoding>

@property (nonatomic, strong) NSString  *shortName;
@property (nonatomic, strong) NSString  *title;
@property (nonatomic, strong) NSString  *description;
@property (nonatomic, strong) NSURL     *imageUrl;
@property (nonatomic, strong) NSURL     *plistUrl;
@property (nonatomic, strong) NSString  *artistName;
@property (nonatomic, strong) NSString  *updatingStatus;
@property (nonatomic, strong) NSString  *category;
@property (nonatomic, strong) NSString  *longdescription;
@property (nonatomic, strong) NSString  *updatedAlbum;

@end
