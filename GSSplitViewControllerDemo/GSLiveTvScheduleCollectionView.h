//
//  GSLiveTvCollectionView.h
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/19/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "fileUploadEngine.h"
#import "GSApiResponseObjectItem.h"
#import "ScheduleListCollectionViewCell.h"



@interface GSLiveTvScheduleCollectionView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
    UICollectionView *collectionView;
    GSApiResponseObjectItem *jsonData;
    NSArray *cellItems;
    UIRefreshControl *refreshControl;
    
    BOOL nibMyScheduleCellloaded;
    int channel_id;
    
    UILabel *noitemslabel;
}

@property (strong, nonatomic) fileUploadEngine *flUploadEngine;
@property (strong, nonatomic) MKNetworkOperation *flOperation;

-(void)didRotate:(UIInterfaceOrientation)orientation;
-(void)loadScheduleForChannel:(int)cid;

@end