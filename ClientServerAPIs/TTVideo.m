//
//  TTVideo.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/6/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTVideo.h"

@implementation TTVideo

- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        
        NSLog(@"%@",[responseObject objectForKey:@"likes"]);
        
        self.likeCount = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"likes"] objectForKey:@"count"]];
        self.likeAllow = YES;
        
        self.title = [responseObject objectForKey:@"title"];
        
        self.videoid = [responseObject objectForKey:@"id"];
        self.owner_id = [NSString stringWithFormat:@"%ld",(long)[[responseObject objectForKey:@"owner_id"]integerValue]];
        self.photoURL = [responseObject objectForKey:@"photo_320"];
        self.description = [responseObject objectForKey:@"description"];
        
        //NSArray *fileArray = [responseObject objectForKey:@"files"];
        
        self.playerURl = [responseObject objectForKey:@"player"];
        
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
        
        [dateFormater setDateFormat:@"HH:mm:ss"];
        [dateFormater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3]];
        
        NSDate *durationTime = [NSDate dateWithTimeIntervalSince1970:[[responseObject objectForKey:@"duration"] floatValue]];
       self.duration = [dateFormater stringFromDate:durationTime];
        
        [dateFormater setDateFormat:@"dd MMM yyyy "];
        
        NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:[[responseObject objectForKey:@"date"] floatValue]];
        NSString *date = [dateFormater stringFromDate:dateTime];
        self.date = date;
        
    }
    return self;
}

@end
