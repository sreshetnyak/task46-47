//
//  TTDetailTopicsViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/7/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTDetailTopicsViewController.h"
#import "TTPostTableViewCell.h"
#import "TTServerManager.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "TTComment.h"


#define DELTA_LABEL 49

@interface TTDetailTopicsViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate>

@property (assign,nonatomic) BOOL loadingData;
@property (strong,nonatomic) NSMutableArray *comentTopicsArray;
@property (strong,nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic)  UITextView *textView;
@property (assign,nonatomic) CGRect keyboardBounds;

@end

@implementation TTDetailTopicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.backgroundColor = [UIColor grayColor];
    toolbar.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    UITextView * txtview = [[UITextView alloc]initWithFrame:CGRectMake(10,20,220,30)];
    [txtview setDelegate:self];
    [txtview setReturnKeyType:UIReturnKeyDefault];
    [txtview setTag:1];
    [txtview.layer setCornerRadius:5.f];
    txtview.scrollEnabled = NO;
    self.textView = txtview;
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAttachment:)];
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc]initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendAttachment:)];
    
    [items addObject:addItem];
    [items addObject:[[UIBarButtonItem alloc] initWithCustomView:self.textView]];
    [items addObject:sendItem];
    [toolbar setItems:items animated:NO];
    
    self.toolBar = toolbar;
    [self.view addSubview:self.toolBar];
    
    self.comentTopicsArray = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.loadingData = YES;
    
    [self getTopicsCommentFromServer];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)flag {
    
    [super viewWillAppear:flag];
    [self.textView becomeFirstResponder];
}

- (void)addAttachment:(UIBarButtonItem *)sender {
    
}

