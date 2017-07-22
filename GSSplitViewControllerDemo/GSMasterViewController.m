//
//  GSMasterViewController.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 2015-08-10.
//  Copyright (c) 2014 Mindzone Company Limited. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "GSMasterViewController.h"
#import "GSDetailViewController.h"
#import "MLPAccessoryBadge.h"
#import "UIColor+MLPFlatColors.h"
#import "GSAppDelegate.h"
#import "KeychainItemWrapper.h"
#import "GSSharedData.h"

@interface GSMasterViewController () {
    NSArray *_objects;
}
@end

@implementation GSMasterViewController

@synthesize profileNameLabel = _profileNameLabel;
@synthesize profileNameSubLabel = _profileNameSubLabel;
@synthesize profileView = _profileView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel* lbNavTitle = [[UILabel alloc] initWithFrame:self.navigationController.view.frame];
    lbNavTitle.textAlignment = NSTextAlignmentLeft;
    lbNavTitle.textColor = [UIColor whiteColor];
    lbNavTitle.text = NSLocalizedString(@"Home", @"Home");
    self.navigationItem.titleView = lbNavTitle;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:11/255.0 green:167/255.0 blue:157/255.0 alpha:1.0];
    
    // SET CLOSING IMAGE NAVBAR
    UIImage *faceImage = [UIImage imageNamed:@"side-menu-arrow"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    [[face imageView] setContentMode: UIViewContentModeScaleAspectFit];
    face.bounds = CGRectMake( 10, 0, 11, 16 );//set bound as per you want
    [face addTarget:self action:@selector(sideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [face setImage:faceImage forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    self.navigationItem.rightBarButtonItem = backButton;
    // END SET CLOSING IMAGE NAVBAR
    
    
    
    // MAKE PROFILE IMAGE CIRCLE
    _profileView.layer.cornerRadius = _profileView.frame.size.width / 2.0;
    _profileView.clipsToBounds = YES;
    _profileView.layer.borderWidth =3.0;
    _profileView.layer.borderColor=[UIColor whiteColor].CGColor;
    // END PROFILE IMAGE CIRCLE
    
    [self loadSideMenuItems];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [NSTimer scheduledTimerWithTimeInterval: 15.0
                                             target: self
                                           selector:@selector(touchUserInfo)
                                           userInfo: nil repeats:YES];
}


-(void)touchUserInfo
{
    [[GSSharedData sharedManager] touch];
}

-(void)sideMenuButtonPressed:(id)sender
{
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.splitViewController setMasterPaneShown:NO animated:YES];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollToTop
{
    [self.tableView setContentOffset:CGPointZero animated:YES];
}



-(void)loadSideMenuItems
{
    
    if (jsonData == nil) [self loadCategories];
    
    [self.profileNameLabel setFont:[UIFont systemFontOfSize:FONTSIZE18]];
    [self.profileNameSubLabel setFont:[UIFont systemFontOfSize:FONTSIZE18]];
    self.profileNameSubLabel.hidden = NO;
    
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"logged_in"]) {
        // not logged in!
        
        
        self.profileNameLabel.text = NSLocalizedString(@"Guest", @"Guest");
        self.profileNameSubLabel.text = NSLocalizedString(@"Not Logged in", @"Not Logged in");
        self.profileView.image = [UIImage imageNamed:@"empty-profile"];
        
        
        int subcount = 0;
        for (NSDictionary *object in [jsonData.responseData objectForKey:@"categories"])
        {
            subcount++;
        }
        int subcount_education = 0;
        for (NSDictionary *object in [jsonData.responseData objectForKey:@"categories_education"])
        {
            subcount_education++;
        }
        
        
        NSMutableArray *categoriesArray = [[NSMutableArray alloc] init];
        [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"VIDEOPLAYER1", @"title": @"    iC Live",@"id":@"0", @"badge": @"0" }]];
        [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"VIDEOPLAYER1", @"title": @"    iC Varieties",@"id":@"2", @"badge": @"0" }]];
        [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"VIDEOPLAYER3", @"title": @"    iC Tube", @"badge": [NSString stringWithFormat:@"%i",subcount] }]];

        if (jsonData != nil && showSubMenu)
        {
            [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"0",@"VIEW": @"VIDEOPLAYER2", @"title": NSLocalizedString(@"    All", @"    All"), @"badge": @"0", @"id" : @"0"}]];
            for (NSDictionary *object in [jsonData.responseData objectForKey:@"categories"])
            {
                [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"0",@"VIEW": @"VIDEOPLAYER2", @"title": [NSString stringWithFormat:@"        %@",[[object valueForKey:@"category"] valueForKey:@"name"]], @"badge": @"0", @"id" : [[object valueForKey:@"category"] valueForKey:@"id"]}]];
            }
        }
        
        [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"VIDEOPLAYER4", @"title": @"    iC Education", @"badge": [NSString stringWithFormat:@"%i",subcount_education] }]];
        if (jsonData != nil && showSubMenu_education)
        {
            [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"0",@"VIEW": @"VIDEOPLAYER5", @"title": NSLocalizedString(@"    All", @"    All"), @"badge": @"0", @"id" : @"0"}]];
            for (NSDictionary *object in [jsonData.responseData objectForKey:@"categories_education"])
            {
                [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"0",@"VIEW": @"VIDEOPLAYER5", @"title": [NSString stringWithFormat:@"        %@",[[object valueForKey:@"category"] valueForKey:@"name"]], @"badge": @"0", @"id" : [[object valueForKey:@"category"] valueForKey:@"id"]}]];
            }
        }
        
        
        
        cellItems = @{
                      @"ACCOUNT" : @[
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"LOGIN", @"title": NSLocalizedString(@"    Login", @"    Login"), @"badge": @"0" }],
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"REGISTER", @"title": NSLocalizedString(@"    Register",@"    Register"), @"badge": @"0" }]
                              ],
                      @"CATEGORIES" : categoriesArray,
                      @"OTHER" : @[
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"NEWS", @"title": NSLocalizedString(@"    News", @"    News"), @"badge": @"0" }],
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"HELP", @"title": NSLocalizedString(@"    Help", @"    Help"), @"badge": @"0" }],
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"ABOUT", @"title": NSLocalizedString(@"    About MOBI Television", @"    About MOBI Television"), @"badge": @"0" }],
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"RESTOREPURCHASES", @"title": NSLocalizedString(@"    Restore Purchases", @"    Restore Purchases"), @"badge": @"0" }]
                              ]
                      };
        
    } else {
        // logged in
        
        //NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
        NSString *user_email = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_email"];
        NSString *user_name = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_name"];
        NSString *user_credits = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_credits"];
        NSString *fb_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"fb_id"];
        
        self.profileNameSubLabel.text = @"";
        
        if (user_credits != nil && user_email != nil) {
            // Code to log user in
            self.profileNameLabel.text = user_name;
            self.profileNameSubLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@\r\n%@ Credits", @"%@\r\n%@ Credits"),user_email,user_credits];
            
            
            
        }
        if (fb_id != nil) {
            // Code to log user in
            self.profileView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=640&height=640",fb_id]];
        }
        
        int subcount = 0;
        for (NSDictionary *object in [jsonData.responseData objectForKey:@"categories"])
        {
            subcount++;
        }
        int subcount_education = 0;
        for (NSDictionary *object in [jsonData.responseData objectForKey:@"categories_education"])
        {
            subcount_education++;
        }
        
        NSMutableArray *categoriesArray = [[NSMutableArray alloc] init];
        [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"VIDEOPLAYER1", @"title": @"    iC Live",@"id":@"0", @"badge": @"0" }]];
        [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"VIDEOPLAYER1", @"title": @"    iC Varieties",@"id":@"2", @"badge": @"0" }]];
        [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"VIDEOPLAYER3", @"title": @"    iC Tube", @"badge": [NSString stringWithFormat:@"%i",subcount] }]];
        if (jsonData != nil && showSubMenu)
        {
            [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"0",@"VIEW": @"VIDEOPLAYER2", @"title": NSLocalizedString(@"    All", @"    All"), @"badge": @"0", @"id" : @"0"}]];
            for (NSDictionary *object in [jsonData.responseData objectForKey:@"categories"])
            {
                [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"0",@"VIEW": @"VIDEOPLAYER2", @"title": [NSString stringWithFormat:@"        %@",[[object valueForKey:@"category"] valueForKey:@"name"]], @"badge": @"0", @"id" : [[object valueForKey:@"category"] valueForKey:@"id"]}]];
            }
        }
        
        [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"VIDEOPLAYER4", @"title": @"    iC Education", @"badge": [NSString stringWithFormat:@"%i",subcount_education] }]];
        if (jsonData != nil && showSubMenu_education)
        {
            [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"0",@"VIEW": @"VIDEOPLAYER5", @"title": NSLocalizedString(@"    All", @"    All"), @"badge": @"0", @"id" : @"0"}]];
            for (NSDictionary *object in [jsonData.responseData objectForKey:@"categories_education"])
            {
                [categoriesArray addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"0",@"VIEW": @"VIDEOPLAYER5", @"title": [NSString stringWithFormat:@"        %@",[[object valueForKey:@"category"] valueForKey:@"name"]], @"badge": @"0", @"id" : [[object valueForKey:@"category"] valueForKey:@"id"]}]];
            }
        }
        
        cellItems = @{
                      @"ACCOUNT" : @[
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"PROFILE", @"title": NSLocalizedString(@"    My Profile", @"    My Profile"), @"badge": @"0" }],
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"FAVOURITES", @"title": NSLocalizedString(@"    Favourites", @"    Favourites"), @"badge": @"0" }],
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"VIDEOS", @"title": NSLocalizedString(@"    My VDO", @"    My VDO"), @"badge": @"0" }],
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"PURCHASED", @"title": NSLocalizedString(@"    Purchased", @"    Purchased"), @"badge": @"0" }]
                              ],
                      @"CATEGORIES" : categoriesArray,
                      @"OTHER" : @[
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"NEWS", @"title": NSLocalizedString(@"    News", @"    News"), @"badge": @"0" }],
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"HELP", @"title": NSLocalizedString(@"    Help", @"    Help"), @"badge": @"0" }],
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"ABOUT", @"title": NSLocalizedString(@"    About MOBI Television", @"    About MOBI Television"), @"badge": @"0" }],
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"LOGOUT", @"title": NSLocalizedString(@"    Logout", @"    Logout"), @"badge": @"0" }],
                              [[GSMasterCellObjectItem alloc] initWithDict:@{ @"image":@"1",@"VIEW": @"RESTOREPURCHASES", @"title": NSLocalizedString(@"    Restore Purchases", @"    Restore Purchases"), @"badge": @"0" }]
                              ]
                      };
    }
    
    SectionTitles = [[cellItems allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.tableView reloadData];
}



