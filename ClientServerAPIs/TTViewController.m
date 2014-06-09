//
//  TTViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/2/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTViewController.h"
#import "TTServerManager.h"
#import "TTInfoTableViewCell.h"
#import "TTPostTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "TTWall.h"
#import "TTPostViewController.h"
#import "TTCountersTableViewCell.h"
#import "TTAddPostTableViewCell.h"
#import "TTAddPostViewController.h"
#import "TTMembersViewController.h"
#import "TTVideoViewController.h"
#import "TTDocViewController.h"
#import "TTTopicsViewController.h"
#import "TTPhotosTableViewController.h"

#define DELTA_LABEL 49
#define DELTA_SCALE 0.4f
#define CONTENT_WIDTH 300.f

@interface TTViewController () <UITableViewDataSource,UITableViewDelegate,TTAddPostDelegete,TTCountersDelegete>

@property (strong,nonatomic) TTGroup *group;
@property (strong,nonatomic) NSMutableArray *wallPostArray;
@property (assign,nonatomic) BOOL loadingData;

@end

@implementation TTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.loadingData = YES;
    self.wallPostArray = [[NSMutableArray alloc]init];

    
    [[TTServerManager sharedManager] authorizeUser:^(TTUser *user) {
        
        NSLog(@"AUTHORIZED!");
        NSLog(@"%@ %@", user.firstName, user.lastName);
        
        [[TTServerManager sharedManager]getGroupById:@"58860049" onSuccess:^(TTGroup *group) {
            self.group = group;
            self.navigationItem.title = group.nameGroup;
            [self.tableView reloadData];
            [self getWallPostFromServer];

        } onFailure:^(NSError *error) {
            
        }];
        
    }];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.000];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self preferredStatusBarStyle];
}

- (void)getWallPostFromServer {

    [[TTServerManager sharedManager]getWallPostWithGroupIds:self.group.groupsID count:10 offset:[self.wallPostArray count] onSuccess:^(NSArray *wallPost) {
        
        
        if ([wallPost count] > 0) {
        
            [self.wallPostArray addObjectsFromArray:wallPost];
            
            NSMutableArray* newPaths = [NSMutableArray array];
            for (int i = (int)[self.wallPostArray count] - (int)[wallPost count]; i < [self.wallPostArray count]; i++) {
                [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:4]];
            }
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            self.loadingData = NO;
        }
        
    } onFailure:^(NSError *error) {
        
    }];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData)
        {
            self.loadingData = YES;
            [self getWallPostFromServer];
        }
    }
}

- (NSString *) stringByStrippingHTML:(NSString *)string {
    
    NSRange r;
    while ((r = [string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        
        string = [string stringByReplacingCharactersInRange:r withString:@""];
    }
    
    return string;
}

- (CGSize)newSizeFromImageHight:(NSInteger)hight width:(NSInteger)width {

    CGSize newSize = CGSizeZero;
    
    if (width > CONTENT_WIDTH) {
        newSize.width = CONTENT_WIDTH;
        newSize.height = CONTENT_WIDTH/width * hight;
    }
    
    return newSize;
}

- (void)addLike:(UIButton *)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    TTWall *wall = [self.wallPostArray objectAtIndex:indexPath.row];
    
    if (wall.likeAllow) {
        [[TTServerManager sharedManager]postLikeOnWall:wall.ownerID inPost:wall.postID type:@"post" onSuccess:^(NSDictionary *result) {
            
            [self updateWall];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            NSLog(@"%@",error);
        }];
    } else {
        
        [[TTServerManager sharedManager]postDeleteLikeOnWall:wall.ownerID inPost:wall.postID type:@"post" onSuccess:^(NSDictionary *result) {
            [self updateWall];
        } onFailure:^(NSError *error, NSInteger statusCode) {
            NSLog(@"%@",error);
        }];
        
    }
    
    
}

- (void)addPOstOnWall:(UIButton *)sender {
   
    TTAddPostViewController *vc = [[TTAddPostViewController alloc]init];
    vc.group = self.group;
    vc.delegate = self;
    
    UINavigationController *nv = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nv animated:YES completion:nil];

}

