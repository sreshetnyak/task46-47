//
//  TTWall.m
//  ClientServerAPIsBasics
//
//  Created by Sergey Reshetnyak on 5/30/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTWall.h"
#import "UIImageView+AFNetworking.h"
#import "TTServerManager.h"

@implementation TTWall


- (instancetype)initWithDictionary:(NSDictionary *) responseObject {

    self = [super init];
    if (self) {
        
        self.text = [responseObject objectForKey:@"text"];
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
        [dateFormater setDateFormat:@"dd MMM yyyy "];
        NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:[[responseObject objectForKey:@"date"] floatValue]];
        NSString *date = [dateFormater stringFromDate:dateTime];
        self.date = date;
        NSDictionary *dict = [[responseObject objectForKey:@"attachments"] objectAtIndex:0];

        if ([[dict objectForKey:@"type"] isEqualToString:@"photo"]) {
            
            self.postImageURL = [[dict objectForKey:@"photo"] objectForKey:@"photo_604"];
            self.postImageHight = [[[dict objectForKey:@"photo"] objectForKey:@"height"] integerValue];
            self.postImageWidth = [[[dict objectForKey:@"photo"] objectForKey:@"width"]integerValue];
            
        }
        
        self.ownerID = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"owner_id"]];
        
        self.postID = [responseObject objectForKey:@"id"];
        self.likeCount = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"likes"] objectForKey:@"count"]];
        self.likeAllow = [[[responseObject objectForKey:@"likes"] objectForKey:@"can_like"] boolValue];
        
        self.commentCount = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"comments"] objectForKey:@"count"]];
        
        self.fromUserID = [NSString stringWithFormat:@"%ld",(long)[[responseObject objectForKey:@"from_id"] integerValue]];

    }
    
    return self;
}

@end
