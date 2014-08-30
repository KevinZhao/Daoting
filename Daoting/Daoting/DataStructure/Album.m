//
//  Album.m
//  Daoting
//
//  Created by Kevin on 14-5-15.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "Album.h"

@implementation Album

@synthesize description;

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.shortName forKey:@"shortName"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.description forKey:@"description"];
    [aCoder encodeObject:self.imageUrl forKey:@"imageUrl"];
    [aCoder encodeObject:self.plistUrl forKey:@"plistUrl"];
    [aCoder encodeObject:self.artistName forKey:@"artistName"];
    [aCoder encodeObject:self.updatingStatus forKey:@"updatingStatus"];
    [aCoder encodeObject:self.category forKey:@"category"];
    [aCoder encodeObject:self.updatedAlbum forKey:@"new"];
    [aCoder encodeObject:self.longdescription forKey:@"longDescription"];
}


- (id)initWithCoder:(NSCoder *)aDecoder{
    _shortName = [aDecoder decodeObjectForKey:@"shortName"];
    _title =[aDecoder decodeObjectForKey:@"title"];
    description =[aDecoder decodeObjectForKey:@"description"];
    _imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
    _plistUrl = [aDecoder decodeObjectForKey:@"plistUrl"];
    _artistName= [aDecoder decodeObjectForKey:@"artistName"];
    _updatingStatus = [aDecoder decodeObjectForKey:@"updatingStatus"];
    _category = [aDecoder decodeObjectForKey:@"category"];
    _updatedAlbum = [aDecoder decodeObjectForKey:@"new"];
    _longdescription = [aDecoder decodeObjectForKey:@"longDescription"];
    
    return self;
}

@end
