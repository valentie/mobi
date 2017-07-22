//
//  GSNewsTableViewCell.h
//  GSSplitViewControllerDemo
//
//  Created by Renee van der Kooi on 8/24/2558 BE.
//  Copyright (c) 2558 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface GSNewsTableViewCell : UITableViewCell

@property (retain, readwrite) IBOutlet UILabel *lblHeader;
@property (retain, readwrite) IBOutlet UITextView *lblDescription;
@property (readwrite, nonatomic) IBOutlet AsyncImageView *imageView;


@end
