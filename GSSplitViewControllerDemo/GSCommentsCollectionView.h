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
#import "CommentListCollectionViewCell.h"


@protocol GSCommentsCollectionViewDelegate <NSObject>
-(void)prepareCommentForPosting;
-(void)resignCommentsFromPosting;
@end

@interface GSCommentsCollectionView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MBProgressHUDDelegate, UITextFieldDelegate>
{
    MBProgressHUD *HUD;
    UICollectionView *collectionView;
    GSApiResponseObjectItem *jsonData;
    NSArray *cellItems;
    UIRefreshControl *refreshControl;
    
    BOOL nibMyCommentsCellloaded;
    
    int channel_id;
    int video_id;
    NSString *section;
    UILabel *noitemslabel;
    
    UITextField *textField;
}

@property (nonatomic, weak) id<GSCommentsCollectionViewDelegate> delegate;

-(void)didRotate:(UIInterfaceOrientation)orientation;
-(void)loadCommentsForChannel:(int)cid;
-(void)loadCommentsForVideo:(int)vid andSection:(NSString *)s;
@end