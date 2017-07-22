//
//  ListCollectionViewCell.m
//  test
//
//  Created by Renee van der Kooi on 9/17/2558 BE.
//  Copyright (c) 2558 Renee van der Kooi. All rights reserved.
//

#import "VideoCollectionViewCell.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "GSSharedData.h"

@implementation VideoCollectionViewCell

@synthesize delegate, category_id, favourite, video_id;

- (void)awakeFromNib {
    // Initialization code
    [self.lblViews setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    [self.lblLikes setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    [self.lblHeader setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.lblSubheader setFont:[UIFont systemFontOfSize:FONTSIZE18]];
    [self.btnFavourite.titleLabel setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    [self.badgeView.titleLabel setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    
    self.badgeView.layer.cornerRadius = 6; // this value vary as per your desire
    self.badgeView.clipsToBounds = YES;
    
    
    self.lblSubheader.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblSubheader.numberOfLines = 0;
    
    
    
}


-(IBAction)btnFavouritePressed:(id)sender
{
    if (favourite == 0)
    {
        favourite = 1;
        [self.btnFavourite setImage:[UIImage imageNamed:@"icon_fav_on"] forState:UIControlStateNormal];
        
        [[GSSharedData sharedManager] addVideoToFavourite:video_id];
        
    } else {
        favourite = 0;
        [self.btnFavourite setImage:[UIImage imageNamed:@"icon_fav_off"] forState:UIControlStateNormal];
        [[GSSharedData sharedManager] removeVideoFromFavourite:video_id];
    }
    
}

-(IBAction)btnTagPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(collectionCellDidPressCategory:)])
    {
        //section
        if ([self.section isEqualToString:@"education"])
        {
            [delegate collectionCellDidPressCategoryForEducation:category_id];
        } else {
            [delegate collectionCellDidPressCategory:category_id];
        }
        
    }
}

@end