-(void)splitViewController:(GSSplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self loadSideMenuItems];
}




-(void)loadCategories
{
    
    // add params!
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] init];
    
    // do upload
    self.flUploadEngine = [[fileUploadEngine alloc] initWithHostName:API_HOST customHeaderFields:nil];
    
    self.flOperation = [self.flUploadEngine postDataToServer:postParams path:[NSString stringWithFormat:@"%@categories",API_END_POINT]];
    [self.flOperation addCompletionHandler:^(MKNetworkOperation* operation) {
        jsonData = [[GSApiResponseObjectItem alloc] initWithNSData:[[operation responseString] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (jsonData.statusCode > 0)
        {
            // an error occurred
            
            
        } else {
            
            // no error
            GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
            appDelegate.categories = [[NSMutableArray alloc] init];
            
            for (NSDictionary *object in [jsonData.responseData objectForKey:@"categories"])
            {
                [appDelegate.categories addObject:[[GSMasterCellObjectItem alloc] initWithDict:@{ @"title": [[object valueForKey:@"category"] valueForKey:@"name"], @"id" : [[object valueForKey:@"category"] valueForKey:@"id"]}]];
            }
            
            [self loadSideMenuItems];
        }
    }
                              errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
                                  
                                  
                              }
     ];
    
    [self.flUploadEngine enqueueOperation:self.flOperation];
}



