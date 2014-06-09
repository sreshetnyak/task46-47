//
//  TTUser.m
//  ClientServerAPIsBasics
//
//  Created by Sergey Reshetnyak on 5/29/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTUser.h"
#import "TTServerManager.h"

static const NSString * first_name = @"first_name";
static const NSString * last_name = @"last_name";
static const NSString * photo_100 = @"photo_100";
static const NSString * user_id = @"id";
static const NSString * university_name = @"university_name";
static const NSString * online = @"online";
static const NSString * photo_medium_rec = @"photo_medium_rec";


@implementation TTUser

- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        self.firstName = [responseObject objectForKey:first_name];
        self.lastName = [responseObject objectForKey:last_name];
        self.userIds = [NSString stringWithFormat:@"%ld",(long)[[responseObject objectForKey:user_id] integerValue]];
        self.photoURL = [responseObject objectForKey:photo_100];
        self.photoURLWall = [responseObject objectForKey:photo_medium_rec];
        self.universityName = [responseObject objectForKey:university_name];
        self.onlineStatus = [[responseObject objectForKey:online] boolValue];
    }
    return self;
}


@end
