//
//  TTTopics.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/7/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTTopics.h"

@implementation TTTopics

- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        
        self.title = [responseObject objectForKey:@"title"];
        self.topicsid = [responseObject objectForKey:@"id"];
        self.last_comment = [responseObject objectForKey:@"last_comment"];
        self.updated_by = [NSString stringWithFormat:@"%ld",(long)[[responseObject objectForKey:@"updated_by"] integerValue]];
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
        [dateFormater setDateFormat:@"dd MMM HH:mm"];
        NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:[[responseObject objectForKey:@"updated"] floatValue]];
        NSString *date = [dateFormater stringFromDate:dateTime];
        self.updated = date;

        self.comments = [NSString stringWithFormat:@"%ld",(long)[[responseObject objectForKey:@"comments"] integerValue]];
        
    }
    return self;
}

@end
