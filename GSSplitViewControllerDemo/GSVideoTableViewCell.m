//
//  GSVideoTableViewCell.m
//  GSSplitViewControllerDemo
//
//  Created by Renee van der Kooi on 8/24/2558 BE.
//  Copyright (c) 2558 Mindzone Company Limited. All rights reserved.
//

#import "GSVideoTableViewCell.h"
#import "Constants.h"
#import "UIColor+MLPFlatColors.h"

@implementation GSVideoTableViewCell

@synthesize lblHeader, imageView;
@synthesize lblLikes,lblViews,imageViewLock,viewTags, accessoryBadge;


- (void)awakeFromNib {
    // Initialization code
    
    accessoryBadge = [MLPAccessoryBadge new];
    [accessoryBadge setText:@""];
    [accessoryBadge setCornerRadius:6];
    [accessoryBadge setTextColor:[UIColor flatSystemGreenColor]];
    [accessoryBadge.textLabel setShadowOffset:CGSizeZero];
    [accessoryBadge setHighlightAlpha:0];
    [accessoryBadge setShadowAlpha:0];
    [accessoryBadge setBackgroundColor:[UIColor flatWhiteColor]];
    [accessoryBadge setGradientAlpha:0];
    [accessoryBadge.textLabel setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    [self.viewTags addSubview:accessoryBadge];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
