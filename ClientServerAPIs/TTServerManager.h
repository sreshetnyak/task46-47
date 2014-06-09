//
//  TTServerManager.h
//  ClientServerAPIsBasics
//
//  Created by Sergey Reshetnyak on 5/29/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTUser.h"
#import "TTGroup.h"

@interface TTServerManager : NSObject

@property (strong,nonatomic) TTGroup *group;

+ (TTServerManager *)sharedManager;

- (void)getUserWithIds:(NSString *)ids onSuccess:(void (^) (TTUser *user)) success onFailure:(void (^) (NSError *error)) failure;

- (void)getCityWithIds:(NSString *)ids onSuccess:(void (^) (NSString *city)) success onFailure:(void (^) (NSError *error)) failure;

- (void)getCountryWithIds:(NSString *)ids onSuccess:(void (^) (NSString *country)) success onFailure:(void (^) (NSError *error)) failure;

- (void)getWallPostWithUserIds:(NSString *)ids count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *wallPost)) success onFailure:(void (^) (NSError *error)) failure;

- (void) authorizeUser:(void(^)(TTUser* user)) completion;

- (void)getGroupById:(NSString *)ids onSuccess:(void (^) (TTGroup *group)) success onFailure:(void (^) (NSError *error)) failure;

- (void)getWallPostWithGroupIds:(NSString *)ids count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *wallPost)) success onFailure:(void (^) (NSError *error)) failure;

- (void)getCommentById:(NSString *)ids ownerID:(NSString *)ownerIDs count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *wallComment))success onFailure:(void (^) (NSError *error)) failure;

- (void) postText:(NSString*)text onWall:(NSString*)groupID inPost:(NSString*)postID onSuccess:(void(^)(NSDictionary* result)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) postLikeOnWall:(NSString*)groupID inPost:(NSString*)postID type:(NSString *)type onSuccess:(void(^)(NSDictionary* result)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) postDeleteLikeOnWall:(NSString*)groupID inPost:(NSString*)postID type:(NSString *)type onSuccess:(void(^)(NSDictionary* result)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) postText:(NSString*) text image:(UIImage *)image onGroupWall:(NSString*) groupID onSuccess:(void(^)(id result)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void)getMembersInGroupId:(NSString *)ids count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *membersArray))success onFailure:(void (^) (NSError *error)) failure;

- (void)getVideoInGroupId:(NSString *)ids count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *videoGroupArray))success onFailure:(void (^) (NSError *error)) failure;

- (void)getDocumentInGroupId:(NSString *)ids count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *docGroupArray))success onFailure:(void (^) (NSError *error)) failure;

- (void)getTopicsInGroupId:(NSString *)ids count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *topicsGroupArray))success onFailure:(void (^) (NSError *error)) failure;

- (void)getCommentTopicById:(NSString *)ids ownerID:(NSString *)ownerIDs count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *wallComment))success onFailure:(void (^) (NSError *error)) failure;

- (void)postText:(NSString *) text inGroup:(NSString *) groupID onTopic:(NSString *)topicID onSuccess:(void(^)(id result)) success onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure;

- (void)getAlbumsGrouppById:(NSString *)ids count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *arrayWithAlbums))success onFailure:(void (^) (NSError *error)) failure;

- (void)getPhotosFromAlbumID:(NSString *)ids ownerID:(NSString *)ownerIDs count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *arrayWithPhotos))success onFailure:(void (^) (NSError *error)) failure;

- (void)postImageInAlbumsIds:(NSString *)ids image:(UIImage *)image onSuccess:(void (^)(id responseObject))success onFailure:(void (^)(NSError *error))failure;

@end
