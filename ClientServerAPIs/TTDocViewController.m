//
//  TTDocViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/6/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTDocViewController.h"
#import "TTServerManager.h"
#import "TTDocuments.h"
#import "TTDocTableViewCell.h"

@interface TTDocViewController () <UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic) NSMutableArray *documentArray;
@property (assign,nonatomic) BOOL loadingData;

@end

@implementation TTDocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Documents";
    self.view.backgroundColor = [UIColor whiteColor];
    self.documentArray = [NSMutableArray array];
    self.loadingData = YES;
    
    [self getDocumentsFromServer];

}

- (void)getDocumentsFromServer {
    
    
    [[TTServerManager sharedManager]getDocumentInGroupId:self.group.groupsID count:20 offset:[self.documentArray count] onSuccess:^(NSArray *docGroupArray) {
        
        if ([docGroupArray count] > 0) {
            
            [self.documentArray addObjectsFromArray:docGroupArray];
            
            NSMutableArray* newPaths = [NSMutableArray array];
            for (int i = (int)[self.documentArray count] - (int)[docGroupArray count]; i < [self.documentArray count]; i++) {
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
            [self getDocumentsFromServer];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.documentArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"docCell";
    
    TTDocTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[TTDocTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    TTDocuments *doc = [self.documentArray objectAtIndex:indexPath.row];
    
    cell.fileNameLabel.text = doc.title;
    cell.sizeFileLabel.text = doc.size;
    
    CALayer *imageLayer = cell.fileImageView.layer;
    [imageLayer setCornerRadius:5];
    [imageLayer setMasksToBounds:YES];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
