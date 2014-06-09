//
//  TTServerManager.m
//  ClientServerAPIsBasics
//
//  Created by Sergey Reshetnyak on 5/29/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTServerManager.h"
#import "AFNetworking.h"
#import "TTWall.h"
#import "TTGroup.h"
#import "TTVideo.h"
#import "TTComment.h"
#import "TTLoginViewController.h"
#import "TTAccessToken.h"
#import "TTDocuments.h"
#import "TTTopics.h"
#import "TTAlbum.h"
#import "TTPhoto.h"


static NSString* kToken = @"kToken";
static NSString* kExpirationDate = @"kExpirationDate";
static NSString* kUserID = @"kUserID";

@interface TTServerManager ()

@property (strong,nonatomic) AFHTTPRequestOperationManager *requestOperationManager;
@property (strong, nonatomic) TTAccessToken *accessToken;

@end

@implementation TTServerManager

+ (TTServerManager *)sharedManager {
    
    static TTServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[TTServerManager alloc]init];
        
    });
    
    return manager;
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:@"https://api.vk.com/method/"]];
        self.accessToken = [[TTAccessToken alloc]init];
        [self loadSettings];
    }
    return self;
}

- (void) saveSettings:(TTAccessToken *)token {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:token.token forKey:kToken];
    [userDefaults setObject:token.expirationDate forKey:kExpirationDate];
    [userDefaults setObject:token.userID forKey:kUserID];
    
    [userDefaults synchronize];
}

- (void) loadSettings {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    self.accessToken.token = [userDefaults objectForKey:kToken];
    self.accessToken.expirationDate = [userDefaults objectForKey:kExpirationDate];
    self.accessToken.userID = [userDefaults objectForKey:kUserID];
    
}

- (void) authorizeUser:(void(^)(TTUser* user)) completion {
    
    if ([self.accessToken.expirationDate compare:[NSDate date]] == NSOrderedDescending) {
        
        [self getUserWithIds:self.accessToken.userID onSuccess:^(TTUser *user) {
            
            if (completion) {
                completion(user);
            }
            
        } onFailure:^(NSError *error) {
            if (completion) {
                completion(nil);
            }
        }];
        
    } else {
    

        TTLoginViewController* vc = [[TTLoginViewController alloc] initWithCompletionBlock:^(TTAccessToken *token) {
            
            [self saveSettings:token];
            self.accessToken = token;

            
            if (token) {
                
                [self getUserWithIds:self.accessToken.userID onSuccess:^(TTUser *user) {
                    
                    if (completion) {
                        completion(user);
                    }
                    
                } onFailure:^(NSError *error) {
                    if (completion) {
                        completion(nil);
                    }
                }];
                
            } else if (completion) {
                completion(nil);
            }
            
        }];
        
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:vc];
        
        UIViewController* mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
        
        [mainVC presentViewController:nav animated:YES completion:nil];
        
    }
}

- (void)postImageInAlbumsIds:(NSString *)ids image:(UIImage *)image onSuccess:(void (^)(id responseObject))success onFailure:(void (^)(NSError *error))failure {
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.group.groupsID,@"group_id",ids,@"album_id",@"5.21",@"v",self.accessToken.token,@"access_token", nil];
    
    [self.requestOperationManager GET:@"photos.getUploadServer" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *objects = [responseObject objectForKey:@"response"];

        NSString *upload_url = [objects objectForKey:@"upload_url"];

        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        [manager POST:upload_url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            [formData appendPartWithFileData:imageData name:@"file1" fileName:@"file1.png" mimeType:@"image/jpeg"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"Success: %@", responseObject);
            
            NSString *aid = [responseObject objectForKey:@"aid"];
            NSString *gid = [responseObject objectForKey:@"gid"];
            NSString *hash = [responseObject objectForKey:@"hash"];
            NSString *photos_list = [responseObject objectForKey:@"photos_list"];
            NSString *server = [responseObject objectForKey:@"server"];
            
            
            
            NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:aid,@"album_id",gid,@"group_id",server,@"server",photos_list,@"photos_list",hash,@"hash",@"5.21",@"v",self.accessToken.token,@"access_token", nil];
            
            [self.requestOperationManager GET:@"photos.save" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSLog(@"Success: %@", responseObject);
                success(responseObject);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}

- (void)getUserWithIds:(NSString *)ids onSuccess:(void (^)(TTUser *user))success onFailure:(void (^)(NSError *))failure {
    
    __block TTUser *user = nil;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:ids,@"user_ids",@"photo_100,city,sex,bdate,city,country,online,education,counters",@"fields", nil];
    
    [self.requestOperationManager GET:@"users.get" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        NSArray *objects = [responseObject objectForKey:@"response"];
        user = [[TTUser alloc]initWithDictionary:[objects firstObject]];
        
        [[TTServerManager sharedManager]getCityWithIds:[[objects firstObject] objectForKey:@"city"] onSuccess:^(NSString *city) {
            
            user.cityName = city;
            
            [[TTServerManager sharedManager]getCountryWithIds:[[objects firstObject] objectForKey:@"country"] onSuccess:^(NSString *country) {
                
                user.countryName = country;
                dispatch_group_leave(group);
                
            } onFailure:^(NSError *error) {
                
            }];
            
            
        } onFailure:^(NSError *error) {
            
        }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        success(user);
    });

}


