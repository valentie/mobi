//
//  GSLiveTvCollectionView.h
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/19/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "GSApiResponseObjectItem.h"
#import "VideoCollectionViewCell.h"
#import "UIAlertView+Blocks.h"
#import "SIAlertView.h"

@protocol GSOnDemandCollectionViewDelegate <NSObject>

-(void)onDemandPressed:(NSDictionary *)video;
-(void)collectionCellDidPressCategory:(int)category_id;
@end


@interface GSOnDemandCollectionView : UIView <UIAlertViewDelegate,UIActionSheetDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MBProgressHUDDelegate, VideoCollectionViewCellDelegate>
{
    MBProgressHUD *HUD;
    UICollectionView *collectionView;
    GSApiResponseObjectItem *jsonData;
    NSMutableArray *cellItems;
    NSMutableArray *sectionItems;
    UIRefreshControl *refreshControl;
    
    BOOL nibMyVideoCellloaded;
    BOOL isLoadingMore;
    float PER_PAGE;
}


@property (nonatomic, weak) id<GSOnDemandCollectionViewDelegate> delegate;
@property (nonatomic,readwrite) int category_id;
@property (nonatomic,readwrite) NSString *searchText;
@property (nonatomic,readwrite) NSString *sortBy;

-(void)didRotate:(UIInterfaceOrientation)orientation;
-(void)showWithCategory:(int)category_id;
-(void)showWithCategory:(int)category_id andSearch:(NSString *)searchText;
-(void)showWithText:(NSString *)searchText;
-(void)showWithSort;

@end