#pragma mark - Table View
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    [header.textLabel setFont:[UIFont boldSystemFontOfSize:11.0]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [SectionTitles objectAtIndex:section];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [SectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *sectionTitle = [SectionTitles objectAtIndex:section];
    NSArray *sectionItems = [cellItems objectForKey:sectionTitle];
    
    
    return [sectionItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *sectionTitle = [SectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionItems = [cellItems objectForKey:sectionTitle];
    GSMasterCellObjectItem *item = [sectionItems objectAtIndex:indexPath.row];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.textLabel.text = [item.data objectForKey:@"title"];
    [cell.textLabel setFont:[UIFont systemFontOfSize:FONTSIZE18]];
    
    int badge = [[item.data objectForKey:@"badge"] intValue];
    if (badge > 0)
    {
        MLPAccessoryBadge *accessoryBadge = [MLPAccessoryBadge new];
        [accessoryBadge setText:[NSString stringWithFormat:@"%i",badge ]];
        [accessoryBadge setCornerRadius:6];
        [accessoryBadge setTextColor:[UIColor flatSystemGreenColor]];
        [accessoryBadge.textLabel setShadowOffset:CGSizeZero];
        [accessoryBadge setHighlightAlpha:0];
        [accessoryBadge setShadowAlpha:0];
        [accessoryBadge setBackgroundColor:[UIColor flatWhiteColor]];
        [accessoryBadge setGradientAlpha:0];
        [cell setAccessoryView:accessoryBadge];
    } else {
        [cell setAccessoryView:nil];
        
    }
    
    //if ([[item.data objectForKey:@"image"] isEqualToString:@"1"])
   // {
    
        UIImageView *backgroundCellImage=[[UIImageView alloc] initWithFrame:CGRectMake(10, (cell.frame.size.height/2)-6, 8, 12)];
        backgroundCellImage.tag = 1;
        backgroundCellImage.image=[UIImage imageNamed:@"side-menu-arrow"];
        [cell.contentView addSubview:backgroundCellImage];
   
    //} else {
        
    //    UIImageView *backgroundCellImage = (UIImageView*)[cell.contentView viewWithTag:1];
    //    [backgroundCellImage removeFromSuperview];
    //    backgroundCellImage = nil;
        
    //}
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [cell setNeedsDisplay];
    });
    return cell;
    
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionTitle = [SectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionItems = [cellItems objectForKey:sectionTitle];
    GSMasterCellObjectItem *item = [sectionItems objectAtIndex:indexPath.row];
    
    NSLog(@"%@",item.data);
    
    if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"LOGIN"])
    {
        if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSLoginViewController class]])
        {
            GSLoginViewController *detailViewController = [[GSLoginViewController alloc] initWithNibName:@"GSLoginViewController" bundle:nil];
            [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
        }
        
    } else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"REGISTER"])
    {
        if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSRegisterViewController class]])
        {
            GSRegisterViewController *detailViewController = [[GSRegisterViewController alloc] initWithNibName:@"GSRegisterViewController" bundle:nil];
            [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
        }
        
    } else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"FAVOURITES"])
    {
        if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSFavouritesViewController class]])
        {
            GSFavouritesViewController *detailViewController = [[GSFavouritesViewController alloc] initWithNibName:@"GSFavouritesViewController" bundle:nil];
            detailViewController.delegate = self;
            [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
        }
        
    } else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"VIDEOS"])
    {
        if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSVideosViewController class]])
        {
            GSVideosViewController *detailViewController = [[GSVideosViewController alloc] initWithNibName:@"GSVideosViewController" bundle:nil];
            detailViewController.delegate = self;
            [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
        }
        
    } else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"PURCHASED"])
    {
        
        if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSPurchasedViewController class]])
        {
            GSPurchasedViewController *detailViewController = [[GSPurchasedViewController alloc] initWithNibName:@"GSPurchasedViewController" bundle:nil];
            detailViewController.delegate = self;
            [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
        }
    } else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"PROFILE"])
    {
        if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSProfileViewController class]])
        {
            GSProfileViewController *detailViewController = [[GSProfileViewController alloc] initWithNibName:@"GSProfileViewController" bundle:nil];
            [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
        }
        
        
    } else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"NEWS"])
    {
        if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSNewsViewController class]])
        {
            GSNewsViewController *detailViewController = [[GSNewsViewController alloc] initWithNibName:@"GSNewsViewController" bundle:nil];
            [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
        }
        
        
    } else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"ABOUT"])
    {
        if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSAboutViewController class]])
        {
            GSAboutViewController *detailViewController = [[GSAboutViewController alloc] initWithNibName:@"GSAboutViewController" bundle:nil];
            [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
        }
        
        
    } else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"RESTOREPURCHASES"])
    {
    
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"Restore Purchases", @"Restore Purchases")
                                              message:NSLocalizedString(@"To restore previous purchases, please login on both devices with the same account. After logging in, your purchases will be available on all devices.", @"To restore previous purchases, please login on both devices with the same account. After logging in, your purchases will be available on all devices.")
                                              preferredStyle:UIAlertControllerStyleAlert];

        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                   }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        
        
    } else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"HELP"])
    {
        if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSHelpViewViewController class]])
        {
            GSHelpViewViewController *detailViewController = [[GSHelpViewViewController alloc] initWithNibName:@"GSHelpViewViewController" bundle:nil];
            [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
        }
    } else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"LOGOUT"])
    {
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadSideMenuItems];
        
        if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSDetailViewController class]])
        {
            GSDetailViewController *detailViewController = [[GSDetailViewController alloc] initWithNibName:@"GSDetailViewController" bundle:nil];
            [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
        }
        
        
    } else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"VIDEOPLAYER4"]) {
        
        if (showSubMenu_education)
        {
            showSubMenu = NO;
            showSubMenu_education = NO;
        } else {
            showSubMenu = NO;
            showSubMenu_education = YES;
        }
        [self loadSideMenuItems];
        return;
        
        
    } else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"VIDEOPLAYER3"]) {
        
        if (showSubMenu)
        {
            showSubMenu = NO;
            showSubMenu_education = NO;
        } else {
            showSubMenu = YES;
            showSubMenu_education = NO;
        }
        [self loadSideMenuItems];
        return;
        
    } else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"VIDEOPLAYER1"])
    {
        NSLog(@"%@", item.data);
       
        GSDetailViewController *detailViewController;
        if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSDetailViewController class]])
        {
            detailViewController = [[GSDetailViewController alloc] initWithNibName:@"GSDetailViewController" bundle:nil];
            [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
            [detailViewController setSegmentIndex:0];
        } else {
            detailViewController = (GSDetailViewController*)self.detailViewNavController.visibleViewController;
            [detailViewController setSegmentIndex:0];
        }
        
        if ([item.data objectForKey:@"id"])
        {
            [detailViewController liveStreamByID: [[item.data objectForKey:@"id"] intValue]];
        }
        
    }  else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"VIDEOPLAYER2"])
    {
        
        
        if ([item.data objectForKey:@"id"] == nil)
        {
            if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSDetailViewController class]])
            {
                GSDetailViewController *detailViewController = [[GSDetailViewController alloc] initWithNibName:@"GSDetailViewController" bundle:nil];
                [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
                [detailViewController setSegmentWithIndex:1 andCategory:0];
            } else {
                GSDetailViewController *detailViewController = (GSDetailViewController*)self.detailViewNavController.visibleViewController;
                [detailViewController setSegmentWithIndex:1 andCategory:0];
            }
        } else {
            
            int category_id = [[item.data objectForKey:@"id"] intValue];
            if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSDetailViewController class]])
            {
                GSDetailViewController *detailViewController = [[GSDetailViewController alloc] initWithNibName:@"GSDetailViewController" bundle:nil];
                [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
                 [detailViewController setSegmentWithIndex:1 andCategory:category_id];
            } else {
                // SET CATEGORY! - already right class
                GSDetailViewController *detailViewController = (GSDetailViewController*)self.detailViewNavController.visibleViewController;
                [detailViewController setSegmentWithIndex:1 andCategory:category_id];
            }
           
        }
        
        
    }else if ([[item.data objectForKey:@"VIEW"] isEqualToString:@"VIDEOPLAYER5"])
    {
        
        
        
        if ([[GSSharedData sharedManager] userHasEducationAccess])
        {
            if ([item.data objectForKey:@"id"] == nil)
            {
                if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSDetailViewController class]])
                {
                    GSDetailViewController *detailViewController = [[GSDetailViewController alloc] initWithNibName:@"GSDetailViewController" bundle:nil];
                    [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
                    [detailViewController setSegmentWithIndex:2 andCategory:0];
                } else {
                    GSDetailViewController *detailViewController = (GSDetailViewController*)self.detailViewNavController.visibleViewController;
                    [detailViewController setSegmentWithIndex:2 andCategory:0];
                }
            } else {
                
                int category_id = [[item.data objectForKey:@"id"] intValue];
                if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSDetailViewController class]])
                {
                    GSDetailViewController *detailViewController = [[GSDetailViewController alloc] initWithNibName:@"GSDetailViewController" bundle:nil];
                    [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
                    [detailViewController setSegmentWithIndex:2 andCategory:category_id];
                } else {
                    // SET CATEGORY! - already right class
                    GSDetailViewController *detailViewController = (GSDetailViewController*)self.detailViewNavController.visibleViewController;
                    [detailViewController setSegmentWithIndex:2 andCategory:category_id];
                }
                
            }
        } else {
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@""
                                                  message:@""
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               NSLog(@"Cancel action");
                                           }];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"OK action");
                                       }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        
        
        
        
        
    }

    
    
    [self sideMenuButtonPressed:nil];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.textLabel.textColor = [UIColor whiteColor];
}