- (void)getTopicsInGroupId:(NSString *)ids count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *topicsGroupArray))success onFailure:(void (^) (NSError *error)) failure {
    
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:ids,@"group_id",@(count),@"count",@(offset),@"offset",@"5.21",@"v",@"1",@"extended",@"2",@"preview",@"0",@"preview_length",self.accessToken.token,@"access_token", nil];
    
    [self.requestOperationManager GET:@"board.getTopics" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *objects = [responseObject objectForKey:@"response"];
        
        NSArray *topicsArray = [objects objectForKey:@"items"];
        NSArray *profileArray = [objects objectForKey:@"profiles"];
        
        NSMutableArray *arrayWithData = [[NSMutableArray alloc]init];
        NSMutableArray *arrayWithLastUser = [[NSMutableArray alloc]init];
        
        for (int i = 0; i < [profileArray count]; i++) {
            TTUser *user = [[TTUser alloc]initWithDictionary:[profileArray objectAtIndex:i]];
            [arrayWithLastUser addObject:user];
        }
        
        for (int i = 0; i < [topicsArray count]; i++) {
            
            TTTopics *topics = [[TTTopics alloc]initWithDictionary:[topicsArray objectAtIndex:i]];
            
            for (TTUser *user in arrayWithLastUser) {
                
                if ([topics.updated_by isEqualToString:user.userIds]) {
                    topics.user = user;
                    [arrayWithData addObject:topics];
                    break;
                }
                
            }
            
        }
        

        
        success(arrayWithData);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
}


- (void)getDocumentInGroupId:(NSString *)ids count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *docGroupArray))success onFailure:(void (^) (NSError *error)) failure {
    
    NSString *idGroup = [NSString stringWithFormat:@"%@",ids];
    
    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:idGroup,@"owner_id",@(count),@"count",@(offset),@"offset",@"5.21",@"v",self.accessToken.token,@"access_token", nil];
    
    [self.requestOperationManager GET:@"docs.get" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *objects = [responseObject objectForKey:@"response"];
        
        NSArray *documentsArray = [objects objectForKey:@"items"];
        
        NSMutableArray *arrayWithData = [[NSMutableArray alloc]init];
        
        for (int i = 0; i < [documentsArray count]; i++) {
            
            TTDocuments *doc = [[TTDocuments alloc]initWithDictionary:[documentsArray objectAtIndex:i]];
            
            [arrayWithData addObject:doc];
            
        }
        
        success(arrayWithData);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
}



- (void)getVideoInGroupId:(NSString *)ids count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *videoGroupArray))success onFailure:(void (^) (NSError *error)) failure {
    
    NSString *idGroup = [NSString stringWithFormat:@"%@",ids];
    
    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:idGroup,@"owner_id",@(count),@"count",@(offset),@"offset",@"5.21",@"v",@"320",@"width",@"0",@"extended",self.accessToken.token,@"access_token", nil];
    
    [self.requestOperationManager GET:@"video.get" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *objects = [responseObject objectForKey:@"response"];
        
        NSArray *videoArray = [objects objectForKey:@"items"];
        
        NSMutableArray *arrayWithVideo = [[NSMutableArray alloc]init];
        
        for (int i = 0; i < [videoArray count]; i++) {
            
            TTVideo *user = [[TTVideo alloc]initWithDictionary:[videoArray objectAtIndex:i]];
            
            [arrayWithVideo addObject:user];
            
        }

        success(arrayWithVideo);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
}


