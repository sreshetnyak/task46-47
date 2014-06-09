//
//  TTAddPostViewController.h
//  ClientServerAPIs
//
//  Created by Sergey Reshetnyak on 6/5/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTGroup.h"

@protocol TTAddPostDelegete;

@interface TTAddPostViewController : UIViewController

@property (strong,nonatomic) TTGroup *group;
@property (weak,nonatomic) id <TTAddPostDelegete> delegate;

@end


@protocol TTAddPostDelegete <NSObject>

- (void)updateWall;

@end