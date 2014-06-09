//
//  TTVideoViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/6/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTVideoViewController.h"
#import "TTVideoTableViewCell.h"
#import "TTServerManager.h"
#import "TTVideo.h"
#import "UIImageView+AFNetworking.h"
#import <MediaPlayer/MediaPlayer.h>

@interface TTVideoViewController () <UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic) NSMutableArray *videoArray;
@property (strong,nonatomic) MPMoviePlayerController *moviePlayer;
@property (assign,nonatomic) BOOL loadingData;

@end

@implementation TTVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Videos";
    self.view.backgroundColor = [UIColor whiteColor];
    self.videoArray = [NSMutableArray array];
    self.loadingData = YES;
    
    [self getVideoFromServer];
    
}

- (void)getVideoFromServer {
    
    
    [[TTServerManager sharedManager]getVideoInGroupId:self.group.groupsID count:10 offset:[self.videoArray count] onSuccess:^(NSArray *videoGroupArray) {
        
        if ([videoGroupArray count] > 0) {
            
            [self.videoArray addObjectsFromArray:videoGroupArray];
            
            NSMutableArray* newPaths = [NSMutableArray array];
            for (int i = (int)[self.videoArray count] - (int)[videoGroupArray count]; i < [self.videoArray count]; i++) {
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
            [self getVideoFromServer];
        }
    }
}

- (void)playVideo:(UIButton *)sender {

    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    NSLog(@"%ld",(long)indexPath.row);
    
    TTVideo *video = [self.videoArray objectAtIndex:indexPath.row];
    
    NSURL *url = [[NSURL alloc] initWithString:video.playerURl];
    
    TTVideoTableViewCell *cell = (TTVideoTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([[url host] isEqualToString:@"www.youtube.com"]) {
        [cell.youtubeView playVideo];
    } else {
        
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDonePressed:) name:MPMoviePlayerDidExitFullscreenNotification object:self.moviePlayer];
        
        self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
        [self.moviePlayer play];
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
        
    }
    
}

- (void) moviePlayBackDonePressed:(NSNotification*)notification {
    
    [self.moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:self.moviePlayer];

    if ([self.moviePlayer respondsToSelector:@selector(setFullscreen:animated:)]) {
        [self.moviePlayer.view removeFromSuperview];
    }
    self.moviePlayer = nil;
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    [self.moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    
    if ([self.moviePlayer respondsToSelector:@selector(setFullscreen:animated:)]) {
        [self.moviePlayer.view removeFromSuperview];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.videoArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"videoCell";
    
    TTVideoTableViewCell *cell = (TTVideoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[TTVideoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    TTVideo *video = [self.videoArray objectAtIndex:indexPath.row];
    
    cell.durationLabel.text = video.duration;
    cell.titleLabel.text = video.title;
    cell.descriptionVideoLabel.text = video.description;
    
    NSURL *url = [NSURL URLWithString:video.playerURl];

    
    if ([[url host] isEqualToString:@"www.youtube.com"]) {
        [cell.youtubeView loadWithVideoId:[video.playerURl lastPathComponent]];
    } else {
        
    }
    
    

    [cell.playVideoBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:video.photoURL]];
    
    __weak TTVideoTableViewCell *weakCell = cell;
    
    [cell.videoImageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       
                                       [UIView transitionWithView:weakCell.videoImageView
                                                         duration:0.3f
                                                          options:UIViewAnimationOptionTransitionCrossDissolve
                                                       animations:^{
                                                           weakCell.videoImageView.image = image;
                                                       } completion:NULL];
                                       
                                       
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       
                                   }];
    
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

@end