- (void)getMembersInGroupId:(NSString *)ids count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *membersArray))success onFailure:(void (^) (NSError *error)) failure {
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:ids,@"group_id",@(count),@"count",@(offset),@"offset",@"5.21",@"v",@"id_asc",@"sort",@"first_name,last_name,photo_100",@"fields",self.accessToken.token,@"access_token", nil];
    
    [self.requestOperationManager GET:@"groups.getMembers" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *objects = [responseObject objectForKey:@"response"];
        
        NSArray *userArray = [objects objectForKey:@"items"];
        
        NSMutableArray *arrayWithMembers = [[NSMutableArray alloc]init];
        
        for (int i = 0; i < [userArray count]; i++) {
            
            TTUser *user = [[TTUser alloc]initWithDictionary:[userArray objectAtIndex:i]];

            [arrayWithMembers addObject:user];
            
        }
        
        
        success(arrayWithMembers);

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
}


- (void)getGroupMembersCountById:(NSString *)ids onSuccess:(void (^) (NSString *membersCount))success onFailure:(void (^) (NSError *error)) failure {
    
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:ids,@"group_id",@"0",@"offset",@"0",@"count",@"5.21",@"v", nil];
    
    [self.requestOperationManager GET:@"groups.getMembers" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *objects = [responseObject objectForKey:@"response"];
        
        NSString *membersCount = [NSString stringWithFormat:@"%ld",(long)[[objects objectForKey:@"count"] integerValue]];
        
        
        
        success(membersCount);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
}

- (void)getGroupById:(NSString *)ids onSuccess:(void (^) (TTGroup *group))success onFailure:(void (^) (NSError *error)) failure {
    
    dispatch_group_t grp = dispatch_group_create();
    dispatch_group_enter(grp);
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:ids,@"group_ids",@"counters",@"fields",@"5.21",@"v", nil];
    
    [self.requestOperationManager GET:@"groups.getById" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSArray *objects = [responseObject objectForKey:@"response"];
        
        TTGroup *group = [[TTGroup alloc]initWithDictionary:[objects firstObject]];
        
        [[TTServerManager sharedManager]getGroupMembersCountById:group.groupsID onSuccess:^(NSString *membersCount) {
            
            group.membersGroup = membersCount;
            
            self.group = group;
            
            dispatch_group_leave(grp);
            
        } onFailure:^(NSError *error) {
            
        }];
        
        dispatch_group_notify(grp, dispatch_get_main_queue(), ^{
            success(group);
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
}

- (void)getPhotosFromAlbumID:(NSString *)ids ownerID:(NSString *)ownerIDs count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *arrayWithPhotos))success onFailure:(void (^) (NSError *error)) failure {

    NSString *idGroup = [NSString stringWithFormat:@"%@",ownerIDs];
    
    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:idGroup,@"owner_id",ids,@"album_id",@"1",@"extended", @(count),@"count",@(offset),@"offset",@"5.21",@"v",self.accessToken.token,@"access_token", nil];
    
    [self.requestOperationManager GET:@"photos.get" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *objects = [responseObject objectForKey:@"response"];
        
        NSArray *photosArray = [objects objectForKey:@"items"];
        
        NSMutableArray *arrayWithPhotos = [[NSMutableArray alloc]init];
        
        for (int i = 0; i < [photosArray count]; i++) {

            TTPhoto *photo = [[TTPhoto alloc]initWithDictionary:[photosArray objectAtIndex:i]];
            
            [arrayWithPhotos addObject:photo];
        }
        
        success(arrayWithPhotos);

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];


}

