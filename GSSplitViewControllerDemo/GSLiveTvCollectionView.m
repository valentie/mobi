//
//  GSLiveTvCollectionView.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/19/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import "GSLiveTvCollectionView.h"
#import "Constants.h"
#import "GSMasterCellObjectItem.h"
#import "URLConnection.h"


@implementation GSLiveTvCollectionView

@synthesize delegate;

- (void)initialize
{

    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:collectionView];
    collectionView.delegate = self;
    collectionView.dataSource =self;
    nibMyCellloaded = NO;
    [collectionView registerClass:[ListCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    collectionView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:248.0/255.0 blue:251.0/255.0 alpha:1];
    

    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor lightGrayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [collectionView addSubview:refreshControl];
    collectionView.alwaysBounceVertical = YES;

    HUD = [[MBProgressHUD alloc] initWithView:self];
    [self addSubview:HUD];
    HUD.mode = MBProgressHUDModeText;
    HUD.delegate = self;
    
    [self reloadData];
}



- (id)initWithCoder:(NSCoder *)aCoder{
    if(self = [super initWithCoder:aCoder]){
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)rect{
    if(self = [super initWithFrame:rect]){
        [self initialize];
    }
    return self;
}

-(void)showWithText:(NSString *)st
{
    
    searchText = st;
    [self reloadData];
}


-(void)reloadData
{

    collectionView.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
    [refreshControl beginRefreshing];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@livetv",API_HOST,API_END_POINT]];
    

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    if (searchText != nil)
    {
        NSLog(@"searchtext is not nil");
        if ([searchText length] > 0)
        {
            NSLog(@"searchtext length more than 0: %@", searchText);
            NSString *postString = [NSString stringWithFormat:@"q=%@",searchText];
            [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [URLConnection asyncConnectionWithRequest:request completionBlock:^(NSData *data, NSURLResponse *response)
     {
         [refreshControl endRefreshing];
         jsonData = [[GSApiResponseObjectItem alloc] initWithNSData:data];
         
         if (jsonData.statusCode > 0)
         {
             // an error occurred
             HUD.labelText = jsonData.statusMessage;
             [HUD show:YES];
             [HUD hide:YES afterDelay:2.0];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         } else {
             // no error
             
             int count = [[jsonData.responseData valueForKey:@"count"] intValue];
             if (count == 0)
             {
                HUD.mode = MBProgressHUDModeText;
                 HUD.labelText = @"No Channels!";
                 [HUD show:YES];
                 [HUD hide:YES afterDelay:2.0];
             } else {

                 // cellitems
                 cellItems = [jsonData.responseData valueForKey:@"channels"];
                 
                 // Reload table data
                 [self->collectionView reloadData];
                 
                 if (forceLaunchChannelId > 0)
                 {
                     for (NSDictionary *channelContainer in cellItems)
                     {
                         
                         NSDictionary *channel = [channelContainer objectForKey:@"channel"];
                         int cid = [[channel valueForKey:@"id"] intValue];
                         if (cid == forceLaunchChannelId)
                         {
                             if([delegate respondsToSelector:@selector(liveStreamPressed:)])
                             {
                                 // should update view count
                                 [delegate liveStreamPressed:channel];
                             }
                             return;
                         }
                     }
                     forceLaunchChannelId = 0;
                 }
                 
             }
             
         }
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     } errorBlock:^(NSError *error) {
         // when error occurs
         HUD.mode = MBProgressHUDModeText;
         HUD.labelText = @"Could not connect.";
         HUD.progress = 100;
         [HUD show:YES];
         [HUD hide:YES afterDelay:2.0];
         [refreshControl endRefreshing];
          [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     } uploadProgressBlock:^(float progress) {
         // when upload progresses
         
     } downloadProgressBlock:^(float progress) {
         // when download progressses
         
     }];
    
}


-(void)didRotate:(UIInterfaceOrientation)orientation
{
    collectionView.frame = self.bounds;
    [collectionView.collectionViewLayout invalidateLayout];
}


-(void)launchChannelByID:(int)channel_id
{
    if (cellItems != nil)
    {
        for (NSDictionary *channelContainer in cellItems)
        {
            
            NSDictionary *channel = [channelContainer objectForKey:@"channel"];
            
            int cid = [[channel valueForKey:@"id"] intValue];
            
            if (cid == channel_id)
            {
                if([delegate respondsToSelector:@selector(liveStreamPressed:)])
                {
                    // should update view count
                    [delegate liveStreamPressed:channel];
                }
                return;
            }
            forceLaunchChannelId = channel_id;
        }
    } else {
        
        forceLaunchChannelId = channel_id;
    }
}

#pragma UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [cellItems count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *identifier = @"cell";
    if(!nibMyCellloaded)
    {
        UINib *nib = [UINib nibWithNibName:@"ListCollectionViewCell" bundle: nil];
        [cv registerNib:nib forCellWithReuseIdentifier:identifier];
        nibMyCellloaded = YES;
    }
    NSDictionary *channel = [[cellItems objectAtIndex:indexPath.row] objectForKey:@"channel"];

    ListCollectionViewCell *cell = (ListCollectionViewCell*)[cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.lblHeader.text = [channel valueForKey:@"title"];
    cell.lblSubheader.text = [NSString stringWithFormat:@"%i คนที่กำลังรับชม",[[channel valueForKey:@"watching"] intValue]];
    cell.lblLikes.text = [NSString stringWithFormat:@"%i",[[channel valueForKey:@"likes"] intValue]];
    cell.lblViews.text = [NSString stringWithFormat:@"%i",[[channel valueForKey:@"views"] intValue]];
    cell.imageView.image = nil;
    cell.imageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@channels/icons/%i.png",API_IMAGE_HOST,[[channel valueForKey:@"id"] intValue]]];
    
    
    return cell;;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5)
    {
        NSLog(@"iphone 4 or less or 5");
        return CGSizeMake(SCREEN_WIDTH - 20, 68);
    }
    
    UIInterfaceOrientation interfaceOrientation =[[UIApplication sharedApplication] statusBarOrientation];
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        return CGSizeMake(354, 68);
    } else {
        return CGSizeMake(322, 68);
    }
    
    
    
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (IS_IPAD)
    {
        return UIEdgeInsetsMake(20, 20, 20, 20);
    } else {
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath");
    NSDictionary *channel = [[cellItems objectAtIndex:indexPath.row] objectForKey:@"channel"];
    if([delegate respondsToSelector:@selector(liveStreamPressed:)])
    {
        // should update view count
        [delegate liveStreamPressed:channel];
    }
}

@end
