//
//  TTGroup.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/3/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTGroup : NSObject

@property (strong,nonatomic) NSString *descriptionGroup;
@property (strong,nonatomic) NSString *groupsID;
@property (strong,nonatomic) NSString *photoStringURL;
@property (strong,nonatomic) NSString *nameGroup;
@property (strong,nonatomic) NSString *membersGroup;
@property (strong,nonatomic) NSString *albumsGroup;
@property (strong,nonatomic) NSString *audiosGroup;
@property (strong,nonatomic) NSString *docsGroup;
@property (strong,nonatomic) NSString *photosGroup;
@property (strong,nonatomic) NSString *topicsGroup;
@property (strong,nonatomic) NSString *videosGroup;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