- (void)getAlbumsGrouppById:(NSString *)ids count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *arrayWithAlbums))success onFailure:(void (^) (NSError *error)) failure {
    
    NSString *idGroup = [NSString stringWithFormat:@"%@",ids];
    
    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:idGroup,@"owner_id",@(count),@"count",@(offset),@"offset",@"5.21",@"v",self.accessToken.token,@"access_token", nil];
    
    [self.requestOperationManager GET:@"photos.getAlbums" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *objects = [responseObject objectForKey:@"response"];
        
        NSArray *commentsArray = [objects objectForKey:@"items"];
        
        NSMutableArray *arrayWithAlbums = [[NSMutableArray alloc]init];
        
        for (int i = 0; i < [commentsArray count]; i++) {

            TTAlbum *album = [[TTAlbum alloc]initWithDictionary:[commentsArray objectAtIndex:i]];
            
            [arrayWithAlbums addObject:album];
            
        }

            
        success(arrayWithAlbums);
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
}


- (void)getCommentTopicById:(NSString *)ids ownerID:(NSString *)ownerIDs count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *wallComment))success onFailure:(void (^) (NSError *error)) failure {
    
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:ids,@"topic_id",ownerIDs,@"group_id",@"1",@"need_likes",@"0",@"extended",@(count),@"count",@(offset),@"offset",@"5.21",@"v",@"desc",@"sort",self.accessToken.token,@"access_token", nil];
    
    [self.requestOperationManager GET:@"board.getComments" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *objects = [responseObject objectForKey:@"response"];
        
        NSArray *commentsArray = [objects objectForKey:@"items"];
        
        NSMutableArray *arrayWithWallComent = [[NSMutableArray alloc]init];
        
        dispatch_group_t group = dispatch_group_create();
        
        for (int i = 0; i < [commentsArray count]; i++) {
            
            dispatch_group_enter(group);
            TTComment *coment = [[TTComment alloc]initWithDictionary:[commentsArray objectAtIndex:i]];
            
            [self getUserWithIds:coment.userIDs onSuccess:^(TTUser *user) {
                
                coment.user = user;
                
                dispatch_group_leave(group);
                
            } onFailure:^(NSError *error) {
                
            }];
            
            [arrayWithWallComent addObject:coment];
            
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            
            success(arrayWithWallComent);
            
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
}


- (void)getCommentById:(NSString *)ids ownerID:(NSString *)ownerIDs count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *wallComment))success onFailure:(void (^) (NSError *error)) failure {
    
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:ownerIDs,@"owner_id",ids,@"post_id",@"1",@"need_likes",@(count),@"count",@(offset),@"offset",@"5.21",@"v",@"desc",@"sort",self.accessToken.token,@"access_token", nil];
    
    [self.requestOperationManager GET:@"wall.getComments" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *objects = [responseObject objectForKey:@"response"];
        
        NSArray *commentsArray = [objects objectForKey:@"items"];
        
        NSMutableArray *arrayWithWallComent = [[NSMutableArray alloc]init];
        
        dispatch_group_t group = dispatch_group_create();
        
        for (int i = 0; i < [commentsArray count]; i++) {
            
            dispatch_group_enter(group);
            TTComment *coment = [[TTComment alloc]initWithDictionary:[commentsArray objectAtIndex:i]];
            
            [self getUserWithIds:coment.userIDs onSuccess:^(TTUser *user) {
                
                NSLog(@"%d",i);
                
                coment.user = user;
                
                dispatch_group_leave(group);
                
            } onFailure:^(NSError *error) {
                
            }];
            
            [arrayWithWallComent addObject:coment];
            
        }

        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSLog(@"finish");
            
            NSArray *temp = [arrayWithWallComent sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                
                return [[(TTComment*) obj1 date] compare:[(TTComment*) obj2 date]];
                
            }];
            
            success(temp);
            
        });
        
        
        //success(arrayWithWallComent);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    
}


- (void) postText:(NSString*)text onWall:(NSString*)groupID inPost:(NSString*)postID onSuccess:(void(^)(NSDictionary* result)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    if (![groupID hasPrefix:@"-"]) {
        groupID = [@"-" stringByAppendingString:groupID];
    }
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:groupID,@"owner_id",postID,@"post_id",text,@"text",self.accessToken.token, @"access_token", nil];
    
    [self.requestOperationManager POST:@"wall.addComment" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
        
         NSLog(@"JSON: %@", responseObject);
         
         if (success) {
             success(responseObject);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
    
    
}


- (void)postText:(NSString *) text inGroup:(NSString *) groupID onTopic:(NSString *)topicID onSuccess:(void(^)(id result)) success onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:groupID,@"group_id",topicID,@"topic_id",text,@"text",@"5.21",@"v",self.accessToken.token, @"access_token", nil];
    
    [self.requestOperationManager POST:@"board.addComment" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
    
    
}