- (void)updateWall {
    
    [[TTServerManager sharedManager]getWallPostWithGroupIds:self.group.groupsID count:MAX(10, [self.wallPostArray count]) offset:0 onSuccess:^(NSArray *wallPost) {

        if ([wallPost count] > 0) {
            [self.wallPostArray removeAllObjects];
            [self.wallPostArray addObjectsFromArray:wallPost];
            [self.tableView reloadData];
            self.loadingData = NO;
        }

    } onFailure:^(NSError *error) {
        
    }];
}

- (void)collectionCellPressedAtIndex:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"members" sender:self];
        
    } else if (indexPath.row == 5) {
        [self performSegueWithIdentifier:@"videoSegue" sender:self];
        
    } else if (indexPath.row == 3) {
        [self performSegueWithIdentifier:@"documentSegue" sender:self];
        
    } else if (indexPath.row == 4) {
        [self performSegueWithIdentifier:@"topicsSegue" sender:self];
        
    } else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"photosSegue" sender:self];
        
    }
    
}

- (void)dealloc {
    NSLog(@"release");
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 1;
    } else if (section == 3) {
        return 1;
    } else {
        return [self.wallPostArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *infoIdentifier = @"infocell";
    static NSString *postIdentifier = @"postcell";
    static NSString *counterIdentifier = @"counterCell";
    static NSString *addPostIdentifier = @"addpostCell";
    static NSString *grayCellIdentifier = @"grayCell";

    
    if (indexPath.section == 0) {
        
        TTInfoTableViewCell *infoCell = [tableView dequeueReusableCellWithIdentifier:infoIdentifier];
        
        if (!infoCell) {
            infoCell = [[TTInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infoIdentifier];
        }
        
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:self.group.photoStringURL]];
        
        __weak TTInfoTableViewCell *weakCell = infoCell;
        
        [infoCell.groupPhotoView setImageWithURLRequest:request
                              placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           
                                           weakCell.groupPhotoView.image = image;
                                           CALayer *imageLayer = weakCell.groupPhotoView.layer;
                                           [imageLayer setCornerRadius:43];
                                           [imageLayer setMasksToBounds:YES];

                                       }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           
                                       }];
        infoCell.descriptionLabel.text = self.group.descriptionGroup;
        infoCell.nameLabel.text = self.group.nameGroup;
        
        return infoCell;
        
    } else if (indexPath.section == 1) {
        
        TTCountersTableViewCell *counterCell = [[TTCountersTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:counterIdentifier];
        
        counterCell.group = self.group;
        counterCell.delegete = self;
        
        return counterCell;
        
    } else if (indexPath.section == 2) {
        
        UITableViewCell *grayCell = [tableView dequeueReusableCellWithIdentifier:grayCellIdentifier];
        
        if (!grayCell) {
            grayCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:grayCellIdentifier];
        }

        grayCell.backgroundColor = [UIColor colorWithRed:0.871 green:0.882 blue:0.902 alpha:1.000];
        
        return grayCell;
        
    }else if (indexPath.section == 3) {
        
        TTAddPostTableViewCell *addPostCell = [tableView dequeueReusableCellWithIdentifier:addPostIdentifier];
               
        [addPostCell.addPostBtn addTarget:self action:@selector(addPOstOnWall:) forControlEvents:UIControlEventTouchUpInside];
        
        return addPostCell;
        
    } else if (indexPath.section == 4) {
        
        TTPostTableViewCell *postCell = [tableView dequeueReusableCellWithIdentifier:postIdentifier];
        
        if (!postCell) {
            postCell = [[TTPostTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postIdentifier];
        }
        
        TTWall *wall = [self.wallPostArray objectAtIndex:indexPath.row];
        
        postCell.dateLabel.text = wall.date;
        postCell.postTextLabel.text = [self stringByStrippingHTML:wall.text];
        

        
        
        postCell.addLikeBtn.frame = CGRectMake(postCell.addLikeBtn.frame.origin.x, postCell.addLikeBtn.frame.origin.y,[self widthOfTextForString:wall.likeCount maxSize:CGSizeMake(100, postCell.addLikeBtn.frame.size.height)], postCell.addLikeBtn.frame.size.height);
        
        postCell.addComentBtn.frame = CGRectMake(postCell.addComentBtn.frame.origin.x, postCell.addComentBtn.frame.origin.y,[self widthOfTextForString:wall.commentCount maxSize:CGSizeMake(100, postCell.addComentBtn.frame.size.height)], postCell.addComentBtn.frame.size.height);

        
        [postCell.addLikeBtn  setTitle:wall.likeCount forState:UIControlStateNormal];
        [postCell.addComentBtn  setTitle:wall.commentCount forState:UIControlStateNormal];

        [postCell.addLikeBtn addTarget:self action:@selector(addLike:) forControlEvents:UIControlEventTouchUpInside];
        
        UIFont* font = [UIFont systemFontOfSize:10.f];
        
        NSShadow* shadow = [[NSShadow alloc] init];
        shadow.shadowOffset = CGSizeMake(0, -1);
        shadow.shadowBlurRadius = 0;
        
        NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
        [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
        [paragraph setAlignment:NSTextAlignmentLeft];
        
        NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, paragraph, NSParagraphStyleAttributeName,shadow, NSShadowAttributeName, nil];
        
        CGRect rect = [[self stringByStrippingHTML:wall.text] boundingRectWithSize:CGSizeMake(postCell.postTextLabel.frame.size.width, CGFLOAT_MAX)
                                                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                        attributes:attributes
                                                                           context:nil];
        
        
        
        
        CGRect newFrame = postCell.postTextLabel.frame;
        newFrame.size.height = rect.size.height;
        postCell.postTextLabel.frame = newFrame;

        CALayer *imageLayerLike = postCell.addLikeBtn.layer;
        [imageLayerLike setCornerRadius:3];
        [imageLayerLike setMasksToBounds:YES];
        
        CALayer *imageLayerComent = postCell.addComentBtn.layer;
        [imageLayerComent setCornerRadius:3];
        [imageLayerComent setMasksToBounds:YES];
        
        postCell.addLikeBtn.frame = CGRectMake(postCell.addLikeBtn.frame.origin.x, newFrame.size.height + DELTA_LABEL + 10,postCell.addLikeBtn.frame.size.width,postCell.addLikeBtn.frame.size.height);
        postCell.addComentBtn.frame = CGRectMake(postCell.addComentBtn.frame.origin.x, newFrame.size.height + DELTA_LABEL + 10,postCell.addComentBtn.frame.size.width,postCell.addComentBtn.frame.size.height);
        
        
        
        
        postCell.userImageView.image = nil;
        postCell.postPhotoView.image = nil;
        postCell.userNameLabel.text = nil;
        
        
        NSURLRequest *request;
        
        if (wall.fromUser != nil) {

            request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:wall.fromUser.photoURL]];
            postCell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@",wall.fromUser.firstName,wall.fromUser.lastName];
            
        } else if (wall.fromGroup != nil) {
        
            request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:wall.fromGroup.photoStringURL]];
            postCell.userNameLabel.text = [NSString stringWithFormat:@"%@",wall.fromGroup.nameGroup];
        }
        
        __weak TTPostTableViewCell *weakPostCell = postCell;
        
        [postCell.userImageView setImageWithURLRequest:request
                                      placeholderImage:nil
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   
                                                   
                                                   weakPostCell.userImageView.image = image;
                                                   CALayer *imageLayer = weakPostCell.userImageView.layer;
                                                   [imageLayer setCornerRadius:20];
                                                   [imageLayer setMasksToBounds:YES];
                                                   
                                                   
                                               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                   
                                               }];

        
        if (wall.postImageURL != nil) {
            
            [[TTServerManager sharedManager]getUserWithIds:wall.fromUserID onSuccess:^(TTUser *user) {
                
                NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:wall.postImageURL]];
                
                __weak TTPostTableViewCell *weakPostCell = postCell;
                
                [postCell.userImageView setImageWithURLRequest:request
                                              placeholderImage:nil
                                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {

                                                           
                                                           weakPostCell.postPhotoView.image = image;
                                                           
                                                           CGSize size = [self newSizeFromImageHight:wall.postImageHight width:wall.postImageWidth];
                                                           
                                                           weakPostCell.postPhotoView.frame = CGRectMake(newFrame.origin.x, newFrame.size.height + DELTA_LABEL + 10 ,size.width,size.height);
                                                           weakPostCell.addLikeBtn.frame = CGRectMake(weakPostCell.addLikeBtn.frame.origin.x, size.height + DELTA_LABEL + 10 + 10 + newFrame.size.height ,weakPostCell.addLikeBtn.frame.size.width,weakPostCell.addLikeBtn.frame.size.height);
                                                           
                                                            weakPostCell.addComentBtn.frame = CGRectMake(weakPostCell.addComentBtn.frame.origin.x, size.height + DELTA_LABEL + 10 + 10 + newFrame.size.height ,weakPostCell.addComentBtn.frame.size.width,weakPostCell.addComentBtn.frame.size.height);
  
                                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {

                                                       }];
            } onFailure:^(NSError *error) {
                
            }];
            
        }
        
        
        return postCell;
        
    }
    
    return nil;
}

