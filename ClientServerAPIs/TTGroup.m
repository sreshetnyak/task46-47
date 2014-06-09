//
//  TTGroup.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/3/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTGroup.h"

static const NSString * description = @"description";
static const NSString * ids = @"id";
static const NSString * photo_200 = @"photo_200";
static const NSString * name = @"name";

@implementation TTGroup

- (instancetype)initWithDictionary:(NSDictionary *) responseObject {
    
    self = [super init];
    if (self) {
        self.descriptionGroup = [responseObject objectForKey:description];
        self.nameGroup = [responseObject objectForKey:name];
        self.groupsID = [responseObject objectForKey:ids];
        self.photoStringURL = [responseObject objectForKey:photo_200];
        self.albumsGroup = [NSString stringWithFormat:@"%ld",(long)[[[responseObject objectForKey:@"counters"] objectForKey:@"albums"] integerValue]];
        self.audiosGroup = [NSString stringWithFormat:@"%ld",(long)[[[responseObject objectForKey:@"counters"] objectForKey:@"audios"] integerValue]];
        self.docsGroup = [NSString stringWithFormat:@"%ld",(long)[[[responseObject objectForKey:@"counters"] objectForKey:@"docs"] integerValue]];
        self.photosGroup = [NSString stringWithFormat:@"%ld",(long)[[[responseObject objectForKey:@"counters"] objectForKey:@"photos"] integerValue]];
        self.topicsGroup = [NSString stringWithFormat:@"%ld",(long)[[[responseObject objectForKey:@"counters"] objectForKey:@"topics"] integerValue]];
        self.videosGroup = [NSString stringWithFormat:@"%ld",(long)[[[responseObject objectForKey:@"counters"] objectForKey:@"videos"] integerValue]];
    }
    return self;
}


@end
