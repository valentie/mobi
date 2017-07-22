//
//  GSNewsTableViewCell.m
//  GSSplitViewControllerDemo
//
//  Created by Renee van der Kooi on 8/24/2558 BE.
//  Copyright (c) 2558 Mindzone Company Limited. All rights reserved.
//

#import "GSNewsTableViewCell.h"
#import "Constants.h"

@implementation GSNewsTableViewCell

@synthesize lblDescription,lblHeader,imageView;

- (void)awakeFromNib {
    // Initialization code
    
    
    [self.lblHeader setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.lblDescription setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
