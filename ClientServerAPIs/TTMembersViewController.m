//
//  TTMembersViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/6/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTMembersViewController.h"
#import "TTMembersTableViewCell.h"
#import "TTServerManager.h"
#import "TTUser.h"
#import "UIImageView+AFNetworking.h"

@interface TTMembersViewController () <UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic) NSMutableArray *groupMembersArray;
@property (assign,nonatomic) BOOL loadingData;

@end

@implementation TTMembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Members";
    self.view.backgroundColor = [UIColor whiteColor];
    self.groupMembersArray = [NSMutableArray array];
    self.loadingData = YES;
    
    [self getFriendFromServer];
    
}

- (void)getFriendFromServer {
    
    
    [[TTServerManager sharedManager]getMembersInGroupId:self.group.groupsID count:10 offset:[self.groupMembersArray count] onSuccess:^(NSArray *membersArray) {
        
        if ([membersArray count] > 0) {
            
            [self.groupMembersArray addObjectsFromArray:membersArray];
            
            NSMutableArray* newPaths = [NSMutableArray array];
            for (int i = (int)[self.groupMembersArray count] - (int)[membersArray count]; i < [self.groupMembersArray count]; i++) {
                [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
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
            [self getFriendFromServer];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groupMembersArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"membersCell";
    
    TTMembersTableViewCell *cell = (TTMembersTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[TTMembersTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    TTUser *user = [self.groupMembersArray objectAtIndex:indexPath.row];
    
    cell.firstNameLabel.text = [NSString stringWithFormat:@"%@",user.firstName];
    cell.lastNameLabel.text = [NSString stringWithFormat:@"%@",user.lastName];
    
    cell.photoView.image = nil;
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:user.photoURL]];
    
    __weak TTMembersTableViewCell *weakCell = cell;
    
    [cell.photoView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       
                                       [UIView transitionWithView:weakCell.photoView
                                                         duration:0.3f
                                                          options:UIViewAnimationOptionTransitionCrossDissolve
                                                       animations:^{
                                                           weakCell.photoView.image = image;
                                                           CALayer *imageLayer = weakCell.photoView.layer;
                                                           [imageLayer setCornerRadius:28];
                                                           [imageLayer setMasksToBounds:YES];
                                                           
                                                       } completion:NULL];
                                       
                                       
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       
                                   }];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
