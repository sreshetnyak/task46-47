//
//  TTPhoto.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/7/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTPhoto.h"

@implementation TTPhoto

- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        
        self.user_id = [responseObject objectForKey:@"user_id"];
        self.photo_75 = [responseObject objectForKey:@"photo_75"];
        self.photo_130 = [responseObject objectForKey:@"photo_130"];

    }
    return self;
}

@end
