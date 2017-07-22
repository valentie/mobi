//
//  ListCollectionViewCell.h
//  test
//
//  Created by Renee van der Kooi on 9/17/2558 BE.
//  Copyright (c) 2558 Renee van der Kooi. All rights reserved.
//


@protocol VideoCollectionViewCellDelegate <NSObject>

-(void)collectionCellDidPressCategory:(int)category_id;
-(void)collectionCellDidPressCategoryForEducation:(int)category_id;
@end

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface VideoCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<VideoCollectionViewCellDelegate> delegate;

@property (readwrite, nonatomic)  int video_id;
@property (readwrite, nonatomic)  int category_id;
@property (readwrite, nonatomic)  int favourite;

@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel *lblViews;
@property (retain, nonatomic) IBOutlet UILabel *lblLikes;
@property (retain, nonatomic) IBOutlet UILabel *lblHeader;
@property (retain, nonatomic) IBOutlet UILabel *lblSubheader;
@property (retain, nonatomic) IBOutlet UIButton *btnFavourite;
@property (retain, nonatomic) IBOutlet UIButton *badgeView;
@property (retain, nonatomic) IBOutlet UIImageView *lockView;

@property (retain, nonatomic) NSString *section;

-(IBAction)btnFavouritePressed:(id)sender;
-(IBAction)btnTagPressed:(id)sender;

@end
