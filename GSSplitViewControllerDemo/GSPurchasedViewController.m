//
//  GSFavouritesViewController.m
//  GSSplitViewControllerDemo
//
//  Created by Renee van der Kooi on 8/24/2558 BE.
//  Copyright (c) 2558 Mindzone Company Limited. All rights reserved.
//

#import "GSPurchasedViewController.h"
#import "URLConnection.h"
#import "UIImageView+AFNetworking.h"

@interface GSPurchasedViewController ()

@end

@implementation GSPurchasedViewController

@synthesize delegate,imageView, lblProfileName, collectionView;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"PURCHASES", @"PURCHASES");
    
    // END ADD BUTTONS
    UIButton *navBarButtonOpenMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    navBarButtonOpenMenu.bounds = CGRectMake( 0, 0, 24, 24);
    [navBarButtonOpenMenu setImage:[UIImage imageNamed:@"open-menu-burger"] forState:UIControlStateNormal];
    UIBarButtonItem *navBarButtonOpenMenuItem = [[UIBarButtonItem alloc] initWithCustomView:navBarButtonOpenMenu];
    self.navigationItem.leftBarButtonItem = navBarButtonOpenMenuItem;
    [navBarButtonOpenMenu addTarget:self action:@selector(sideMenuOpenButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    // END ADD BUTTONS
    
    
    // MAKE PROFILE IMAGE CIRCLE
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2.0;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.borderWidth =3.0;
    self.imageView.layer.borderColor=[UIColor whiteColor].CGColor;
    // END PROFILE IMAGE CIRCLE
    
    
    
    // COLLECTIONVIEW
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    collectionView.collectionViewLayout = flowLayout;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    collectionView.delegate = self;
    collectionView.dataSource =self;
    nibMyCellloaded = NO;
    [collectionView registerClass:[VideoCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    collectionView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:248.0/255.0 blue:251.0/255.0 alpha:1];
    
    // REFRESH CONTROL
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor lightGrayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [collectionView addSubview:refreshControl];
    collectionView.alwaysBounceVertical = YES;
    collectionView.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
    [refreshControl beginRefreshing];
    //////////
    
    
    noitemslabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 30)];
    noitemslabel.text = NSLocalizedString(@"No items found", @"No items found");
    noitemslabel.textAlignment = NSTextAlignmentCenter;
    [collectionView addSubview:noitemslabel];
    
    //NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    NSString *user_email = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_email"];
    NSString *user_credits = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_credits"];
    NSString *fb_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"fb_id"];
    if (user_credits != nil && user_email != nil) {
        // Code to log user in
        self.lblProfileName.text = user_email;
    }
    if (fb_id != nil) {
        // Code to log user in
        self.imageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=640&height=640",fb_id]];
    }
    
    // ADD LOADER
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    
    
    // LOAD NEWS
    [self reloadData];
}

-(void)sideMenuOpenButtonPressed:(id)sender
{
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.splitViewController setMasterPaneShown:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)reloadData
{
     GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@purchased",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    NSString *postString = [NSString stringWithFormat:@"user_id=%@&device_uuid=%@",user_id,[appDelegate deviceID]];
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
                 
                 HUD.labelText = NSLocalizedString(@"No Videos", @"No Videos");
                 [HUD show:YES];
                 [HUD hide:YES afterDelay:2.0];
                 noitemslabel.hidden = NO;
             } else {
                 
                 // cellitems
                 cellItems = [jsonData.responseData valueForKey:@"videos"];
                 
                 // Reload table data
                 [self->collectionView reloadData];
                 noitemslabel.hidden = YES;
             }
             
             
             
         }
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         HUD.labelText = NSLocalizedString(@"Could not connect", @"Could not connect");
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
        UINib *nib = [UINib nibWithNibName:@"VideoCollectionViewCell" bundle: nil];
        [cv registerNib:nib forCellWithReuseIdentifier:identifier];
        nibMyCellloaded = YES;
    }
    VideoCollectionViewCell *cell = (VideoCollectionViewCell*)[cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    
    NSDictionary *video = [[cellItems objectAtIndex:indexPath.row] objectForKey:@"video"];
    int category_id =[[video valueForKey:@"category_id"] intValue];
    int likes =[[video valueForKey:@"likes"] intValue];
    int views =[[video valueForKey:@"views"] intValue];
    int favourite =[[video valueForKey:@"favourite"] intValue];
    int exclusive =[[video valueForKey:@"exclusive"] intValue];
    int video_id =[[video valueForKey:@"video_id"] intValue];
    
    cell.video_id = video_id;
    cell.category_id = category_id;
    cell.favourite = favourite;
    
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@ondemand/screenshots/%i.png",API_IMAGE_HOST,[[video valueForKey:@"video_id"] intValue]]] placeholderImage:nil];
    cell.lblHeader.text = [video valueForKey:@"title"];
    cell.lblSubheader.text = [video valueForKey:@"description"];
    cell.lblLikes.text = [NSString stringWithFormat:@"%i",likes];
    cell.lblViews.text = [NSString stringWithFormat:@"%i",views];
    [cell.badgeView setTitle:[video valueForKey:@"category"] forState:UIControlStateNormal];
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
        return CGSizeMake(SCREEN_WIDTH - 20, 68);
    }
    UIInterfaceOrientation interfaceOrientation =[[UIApplication sharedApplication] statusBarOrientation];
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        return CGSizeMake(354, 82);
    } else {
        return CGSizeMake(322, 82);
    }
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath");
    NSDictionary *video = [[cellItems objectAtIndex:indexPath.row] objectForKey:@"video"];
    if ([self.delegate respondsToSelector:@selector(onDemandCellPressed:)]) {
        [delegate onDemandCellPressed:video];
    }
}

-(void)collectionCellDidPressCategory:(int)category_id
{
    if ([self.delegate respondsToSelector:@selector(collectionCellDidPressCategory:)]) {
        [delegate collectionCellDidPressCategory:category_id];
    }
}

-(void)collectionCellDidPressCategoryForEducation:(int)category_id
{
    
}

@end