- (void) postText:(NSString*) text image:(UIImage *)image onGroupWall:(NSString*) groupID onSuccess:(void(^)(id result)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSString *idGroup = [NSString stringWithFormat:@"%@",groupID];
    
    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }
    
    
    if (image != nil) {
        
        
        NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.group.groupsID,@"group_id",@"5.21",@"v",self.accessToken.token,@"access_token", nil];
        
        [self.requestOperationManager GET:@"photos.getWallUploadServer" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            
            NSDictionary *objects = [responseObject objectForKey:@"response"];
            
            NSString *upload_url = [objects objectForKey:@"upload_url"];
            NSString *user_id = [objects objectForKey:@"user_id"];
            
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            
            [manager POST:upload_url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                
                [formData appendPartWithFileData:imageData name:@"file1" fileName:@"file1.png" mimeType:@"image/jpeg"];
                
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSLog(@"Success: %@", responseObject);

                NSString *hash = [responseObject objectForKey:@"hash"];
                NSString *photo = [responseObject objectForKey:@"photo"];
                NSString *server = [responseObject objectForKey:@"server"];

                
                NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:user_id,@"user_id",self.group.groupsID,@"group_id",server,@"server",photo,@"photo",hash,@"hash",@"5.21",@"v",self.accessToken.token,@"access_token", nil];
                
                [self.requestOperationManager GET:@"photos.saveWallPhoto" parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSLog(@"Success: %@", responseObject);
                    
                    NSArray *objects = [responseObject objectForKey:@"response"];
                    NSDictionary *dict = [objects firstObject];
                    NSString *owner_id = [dict objectForKey:@"owner_id"];
                     NSString *media_id = [dict objectForKey:@"id"];
                    //success(responseObject);
                    //photo100172_166443618
                    NSString *attachments = [NSString stringWithFormat:@"photo%@_%@",owner_id,media_id];
                    
                    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:idGroup,@"owner_id",text,@"message",attachments,@"attachments",self.accessToken.token, @"access_token", nil];
                    
                    [self.requestOperationManager POST:@"wall.post" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
                        
                        NSLog(@"JSON: %@", responseObject);
                        
                        if (success) {
                            success(responseObject);
                        }
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        
                        //NSLog(@"Error: %@", error);
                        
                        if (failure) {
                            failure(error, operation.response.statusCode);
                        }
                    }];
                    
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];

        
        
    } else {
        
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:idGroup,@"owner_id",text,@"message",self.accessToken.token, @"access_token", nil];
        
        [self.requestOperationManager POST:@"wall.post" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
            
            NSLog(@"JSON: %@", responseObject);
             
             if (success) {
                 success(responseObject);
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             //NSLog(@"Error: %@", error);
             
             if (failure) {
                 failure(error, operation.response.statusCode);
             }
         }];
    }
    
}

- (void) postLikeOnWall:(NSString*)groupID inPost:(NSString*)postID type:(NSString *)type onSuccess:(void(^)(NSDictionary* result)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    NSString *idGroup = [NSString stringWithFormat:@"%@",groupID];

    if ([type isEqualToString:@"topic_comment"]) {
        
        if (![idGroup hasPrefix:@"-"]) {
            idGroup = [@"-" stringByAppendingString:idGroup];
        }
        
    }
    
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:type,@"type",idGroup,@"owner_id",postID,@"item_id",@"5.21",@"v",self.accessToken.token, @"access_token", nil];
    
    [self.requestOperationManager POST:@"likes.add" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@", error);
        
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
    
}

- (void) postDeleteLikeOnWall:(NSString*)groupID inPost:(NSString*)postID type:(NSString *)type onSuccess:(void(^)(NSDictionary* result)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    NSString *idGroup = [NSString stringWithFormat:@"%@",groupID];
    
    if ([type isEqualToString:@"topic_comment"]) {
        
        if (![idGroup hasPrefix:@"-"]) {
            idGroup = [@"-" stringByAppendingString:idGroup];
        }
        
    }
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:type,@"type",idGroup,@"owner_id",postID,@"item_id",@"5.21",@"v",self.accessToken.token, @"access_token", nil];
    
    [self.requestOperationManager POST:@"likes.delete" parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        if (failure) {
            failure(error, operation.response.statusCode);
        }
    }];
    
}