- (CGFloat)widthOfTextForString:(NSString *)aString maxSize:(CGSize)aSize {

    UIFont* font = [UIFont systemFontOfSize:15.f];
    
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0, -1);
    shadow.shadowBlurRadius = 0;
    
    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentLeft];
    
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, paragraph, NSParagraphStyleAttributeName,shadow, NSShadowAttributeName, nil];
    
    CGSize sizeOfText = [aString boundingRectWithSize: aSize
                                              options: (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                           attributes: attributes
                                              context: nil].size;
    
    return ceilf(sizeOfText.width + 35);
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        return 100;
    } else if (indexPath.section == 4) {
        
        TTWall *wall = [self.wallPostArray objectAtIndex:indexPath.row];
        
        TTPostTableViewCell *postCell = (TTPostTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        
        UIFont* font = [UIFont systemFontOfSize:10.f];
        
        NSShadow* shadow = [[NSShadow alloc] init];
        shadow.shadowOffset = CGSizeMake(0, -1);
        shadow.shadowBlurRadius = 0;
        
        NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
        [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
        [paragraph setAlignment:NSTextAlignmentLeft];
        
        NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, paragraph, NSParagraphStyleAttributeName,shadow, NSShadowAttributeName, nil];
        
        CGRect rect = [[self stringByStrippingHTML:wall.text] boundingRectWithSize:CGSizeMake(postCell.postTextLabel.frame.size.width, CGFLOAT_MAX)
                                                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                        attributes:attributes
                                                                           context:nil];
        
        
        CGRect newFrame = postCell.postTextLabel.frame;
        newFrame.size.height = rect.size.height;
        
        if (wall.postImageURL != nil) {
            
            CGSize size = [self newSizeFromImageHight:wall.postImageHight width:wall.postImageWidth];
            
            float height = newFrame.size.height + DELTA_LABEL + 10 + 10 + size.height + postCell.addLikeBtn.frame.size.height + 5;
            
            return height;
            
        } else {
            
            return newFrame.size.height + DELTA_LABEL + 10 + 5 + postCell.addLikeBtn.frame.size.height;
        }

        
    } else if (indexPath.section == 2) {
        return 20;
    } else if (indexPath.section == 3) {
        return 30;
    } else {
        return 45;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    
    if ([[segue identifier] isEqualToString: @"comments"]) {
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        TTWall *wall = [self.wallPostArray objectAtIndex:indexPath.row];
        TTPostViewController *dest = [segue destinationViewController];
        dest.wallPost = wall;
        
    } else if ([[segue identifier] isEqualToString:@"members"]) {
    
        TTMembersViewController *vc = [segue destinationViewController];
        vc.group = self.group;
    } else if ([[segue identifier] isEqualToString:@"videoSegue"]) {
        
        TTVideoViewController *vc = [segue destinationViewController];
        vc.group = self.group;
    } else if ([[segue identifier] isEqualToString:@"documentSegue"]) {
        
        TTDocViewController *vc = [segue destinationViewController];
        vc.group = self.group;
    }  else if ([[segue identifier] isEqualToString:@"topicsSegue"]) {
        
        TTTopicsViewController *vc = [segue destinationViewController];
        vc.group = self.group;
    } else if ([[segue identifier] isEqualToString:@"photosSegue"]) {
        
        TTPhotosTableViewController *vc = [segue destinationViewController];
        vc.group = self.group;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
