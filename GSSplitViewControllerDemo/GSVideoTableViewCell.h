//
//  GSVideoTableViewCell.h
//  GSSplitViewControllerDemo
//
//  Created by Renee van der Kooi on 8/24/2558 BE.
//  Copyright (c) 2558 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "MLPAccessoryBadge.h"

@interface GSVideoTableViewCell : UITableViewCell

@property (retain, readwrite) IBOutlet UILabel *lblHeader;
@property (retain, readwrite) IBOutlet UILabel *lblDescription;
@property (readwrite, nonatomic) IBOutlet AsyncImageView *imageView;

@property (retain, readwrite) IBOutlet UILabel *lblViews;
@property (retain, readwrite) IBOutlet UILabel *lblLikes;


@property (readwrite, nonatomic) IBOutlet UIImageView *imageViewLock;

@property (retain, readwrite) IBOutlet UIView *viewTags;
@property (retain, readwrite) MLPAccessoryBadge *accessoryBadge;


@end