- (void)getWallPostWithGroupIds:(NSString *)ids count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *wallPost)) success onFailure:(void (^) (NSError *error)) failure {
    
    NSString *idGroup = [NSString stringWithFormat:@"%@",ids];
    
    if (![idGroup hasPrefix:@"-"]) {
        idGroup = [@"-" stringByAppendingString:idGroup];
    }
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:idGroup,@"owner_id",@(count),@"count",@(offset),@"offset",@"all",@"filter",@"1",@"extended",@"5.21",@"v",self.accessToken.token,@"access_token", nil];
    
    [self.requestOperationManager GET:@"wall.get" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *objects = [responseObject objectForKey:@"response"];
        
        NSArray *wallArray = [objects objectForKey:@"items"];
        
        NSArray *profilesArray = [objects objectForKey:@"profiles"];
        
        NSMutableArray *arrayWithProfiles = [[NSMutableArray alloc]init];
        
        for (NSDictionary *dict in profilesArray) {
            
            TTUser *user = [[TTUser alloc]initWithDictionary:dict];
            
            [arrayWithProfiles addObject:user];
            
        }

        TTGroup *group = [[TTGroup alloc]initWithDictionary:[[objects objectForKey:@"groups"] objectAtIndex:0]];

        NSMutableArray *arrayWithWall = [[NSMutableArray alloc]init];
        
        
        for (int i = 0; i < [wallArray count]; i++) {
            
            TTWall *wall = [[TTWall alloc]initWithDictionary:[wallArray objectAtIndex:i]];

            if ([wall.fromUserID hasPrefix:@"-"]) {
                
                wall.fromGroup = group;
                [arrayWithWall addObject:wall];
                continue;
            }

            for (TTUser *user in arrayWithProfiles) {
                
                if ([wall.fromUserID isEqualToString:user.userIds]) {
                    
                    wall.fromUser = user;
                    [arrayWithWall addObject:wall];
                    break;
                }
                
            }

        }

        success(arrayWithWall);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@", error);
        failure(error);
    }];
    
    
    
}


- (void)getCityWithIds:(NSString *)ids onSuccess:(void (^) (NSString *city)) success onFailure:(void (^) (NSError *error)) failure {
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:ids,@"city_ids", nil];
    
    [self.requestOperationManager GET:@"database.getCitiesById" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *objects = [responseObject objectForKey:@"response"];
        NSString* city = [[objects firstObject] objectForKey:@"name"];
        success(city);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@", error);
        failure(error);
    }];
    
}


- (void)getCountryWithIds:(NSString *)ids onSuccess:(void (^) (NSString *country)) success onFailure:(void (^) (NSError *error)) failure {

    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:ids,@"country_ids", nil];
    
    [self.requestOperationManager GET:@"database.getCountriesById" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        
        NSArray *objects = [responseObject objectForKey:@"response"];
        NSString* country = [[objects firstObject] objectForKey:@"name"];
        success(country);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failure(error);
    }];
    
}

- (void)getWallPostWithUserIds:(NSString *)ids count:(NSInteger)count offset:(NSInteger)offset onSuccess:(void (^) (NSArray *wallPost)) success onFailure:(void (^) (NSError *error)) failure {
    
    
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:ids,@"owner_id",@(count),@"count",@(offset),@"offset",@"owner",@"filter", nil];
    
    [self.requestOperationManager GET:@"wall.get" parameters:paramDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSArray *objects = [responseObject objectForKey:@"response"];
        
        NSMutableArray *arrayWithWallPost = [[NSMutableArray alloc]init];
        
        for (int i = 1; i < [objects count]; i++) {
            
            TTWall *wall = [[TTWall alloc]initWithDictionary:[objects objectAtIndex:i]];
            [arrayWithWallPost addObject:wall];
            
        }
        
        success(arrayWithWallPost);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failure(error);
    }];
    
}

@end
