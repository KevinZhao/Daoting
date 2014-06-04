//
//  Song.m
//  Daoting
//
//  Created by Kevin on 14-5-16.
//  Copyright (c) 2014年 赵 克鸣. All rights reserved.
//

#import "Song.h"

@implementation Song


- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.songNumber forKey:@"AddressCard_name"];
    [aCoder encodeObject:self.title forKey:@"AddressCard_email"];
    [aCoder encodeObject:self.duration forKey:@"AddressCard_salary"];
    [aCoder encodeObject:self.Url forKey:@"url"];
    [aCoder encodeObject:self.filePath forKey:@"filePath"];
    [aCoder encodeObject:self.price forKey:@"key"];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    _songNumber = [aDecoder decodeObjectForKey:@"AddressCard_name"];
    _title =[aDecoder decodeObjectForKey:@"AddressCard_email"];
    _duration =[aDecoder decodeObjectForKey:@"AddressCard_salary"];
    _Url = [aDecoder decodeObjectForKey:@"url"];
    _filePath = [aDecoder decodeObjectForKey:@"filePath"];
    _price = [aDecoder decodeObjectForKey:@"key"];
    
    return self;
}

@end
