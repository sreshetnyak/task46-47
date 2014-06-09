//
//  TTTopicsViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/7/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTTopicsViewController.h"
#import "TTServerManager.h"
#import "TTTopicsTableViewCell.h"
#import "TTUser.h"
#import "TTTopics.h"
#import "UIImageView+AFNetworking.h"
#import "TTDetailTopicsViewController.h"

@interface TTTopicsViewController () <UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) NSMutableArray *topicsArray;
@property (assign,nonatomic) BOOL loadingData;

@end

@implementation TTTopicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Topics";
    self.topicsArray = [NSMutableArray array];
    self.loadingData = YES;
    [self getTopicsFromServer];
    
    
}


- (void)getTopicsFromServer {
    
    
    [[TTServerManager sharedManager]getTopicsInGroupId:self.group.groupsID count:10 offset:[self.topicsArray count] onSuccess:^(NSArray *topicsGroupArray) {

        if ([topicsGroupArray count] > 0) {
            
            [self.topicsArray addObjectsFromArray:topicsGroupArray];
            
            NSMutableArray* newPaths = [NSMutableArray array];
            for (int i = (int)[self.topicsArray count] - (int)[topicsGroupArray count]; i < [self.topicsArray count]; i++) {
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
            [self getTopicsFromServer];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.topicsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"topicsCell";
    
    TTTopicsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[TTTopicsTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    TTTopics *topics = [self.topicsArray objectAtIndex:indexPath.row];
    
    cell.titleTopicLabel.text = topics.title;
    cell.commentsCountLabel.text = topics.comments;
    
    NSArray *strArray = [topics.last_comment componentsSeparatedByString:@"]"];
    
    if ([strArray count] > 1) {
        
        NSArray *newStrArray = [[strArray firstObject] componentsSeparatedByString:@"|"];
        
        cell.lastCommentLabel.text = [NSString stringWithFormat:@"%@%@",[newStrArray lastObject],[strArray lastObject]];
        
        
    } else {
        
        if (![topics.last_comment isEqualToString:@""]) {
            cell.lastCommentLabel.text = topics.last_comment;
        } else {
            cell.lastCommentLabel.text = @"...";
        }
        
        
    }
    
    cell.dateLastCommentLabel.text = topics.updated;
    cell.nameProfileLabel.text = [NSString stringWithFormat:@"%@ %@",topics.user.firstName,topics.user.lastName];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:topics.user.photoURL]];
    
    __weak TTTopicsTableViewCell *weakCell = cell;
    
    [cell.profileImageView setImageWithURLRequest:request
                               placeholderImage:nil
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            
                                            [UIView transitionWithView:weakCell.profileImageView
                                                              duration:0.3f
                                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                                            animations:^{
                                                                weakCell.profileImageView.image = image;
                                                                CALayer *imageLayer = weakCell.profileImageView.layer;
                                                                [imageLayer setCornerRadius:20];
                                                                [imageLayer setMasksToBounds:YES];
                                                                
                                                            } completion:NULL];
                                            
                                            
                                        }
                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                            
                                        }];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 86;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"detailTopicsSegue"]) {
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        TTTopics *topics = [self.topicsArray objectAtIndex:indexPath.row];
        TTDetailTopicsViewController *dest = [segue destinationViewController];
        dest.topics = topics;
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
