//
//  Song.m
//  Daoting
//
//  Created by Kevin on 14-5-16.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "Song.h"

@implementation Song


@synthesize description;

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.songNumber forKey:@"songNumber"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.duration forKey:@"duration"];
    [aCoder encodeObject:self.Url forKey:@"url"];
    [aCoder encodeObject:self.filePath forKey:@"filePath"];
    [aCoder encodeObject:self.price forKey:@"key"];
    [aCoder encodeDouble:self.progress forKey:@"progress"];
    [aCoder encodeObject:self.updatedSong forKey:@"new"];
    [aCoder encodeObject:self.description forKey:@"description"];
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    _songNumber = [aDecoder decodeObjectForKey:@"songNumber"];
    _title =[aDecoder decodeObjectForKey:@"title"];
    _duration =[aDecoder decodeObjectForKey:@"duration"];
    _Url = [aDecoder decodeObjectForKey:@"url"];
    _filePath = [aDecoder decodeObjectForKey:@"filePath"];
    _price = [aDecoder decodeObjectForKey:@"key"];
    _progress = [aDecoder decodeDoubleForKey:@"progress"];
    _updatedSong = [aDecoder decodeObjectForKey:@"new"];
    description = [aDecoder decodeObjectForKey:@"description"];
    
    return self;
}

@end
