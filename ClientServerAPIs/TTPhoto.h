//
//  TTPhoto.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/7/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTPhoto : NSObject

@property (strong,nonatomic) NSString *user_id;
@property (strong,nonatomic) NSString *photo_75;
@property (strong,nonatomic) NSString *photo_130;

- (instancetype)initWithDictionary:(NSDictionary *) responseObject;

@end
