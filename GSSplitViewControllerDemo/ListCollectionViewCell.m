//
//  ListCollectionViewCell.m
//  test
//
//  Created by Renee van der Kooi on 9/17/2558 BE.
//  Copyright (c) 2558 Renee van der Kooi. All rights reserved.
//

#import "ListCollectionViewCell.h"
#import "Constants.h"

@implementation ListCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.lblViews setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    [self.lblLikes setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    [self.lblHeader setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.lblSubheader setFont:[UIFont systemFontOfSize:FONTSIZE18]];
}

@end