- (void)sendAttachment:(UIBarButtonItem *)sender {
    
    [self.textView resignFirstResponder];
    
    [[TTServerManager sharedManager]postText:self.textView.text inGroup:[[TTServerManager sharedManager] group].groupsID onTopic:self.topics.topicsid onSuccess:^(id result) {
        
        NSLog(@"%@",result);
        [self.textView setText:@""];
        [self refreshComment];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
}

- (void)refreshComment {

    [[TTServerManager sharedManager]getCommentTopicById:self.topics.topicsid ownerID:[[TTServerManager sharedManager] group].groupsID count:MAX(10, [self.comentTopicsArray count]) offset:0 onSuccess:^(NSArray *wallComment) {

        if ([wallComment count] > 0) {
            
            [self.comentTopicsArray removeAllObjects];
            [self.comentTopicsArray addObjectsFromArray:wallComment];
            [self.tableView reloadData];
        }
        
    } onFailure:^(NSError *error) {
        
    }];
    
}

- (void)getTopicsCommentFromServer {
    
    [[TTServerManager sharedManager]getCommentTopicById:self.topics.topicsid ownerID:[[TTServerManager sharedManager] group].groupsID count:10 offset:[self.comentTopicsArray count] onSuccess:^(NSArray *wallComment) {
        
        if ([wallComment count] > 0) {
            
            [self.comentTopicsArray addObjectsFromArray:wallComment];
            
            NSMutableArray* newPaths = [NSMutableArray array];
            for (int i = (int)[self.comentTopicsArray count] - (int)[wallComment count]; i < [self.comentTopicsArray count]; i++) {
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


- (void)keyboardWillShow: (NSNotification *)notification {
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] valueForKey: UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.keyboardBounds = [(NSValue *)[[notification userInfo] objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    [self.tableView setFrame:CGRectMake(0, 0, self.toolBar.frame.size.width, self.view.frame.size.height - self.keyboardBounds.size.height - self.toolBar.frame.size.height)];
    [self.toolBar setFrame:CGRectMake(0.0f, self.view.frame.size.height - self.keyboardBounds.size.height - self.toolBar.frame.size.height,self.toolBar.frame.size.width, self.toolBar.frame.size.height)];
    [UIView commitAnimations];
    [self.tableView scrollsToTop];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)keyboardWillHide: (NSNotification *)notification {
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] valueForKey: UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    [self.tableView setFrame:CGRectMake(0, 0, self.toolBar.frame.size.width, self.view.frame.size.height - self.toolBar.frame.size.height)];
    [self.toolBar setFrame:CGRectMake(0.0f, self.view.frame.size.height - self.toolBar.frame.size.height,self.toolBar.frame.size.width, self.toolBar.frame.size.height)];
    [UIView commitAnimations];
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    
    NSLog(@"%f",newFrame.size.height);
    
    [self.toolBar setFrame:CGRectMake(0,
                                      self.view.frame.size.height - self.keyboardBounds.size.height - newFrame.size.height - 14,
                                      self.toolBar.frame.size.width,
                                      newFrame.size.height + 14)];
    
    textView.frame = newFrame;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.loadingData)
        {
            self.loadingData = YES;
            [self getTopicsCommentFromServer];
        }
    }
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

- (NSString *) stringByStrippingHTML:(NSString *)string {
    
    NSRange r;
    while ((r = [string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        
        string = [string stringByReplacingCharactersInRange:r withString:@""];
    }
    
    return string;
}

- (void)addLike:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    TTComment *coment = [self.comentTopicsArray objectAtIndex:indexPath.row];
    
    if (coment.likeAllow) {
        
        [[TTServerManager sharedManager]postLikeOnWall:[[TTServerManager sharedManager] group].groupsID inPost:coment.comentIDs type:@"topic_comment" onSuccess:^(NSDictionary *result) {
            
            [self refreshComment];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
    } else {
        
        [[TTServerManager sharedManager]postDeleteLikeOnWall:[[TTServerManager sharedManager] group].groupsID inPost:coment.comentIDs type:@"topic_comment" onSuccess:^(NSDictionary *result) {
            
            [self refreshComment];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
    }
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.comentTopicsArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *postIdentifier = @"detailTopicsCell";
    
    TTPostTableViewCell *postCell = [tableView dequeueReusableCellWithIdentifier:postIdentifier];
    
    if (!postCell) {
        postCell = [[TTPostTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:postIdentifier];
    }
    
    TTComment *coment = [self.comentTopicsArray objectAtIndex:indexPath.row];
    
    postCell.postTextLabel.text = coment.text;
    postCell.dateLabel.text = coment.date;
    
    postCell.addLikeBtn.frame = CGRectMake(postCell.addLikeBtn.frame.origin.x, postCell.addLikeBtn.frame.origin.y,[self widthOfTextForString:coment.likeCount maxSize:CGSizeMake(100, postCell.addLikeBtn.frame.size.height)], postCell.addLikeBtn.frame.size.height);
    
    UIFont* font = [UIFont systemFontOfSize:10.f];
    
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0, -1);
    shadow.shadowBlurRadius = 0;
    
    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentLeft];
    
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, paragraph, NSParagraphStyleAttributeName,shadow, NSShadowAttributeName, nil];
    
    CGRect rect = [[self stringByStrippingHTML:coment.text] boundingRectWithSize:CGSizeMake(postCell.postTextLabel.frame.size.width, CGFLOAT_MAX)
                                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                      attributes:attributes
                                                                         context:nil];
    
    
    
    
    CGRect newFrame = postCell.postTextLabel.frame;
    newFrame.size.height = rect.size.height;
    postCell.postTextLabel.frame = newFrame;
    
    CALayer *imageLayerLike = postCell.addLikeBtn.layer;
    [imageLayerLike setCornerRadius:3];
    [imageLayerLike setMasksToBounds:YES];
    
    
    postCell.addLikeBtn.frame = CGRectMake(postCell.addLikeBtn.frame.origin.x, newFrame.size.height + DELTA_LABEL + 10,postCell.addLikeBtn.frame.size.width,postCell.addLikeBtn.frame.size.height);
    
    [postCell.addLikeBtn  setTitle:coment.likeCount forState:UIControlStateNormal];
    [postCell.addLikeBtn addTarget:self action:@selector(addLike:) forControlEvents:UIControlEventTouchUpInside];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:coment.user.photoURL]];
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
    
    
    postCell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@",coment.user.firstName,coment.user.lastName];
    
    return postCell;
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TTComment *coment = [self.comentTopicsArray objectAtIndex:indexPath.row];
    
    TTPostTableViewCell *postCell = (TTPostTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    UIFont* font = [UIFont systemFontOfSize:10.f];
    
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0, -1);
    shadow.shadowBlurRadius = 0;
    
    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentLeft];
    
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, paragraph, NSParagraphStyleAttributeName,shadow, NSShadowAttributeName, nil];
    
    CGRect rect = [[self stringByStrippingHTML:coment.text] boundingRectWithSize:CGSizeMake(postCell.postTextLabel.frame.size.width, CGFLOAT_MAX)
                                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                      attributes:attributes
                                                                         context:nil];
    
    
    CGRect newFrame = postCell.postTextLabel.frame;
    newFrame.size.height = rect.size.height;
    
    
    return newFrame.size.height + DELTA_LABEL + 10 + 5 + postCell.addLikeBtn.frame.size.height;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
