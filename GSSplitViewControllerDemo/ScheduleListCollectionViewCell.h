//
//  ListCollectionViewCell.h
//  test
//
//  Created by Renee van der Kooi on 9/17/2558 BE.
//  Copyright (c) 2558 Renee van der Kooi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ScheduleListCollectionViewCell : UICollectionViewCell



@property (retain, nonatomic) IBOutlet UILabel *lblTime;
@property (retain, nonatomic) IBOutlet UILabel *lblAmPm;

@property (retain, nonatomic) IBOutlet UILabel *lblHeader;
@property (retain, nonatomic) IBOutlet UILabel *lblSubheader;
@property (retain, nonatomic) IBOutlet UILabel *lblSubHeaderMinimum;
@property (retain, nonatomic) IBOutlet UILabel *lblDuration;
@end
