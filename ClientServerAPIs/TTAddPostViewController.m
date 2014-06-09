//
//  TTAddPostViewController.m
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/5/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTAddPostViewController.h"
#import "TTServerManager.h"

@interface TTAddPostViewController () <UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic)  UITextView *textView;
@property (strong, nonatomic)  UIToolbar *toolBar;
@property (strong, nonatomic)  UIImageView *atachment;
@property (assign,nonatomic) CGRect keyboardBounds;

@end

@implementation TTAddPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hidePostView:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addPostOnWall:)];
    
    self.navigationItem.rightBarButtonItem = done;
    self.navigationItem.leftBarButtonItem = cancel;
    
    self.atachment = [[UIImageView alloc]initWithFrame:CGRectMake(5, 25, 100, 100)];
    
    CALayer *imageLayer = self.atachment.layer;
    [imageLayer setCornerRadius:10];
    [imageLayer setMasksToBounds:YES];
    
    UITextView * txtview = [[UITextView alloc]initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];

    [txtview setDelegate:self];
    [txtview setReturnKeyType:UIReturnKeyDefault];
    [txtview setTag:1];
    txtview.scrollEnabled = NO;
    self.textView = txtview;
    [self.textView addSubview:self.atachment];
    [self.view addSubview:self.textView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.backgroundColor = [UIColor grayColor];
    toolbar.frame = CGRectMake(0, self.view.frame.size.height - 30, self.view.frame.size.width, 30);
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *addPhoto = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(addPhoto:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 20.f;
    UIBarButtonItem *addAttachment = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAttachment:)];
    
    [items addObjectsFromArray:@[flexibleSpace,addPhoto,fixedSpace,addAttachment]];
    [toolbar setItems:items animated:NO];
    
    self.toolBar = toolbar;
    [self.view addSubview:self.toolBar];
    
    [self.textView becomeFirstResponder];
    
    NSLog(@"%@",self.group.groupsID);
    
}

- (void)keyboardWillShow: (NSNotification *)notification {
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] valueForKey: UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.keyboardBounds = [(NSValue *)[[notification userInfo] objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    [self.textView setFrame:CGRectMake(0, 0, self.textView.frame.size.width, self.view.frame.size.height - self.keyboardBounds.size.height - self.toolBar.frame.size.height)];
    [self.toolBar setFrame:CGRectMake(0.0f, self.view.frame.size.height - self.keyboardBounds.size.height - self.toolBar.frame.size.height,self.toolBar.frame.size.width, self.toolBar.frame.size.height)];
    [UIView commitAnimations];
}

- (void)keyboardWillHide: (NSNotification *)notification {
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] valueForKey: UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval animationDuration = [[[notification userInfo] valueForKey: UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:nil context: nil];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    [self.textView setFrame:CGRectMake(0, 0, self.textView.frame.size.width, self.view.frame.size.height - self.toolBar.frame.size.height)];
    [self.toolBar setFrame:CGRectMake(0.0f, self.view.frame.size.height - self.toolBar.frame.size.height,self.toolBar.frame.size.width, self.toolBar.frame.size.height)];
    [UIView commitAnimations];
    
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addPhoto:(UIBarButtonItem *)sender {

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    
    NSLog(@"%f",newFrame.size.height);
    
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.atachment setFrame:CGRectMake(self.atachment.frame.origin.x, newFrame.size.height, self.atachment.frame.size.width, self.atachment.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    self.atachment.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)addAttachment:(UIBarButtonItem *)sender {
    
}

- (void)hidePostView:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addPostOnWall:(UIBarButtonItem *)sender {
    
    [[TTServerManager sharedManager]postText:self.textView.text image:self.atachment.image onGroupWall:self.group.groupsID onSuccess:^(id result) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [self.delegate updateWall];
        
        
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
