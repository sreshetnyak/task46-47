//
//  TTWall.h
//  ClientServerAPIsBasics
//
//  Created by Sergey Reshetnyak on 5/30/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTUser;
@class TTGroup;

@interface TTWall : NSObject

@property (strong,nonatomic) NSString *text;
@property (strong,nonatomic) NSString *date;
@property (strong,nonatomic) NSString *postImageURL;
@property (assign,nonatomic) NSInteger postImageHight;
@property (assign,nonatomic) NSInteger postImageWidth;
@property (strong,nonatomic) NSString *fromUserID;
@property (strong,nonatomic) NSString *postID;
@property (strong,nonatomic) NSString *ownerID;
@property (strong,nonatomic) TTUser *fromUser;
@property (strong,nonatomic) TTGroup *fromGroup;
@property (assign,nonatomic) BOOL likeAllow;

@property (strong,nonatomic) NSString *likeCount;

@property (strong,nonatomic) NSString *commentCount;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
