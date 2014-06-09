//
//  TTComment.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/4/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTComment.h"

@implementation TTComment

- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        self.likeCount = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"likes"] objectForKey:@"count"]];
        self.likeAllow = [[[responseObject objectForKey:@"likes"] objectForKey:@"can_like"] boolValue];
        self.text = [responseObject objectForKey:@"text"];
        self.comentIDs = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"id"]];
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
        [dateFormater setDateFormat:@"dd MMM yyyy "];
        NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:[[responseObject objectForKey:@"date"] floatValue]];
        NSString *date = [dateFormater stringFromDate:dateTime];
        self.date = date;
        self.userIDs = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"from_id"]];
        
    }
    return self;
}

@end
