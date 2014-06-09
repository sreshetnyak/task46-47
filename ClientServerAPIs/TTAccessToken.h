//
//  TTAccessToken.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/3/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTAccessToken : NSObject

@property (strong, nonatomic) NSString* token;
@property (strong, nonatomic) NSDate* expirationDate;
@property (strong, nonatomic) NSString* userID;

@end
