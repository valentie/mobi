//
//  GSFavouritesViewController.h
//  GSSplitViewControllerDemo
//
//  Created by Renee van der Kooi on 8/24/2558 BE.
//  Copyright (c) 2558 Mindzone Company Limited. All rights reserved.
//

@protocol GSFavouritesViewControllerDelegate <NSObject>

-(void)onDemandCellPressed:(NSDictionary *)video;
-(void)collectionCellDidPressCategory:(int)category_id;

@end


#import <UIKit/UIKit.h>
#import "GSAppDelegate.h"
#import "AsyncImageView.h"
#import "GSVideoTableViewCell.h"
#import "UIColor+MLPFlatColors.h"
#import "GSApiResponseObjectItem.h"
#import "MBProgressHUD.h"
#import "VideoCollectionViewCell.h"



@interface GSFavouritesViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, MBProgressHUDDelegate, VideoCollectionViewCellDelegate>
{
    MBProgressHUD *HUD;
    GSApiResponseObjectItem *jsonData;
    NSArray *cellItems;
    UIRefreshControl *refreshControl;
    
    BOOL nibMyCellloaded;
     UILabel *noitemslabel;
}

@property (nonatomic, weak) id<GSFavouritesViewControllerDelegate> delegate;
@property (readwrite, retain) IBOutlet AsyncImageView *imageView;
@property (readwrite, retain) IBOutlet UILabel *lblProfileName;
@property (readwrite, retain) IBOutlet UICollectionView *collectionView;



@end