-(void)onDemandCellPressed:(NSDictionary *)video
{
    
    int category_id =[[video valueForKey:@"category_id"] intValue];
    
    if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSDetailViewController class]])
    {
        GSDetailViewController *detailViewController = [[GSDetailViewController alloc] initWithNibName:@"GSDetailViewController" bundle:nil];
        [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
        [detailViewController setSegmentWithIndex:1 andCategory:category_id];
        // press videoooooo
        [detailViewController onDemandPressed:video];
    } else {
        // SET CATEGORY! - already right class
        GSDetailViewController *detailViewController = (GSDetailViewController*)self.detailViewNavController.visibleViewController;
        [detailViewController setSegmentWithIndex:1 andCategory:category_id];
        // press videoooooo
        [detailViewController onDemandPressed:video];
    }
}


-(void)collectionCellDidPressCategory:(int)category_id
{
    NSLog(@"collectionCellDidPressCategory....");
    if (![self.detailViewNavController.visibleViewController isKindOfClass:[GSDetailViewController class]])
    {
        GSDetailViewController *detailViewController = [[GSDetailViewController alloc] initWithNibName:@"GSDetailViewController" bundle:nil];
        [self.detailViewNavController setViewControllers:@[detailViewController] animated:NO];
        [detailViewController setSegmentWithIndex:1 andCategory:category_id];
    } else {
        // SET CATEGORY! - already right class
        GSDetailViewController *detailViewController = (GSDetailViewController*)self.detailViewNavController.visibleViewController;
        [detailViewController setSegmentWithIndex:1 andCategory:category_id];
    }
}



@end
