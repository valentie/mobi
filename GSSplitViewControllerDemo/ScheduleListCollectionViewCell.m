//
//  ListCollectionViewCell.m
//  test
//
//  Created by Renee van der Kooi on 9/17/2558 BE.
//  Copyright (c) 2558 Renee van der Kooi. All rights reserved.
//

#import "ScheduleListCollectionViewCell.h"
#import "Constants.h"
@implementation ScheduleListCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    
    
    
    [self.lblTime setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    [self.lblAmPm setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    [self.lblHeader setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.lblSubheader setFont:[UIFont systemFontOfSize:FONTSIZE18]];
    
    [self.lblSubHeaderMinimum setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    [self.lblDuration setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    
}

@end
