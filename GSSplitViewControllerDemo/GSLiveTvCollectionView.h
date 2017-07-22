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
#import "ListCollectionViewCell.h"

@protocol GSLiveTvCollectionViewDelegate <NSObject>

-(void)liveStreamPressed:(NSDictionary *)url;

@end


@interface GSLiveTvCollectionView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
    UICollectionView *collectionView;
    GSApiResponseObjectItem *jsonData;
    NSArray *cellItems;
    UIRefreshControl *refreshControl;
    
    BOOL nibMyCellloaded;
    int forceLaunchChannelId;
    
    NSString *searchText;
}


@property (nonatomic, weak) id<GSLiveTvCollectionViewDelegate> delegate;

-(void)didRotate:(UIInterfaceOrientation)orientation;
-(void)launchChannelByID:(int)channel_id;
-(void)showWithText:(NSString *)searchText;
@end