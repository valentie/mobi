//
//  GSLiveTvCollectionView.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/19/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import "GSLiveTvScheduleCollectionView.h"
#import "Constants.h"
#import "GSMasterCellObjectItem.h"
#import "URLConnection.h"


@implementation GSLiveTvScheduleCollectionView

@synthesize flOperation,flUploadEngine;

- (void)initialize
{

    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:collectionView];
    collectionView.delegate = self;
    collectionView.dataSource =self;
    nibMyScheduleCellloaded = NO;
    [collectionView registerClass:[ScheduleListCollectionViewCell class] forCellWithReuseIdentifier:@"cellSchedule"];
    collectionView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:248.0/255.0 blue:251.0/255.0 alpha:1];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor lightGrayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [collectionView addSubview:refreshControl];
    collectionView.alwaysBounceVertical = YES;

    
    noitemslabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 30)];
    noitemslabel.text = @"No items found";
    noitemslabel.textAlignment = NSTextAlignmentCenter;
    [collectionView addSubview:noitemslabel];
    
    HUD = [[MBProgressHUD alloc] initWithView:self];
    [self addSubview:HUD];
    HUD.mode = MBProgressHUDModeText;
    HUD.delegate = self;
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

-(void)loadScheduleForChannel:(int)cid
{
    cellItems = [[NSArray alloc] init];
    [self->collectionView reloadData];
    
    channel_id = cid;
    [self reloadData];
}



-(void)reloadData
{
    
    collectionView.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
    [refreshControl beginRefreshing];
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@schedule",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"channel_id=%i",channel_id];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
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
             
         } else {
             // no error
             
             int count = [[jsonData.responseData valueForKey:@"count"] intValue];
             if (count == 0)
             {
                 HUD.mode = MBProgressHUDModeText;
                 HUD.labelText = @"No schedule!";
                 [HUD show:YES];
                 [HUD hide:YES afterDelay:2.0];
                 noitemslabel.hidden = NO;
             } else {
                 
                 // cellitems
                 cellItems = [jsonData.responseData valueForKey:@"schedules"];
                 
                 // Reload table data
                 [self->collectionView reloadData];
                 noitemslabel.hidden = YES;
                 
             }
             
             
             
         }
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         HUD.labelText = @"Could not connect.";
         HUD.progress = 100;
         [HUD show:YES];
         [HUD hide:YES afterDelay:2.0];
         [refreshControl endRefreshing];
     } uploadProgressBlock:^(float progress) {
         // when upload progresses
         
     } downloadProgressBlock:^(float progress) {
         // when download progressses
         
     }];
    
}


-(void)didRotate:(UIInterfaceOrientation)orientation
{
    NSLog(@"rotate in livetv");
    collectionView.frame = self.bounds;
    [collectionView.collectionViewLayout invalidateLayout];
    
}

#pragma UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [cellItems count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *identifier = @"cellSchedule";
    
    
    
    if(!nibMyScheduleCellloaded)
    {
        UINib *nib = [UINib nibWithNibName:@"ScheduleListCollectionViewCell" bundle: nil];
        [cv registerNib:nib forCellWithReuseIdentifier:identifier];
        nibMyScheduleCellloaded = YES;
    }
    NSDictionary *channel = [[cellItems objectAtIndex:indexPath.row] objectForKey:@"schedule"];

    ScheduleListCollectionViewCell *cell = (ScheduleListCollectionViewCell*)[cv dequeueReusableCellWithReuseIdentifier:@"cellSchedule" forIndexPath:indexPath];
    cell.lblHeader.text = [channel valueForKey:@"schedule_name"];
    cell.lblSubheader.text = [channel valueForKey:@"schedule_description"];
    cell.lblTime.text = [channel valueForKey:@"hour"];
    cell.lblAmPm.text = [channel valueForKey:@"timezone"];
    cell.lblSubHeaderMinimum.text = [channel valueForKey:@"subtitle"];
    cell.lblDuration.text = [channel valueForKey:@"duration"];

    return cell;
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


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
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
}

@end
