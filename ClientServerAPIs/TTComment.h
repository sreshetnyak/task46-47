//
//  TTComment.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/4/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTUser;

@interface TTComment : NSObject

@property (strong,nonatomic) NSString *text;
@property (strong,nonatomic) NSString *date;
@property (strong,nonatomic) NSString *likeCount;
@property (assign,nonatomic) BOOL likeAllow;
@property (strong,nonatomic) NSString *userIDs;
@property (strong,nonatomic) NSString *comentIDs;
@property (strong,nonatomic) TTUser *user;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
