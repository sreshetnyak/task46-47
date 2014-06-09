//
//  TTInfoTableViewCell.h
//  ClientServerAPIsBasics
//
//  Created by Sergey Reshetnyak on 5/29/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *groupPhotoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;


@end
