//
//  AudioCategory.m
//  Daoting
//
//  Created by Kevin on 14/9/5.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "AudioCategory.h"

@implementation AudioCategory

@synthesize description, shortName, title, imageUrl, albumListUrl, updatedCategory, albumArray;

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:shortName forKey:@"shortName"];
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:imageUrl forKey:@"imageUrl"];
    [aCoder encodeObject:albumListUrl forKey:@"albumListUrl"];
    [aCoder encodeObject:description forKey:@"description"];
    [aCoder encodeObject:updatedCategory forKey:@"updatedCategory"];
    [aCoder encodeObject:albumArray forKey:@"albumArray"];
}


- (id)initWithCoder:(NSCoder *)aDecoder{
    shortName = [aDecoder decodeObjectForKey:@"shortName"];
    title =[aDecoder decodeObjectForKey:@"title"];
    imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
    albumListUrl = [aDecoder decodeObjectForKey:@"albumListUrl"];
    description= [aDecoder decodeObjectForKey:@"description"];
    updatedCategory= [aDecoder decodeObjectForKey:@"updatedCategory"];
    albumArray = [aDecoder decodeObjectForKey:@"albumArray"];
    
    return self;
}


@end
