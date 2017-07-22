//
//  GSLiveTvCollectionView.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/19/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import "GSOnDemandCollectionView.h"
#import "Constants.h"
#import "GSMasterCellObjectItem.h"
#import "URLConnection.h"
#import "UIImageView+AFNetworking.h"
#import "IAPManager.h"
#import "GSSharedData.h"
#import "GSCollectionHeaderView.h"

#define ALART_TAG_CONFIRMPURCHASE 10

@implementation GSOnDemandCollectionView

@synthesize delegate, category_id, searchText, sortBy;

- (void)initialize
{
    isLoadingMore = false;
    PER_PAGE = 32;
    sortBy = @"";
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
    // iOS 8.0 or later
    if ([flowLayout respondsToSelector:@selector(setSectionHeadersPinToVisibleBounds:)])
    {
        [flowLayout setSectionHeadersPinToVisibleBounds:YES];
    }
#else
    // less than 8.0
#endif
    
    flowLayout.headerReferenceSize = CGSizeMake(50.0f, 30.0f);
    
    collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    
    [self addSubview:collectionView];
    collectionView.delegate = self;
    collectionView.dataSource =self;
    nibMyVideoCellloaded = NO;
    [collectionView registerClass:[VideoCollectionViewCell class] forCellWithReuseIdentifier:@"cellVideo"];
    [collectionView registerClass:[GSCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeaderView"];
    collectionView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:248.0/255.0 blue:251.0/255.0 alpha:1];
    

    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor lightGrayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [collectionView addSubview:refreshControl];
    collectionView.alwaysBounceVertical = YES;
    collectionView.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
    [refreshControl beginRefreshing];
    
    self.category_id = 0;
    self.searchText = @"";
    
    
    
    HUD = [[MBProgressHUD alloc] initWithView:self];
    [self addSubview:HUD];
    HUD.delegate = self;
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
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

-(void)showWithCategory:(int)category_id
{
    isLoadingMore = NO;
    cellItems = nil;
    self.category_id = category_id;
    self.searchText = @"";
    [self reloadData];
}

-(void)showWithCategory:(int)category_id andSearch:(NSString *)searchText
{
    isLoadingMore = NO;
    cellItems = nil;
    self.category_id = category_id;
    self.searchText = searchText;
    [self reloadData];
}
-(void)showWithText:(NSString *)searchText
{
    isLoadingMore = NO;
    cellItems = nil;
    self.category_id = 0;
    self.searchText = searchText;
    [self reloadData];
}
-(void)showWithSort
{
    isLoadingMore = NO;
    cellItems = nil;
    [self reloadData];
}

-(void)reloadData
{
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@ondemand_sectioned2",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    NSString *postString;
    if (!isLoadingMore)
    {
        postString = [NSString stringWithFormat:@"user_id=%@&category_id=%i&q=%@&sortby=%@&device_uuid=%@&per_page=%f",user_id,category_id,searchText, sortBy, [appDelegate deviceID], PER_PAGE];
    } else {
        postString = [NSString stringWithFormat:@"user_id=%@&category_id=%i&q=%@&sortby=%@&device_uuid=%@&per_page=%f",user_id,category_id,searchText, sortBy, [appDelegate deviceID],[self totalCellItems] +PER_PAGE ];
    }
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

   
    
    NSLog(@"ICTUBE searching for %@ in category %i perpage: %i and sortby %@", searchText, category_id, (int)PER_PAGE, sortBy);
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [URLConnection asyncConnectionWithRequest:request completionBlock:^(NSData *data, NSURLResponse *response)
     {
         [refreshControl endRefreshing];
         jsonData = [[GSApiResponseObjectItem alloc] initWithNSData:data];
         
         NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         NSLog(@"searching returned %@ ", myString);
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


                 NSArray *videos_exclusive = [jsonData.responseData valueForKey:@"videos_exclusive"];
                 NSArray *videos_featured = [jsonData.responseData valueForKey:@"videos_featured"];
                 NSArray *videos_mostviewed = [jsonData.responseData valueForKey:@"videos_mostviewed"];
                 NSArray *videos_default = [jsonData.responseData valueForKey:@"videos_default"];
                 
                 
                 cellItems = [[NSMutableArray alloc] init];
                 sectionItems = [[NSMutableArray alloc] init];
                 
                 if ([videos_exclusive count] > 0)
                 {
                     [cellItems addObject:videos_exclusive];
                     [sectionItems addObject:@"Exclusive"];
                 }
                 if ([videos_featured count] > 0)
                 {
                     [cellItems addObject:videos_featured];
                     [sectionItems addObject:@"Featured"];
                 }
                 if ([videos_mostviewed count] > 0)
                 {
                     [cellItems addObject:videos_mostviewed];
                     [sectionItems addObject:@"Most Viewed"];
                 }
                 if ([videos_default count] > 0)
                 {
                     [cellItems addObject:videos_default];
                     [sectionItems addObject:@"Videos"];
                 }
                 
                 // Reload table data
                 NSLog(@"items after : %i", [cellItems count]);
             
                if ([self totalCellItems] == 0)
                {
                    HUD.mode = MBProgressHUDModeText;
                    HUD.labelText = @"No Results";
                    [HUD show:YES];
                    [HUD hide:YES afterDelay:2.0];
                }
             
                [collectionView reloadData];
             
             
         }
         isLoadingMore = NO;
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     } errorBlock:^(NSError *error) {
         
         // when error occurs
         HUD.labelText = @"Could not connect.";
         HUD.progress = 100;
         [HUD show:YES];
         [HUD hide:YES afterDelay:2.0];
         [refreshControl endRefreshing];
         isLoadingMore = NO;
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSLog(@"numberOfSectionsInCollectionView %lu", (unsigned long)[cellItems count]);
    return [cellItems count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"numberOfItemsInSection %lu", (unsigned long)[[cellItems objectAtIndex:section] count]);
    
    return [[cellItems objectAtIndex:section] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;


    
    if (kind == UICollectionElementKindSectionHeader) {
        GSCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeaderView" forIndexPath:indexPath];
        
        
        NSString *title = [sectionItems objectAtIndex:indexPath.section];
        headerView.title.text = title;
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        
       // reusableview = nil;
    }
    
    return reusableview;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *identifier = @"cellVideo";
    if(!nibMyVideoCellloaded)
    {
        UINib *nib = [UINib nibWithNibName:@"VideoCollectionViewCell" bundle: nil];
        [cv registerNib:nib forCellWithReuseIdentifier:identifier];
        nibMyVideoCellloaded = YES;
    }
    
    VideoCollectionViewCell *cell = (VideoCollectionViewCell*)[cv dequeueReusableCellWithReuseIdentifier:@"cellVideo" forIndexPath:indexPath];
    cell.delegate = self;
    
   
    
    NSDictionary *video = [[cellItems[indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"video"];
    
    
    int cat_id =[[video valueForKey:@"category_id"] intValue];
    int likes =[[video valueForKey:@"likes"] intValue];
    int views =[[video valueForKey:@"views"] intValue];
    int favourite =[[video valueForKey:@"favourite"] intValue];
    int exclusive =[[video valueForKey:@"exclusive"] intValue];
    int video_id =[[video valueForKey:@"video_id"] intValue];
    
    cell.category_id = cat_id;
    cell.video_id = video_id;
    cell.favourite = favourite;
    
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@ondemand/screenshots/%i.png",API_IMAGE_HOST,[[video valueForKey:@"video_id"] intValue]]] placeholderImage:nil];
    cell.lblHeader.text = [video valueForKey:@"title"];
    cell.lblSubheader.text = [video valueForKey:@"description"];
    cell.lblLikes.text = [[GSSharedData sharedManager] suffixNumber:[NSNumber numberWithInt:likes]];
    cell.lblViews.text = [[GSSharedData sharedManager] suffixNumber:[NSNumber numberWithInt:views]];
   
    
    if ([video valueForKey:@"category"] != nil)
    {
        [cell.badgeView setTitle:[video valueForKey:@"category"] forState:UIControlStateNormal];
    } else {
        [cell.badgeView setTitle:@"undefined" forState:UIControlStateNormal];
    }
    
    if (exclusive > 0)
    {
        cell.lockView.hidden = NO;
    } else {
        cell.lockView.hidden = YES;
    }
    if (favourite == 0)
    {
        [cell.btnFavourite setImage:[UIImage imageNamed:@"icon_fav_off"] forState:UIControlStateNormal];
    } else {
        [cell.btnFavourite setImage:[UIImage imageNamed:@"icon_fav_on"] forState:UIControlStateNormal];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5)
    {
        NSLog(@"iphone 4 or less or 5");
        return CGSizeMake(SCREEN_WIDTH - 20, 88);
    }
    UIInterfaceOrientation interfaceOrientation =[[UIApplication sharedApplication] statusBarOrientation];
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        return CGSizeMake(354, 82);
    } else {
        return CGSizeMake(322, 82);
    }
}

-(NSUInteger)totalCellItems
{
    NSUInteger total = 0;
    for (NSArray *section in cellItems)
    {
        total = total + ([section count]-1);
    }
    return total;
}
-(NSUInteger)totalCellItemsInLastSection
{
    if (cellItems != nil)
    {
        return [[cellItems objectAtIndex:[cellItems count]-1] count];
    }
    return 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset == 0)
    {
        // then we are at the top
    }
    else if (scrollOffset + scrollViewHeight >= scrollContentSizeHeight)
    {
        // then we are at the end
        
        if (!isLoadingMore)
        {
            NSLog(@"AT END!!!");
            NSLog(@"load more....");
            isLoadingMore = true;
            [self reloadData];
        }
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

    NSDictionary *video = [[cellItems[indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"video"];
    if([delegate respondsToSelector:@selector(onDemandPressed:)])
    {
        // should update view count
        int video_id =[[video valueForKey:@"video_id"] intValue];
        int exclusive =[[video valueForKey:@"exclusive"] intValue];
        int purchased =[[video valueForKey:@"purchased"] intValue];
        int price =[[video valueForKey:@"price"] intValue];
        
        if (exclusive == 1 && purchased == 0)
        {
           
            [UIAlertView showWithTitle:@"Confirm Purchase"
                               message:[NSString stringWithFormat:@"Would you like to purchase access to this video?"]
                     cancelButtonTitle:@"No"
                     otherButtonTitles:@[@"Yes"]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      
                                      NSLog(@"Cancelled");
                                      
                                  } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
                                      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                                      
                                      NSString *productIdentifier;
                                      if (price == 60)
                                      {
                                          productIdentifier = [NSString stringWithFormat:@"%iCREDITS",price];
                                      } else {
                                          productIdentifier = [NSString stringWithFormat:@"%iCREDIT",price];
                                      }
                                      
                                      
                                      [[IAPManager sharedIAPManager] purchaseProductForId:productIdentifier completion:^(SKPaymentTransaction *transaction) {
                                          [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                          if (transaction.transactionState == SKPaymentTransactionStatePurchased)
                                          {
                                              NSLog(@"PURCHASED: %@",transaction.transactionIdentifier);
                                              [[GSSharedData sharedManager] submitVideoPurchased:video_id andTransactionIdentifier:transaction.transactionIdentifier];
                                              
                                              [delegate onDemandPressed:video];
                                              
                                          } else {
                                              
                                               [self alertStatus:[NSString stringWithFormat:@"Failed with status code: %li",(long)transaction.transactionState] :@"Failed" :0];
                                          
                                          }
                                          
                                          
                                          
                                      } error:^(NSError *err) {
                                          
                                          [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                          [self alertStatus:err.localizedDescription :@"Failed" :0];
                                          
                                      }];
                                      
                                  
                                  
                                  }
                              }];
            
        } else
        {
              [delegate onDemandPressed:video];
        }
        
        
    }
}


-(void)collectionCellDidPressCategory:(int)cat_id
{
    if ([self.delegate respondsToSelector:@selector(collectionCellDidPressCategory:)]) {
        [delegate collectionCellDidPressCategory:cat_id];
    }
}



#pragma UIAlertView+Purchasing
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case ALART_TAG_CONFIRMPURCHASE:
        {
            
            NSString *title = [popup buttonTitleAtIndex:buttonIndex];
            
            int credits = [[[title stringByReplacingOccurrencesOfString:@"CREDITS" withString:@""] stringByReplacingOccurrencesOfString:@"CREDIT" withString:@""]  intValue];
            
            [[IAPManager sharedIAPManager] purchaseProductForId:title
                                                     completion:^(SKPaymentTransaction *transaction) {
                                                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                         
                                                         [[GSSharedData sharedManager] submitCreditsPurchased:credits];
                                                         
                                                         [self alertStatus:@"Credits have been purchased adn added to your account. You can now purchase the video." :@"Completed" :0];
                                                         
                                                     } error:^(NSError *err) {
                                                         
                                                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                         [self alertStatus:err.localizedDescription :@"Failed" :0];
                                                         
                                                     }];
        }
        default:
            break;
    }
}

@end
