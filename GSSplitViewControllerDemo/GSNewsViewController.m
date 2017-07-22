//
//  GSNewsViewController.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/18/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import "GSNewsViewController.h"

@interface GSNewsViewController ()

@end

@implementation GSNewsViewController

@synthesize tableView, refreshControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"NEWS", @"NEWS");
    
    // END ADD BUTTONS
    UIButton *navBarButtonOpenMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    navBarButtonOpenMenu.bounds = CGRectMake( 0, 0, 24, 24);
    [navBarButtonOpenMenu setImage:[UIImage imageNamed:@"open-menu-burger"] forState:UIControlStateNormal];
    UIBarButtonItem *navBarButtonOpenMenuItem = [[UIBarButtonItem alloc] initWithCustomView:navBarButtonOpenMenu];
    self.navigationItem.leftBarButtonItem = navBarButtonOpenMenuItem;
    [navBarButtonOpenMenu addTarget:self action:@selector(sideMenuOpenButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    // END ADD BUTTONS
    

    // ADD LOADER
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    // EMPTY DATA
    dataArray = [[NSArray alloc] init];
    
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
    // show loader...
    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
    HUD.labelText = NSLocalizedString(@"Connecting...", @"Connecting...");
    [HUD show:YES];
    
    // do upload
    self.flUploadEngine = [[fileUploadEngine alloc] initWithHostName:API_HOST customHeaderFields:nil];
    
    // add params!
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] init];
  // [postParams setObject:@"email" forKey:@"method"];
 //   NSLog(@"%@",postParams);
    
    
    self.flOperation = [self.flUploadEngine postDataToServer:postParams path:[NSString stringWithFormat:@"%@news",API_END_POINT]];
    
    [self.flOperation addCompletionHandler:^(MKNetworkOperation* operation) {
        
        jsonData = [[GSApiResponseObjectItem alloc] initWithNSData:[[operation responseString] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (jsonData.statusCode > 0)
        {
            // an error occurred
            HUD.labelText = jsonData.statusMessage;
            [HUD hide:YES afterDelay:2.0];
        } else {
            // no error
            
            
            int count = [[jsonData.responseData valueForKey:@"count"] intValue];
            if (count == 0)
            {
                HUD.labelText = @"No news articles";
            } else {
                // End the refreshing
                if (self.refreshControl)
                {
                    
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"MMM d, h:mm a"];
                    NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
                    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                                forKey:NSForegroundColorAttributeName];
                    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
                    self.refreshControl.attributedTitle = attributedTitle;
                    [self.refreshControl endRefreshing];
                } else {
                    // REFRESH CONTROL - added after first load due to layout problem
                    self.refreshControl = [[UIRefreshControl alloc] init];
                    self.refreshControl.backgroundColor = [UIColor flatSystemGreenColor];
                    self.refreshControl.tintColor = [UIColor whiteColor];
                    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
                    [self.refreshControl endRefreshing];
                    [self.tableView addSubview:self.refreshControl];
                }

                // set data array
                dataArray = [jsonData.responseData objectForKey:@"articles"];
                NSLog(@"%@",dataArray);
                
                
                // Reload table data
                [self.tableView reloadData];
                
            }
            HUD.progress = 100;
            [HUD hide:YES afterDelay:1.0];
        }
    }
    errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
        HUD.labelText = error.localizedDescription;
        [HUD hide:YES afterDelay:2];
    }
    ];
    
    [self.flOperation onUploadProgressChanged:^(double progress) {
        HUD.progress = progress;
        HUD.labelText = [NSString stringWithFormat:@"%.0f%%",progress*100];
    }];
    
    [self.flUploadEngine enqueueOperation:self.flOperation];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    return [dataArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CustomNewsCell";
    
    GSNewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"GSNewsTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    
    NSDictionary *article = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"article"];
    cell.lblHeader.text = [article valueForKey:@"title"];
    cell.lblDescription.text = [article valueForKey:@"content"];
    cell.imageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@news/%i.png",API_IMAGE_HOST,[[article valueForKey:@"id"] intValue]]];
    
    [cell.lblDescription setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *article = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"article"];
    int article_id = [[article valueForKey:@"id"] intValue];
    
    [self openArticle:article_id];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


-(void)openArticle:(int)article_id
{
    // show loader...
    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
    HUD.labelText = NSLocalizedString(@"Connecting...", @"Connecting...");
    [HUD show:YES];
    
    // do upload
    self.flUploadEngine = [[fileUploadEngine alloc] initWithHostName:API_HOST customHeaderFields:nil];
    
    // add params!
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] init];
    [postParams setObject:[NSString stringWithFormat:@"%i",article_id] forKey:@"id"];
    
    self.flOperation = [self.flUploadEngine postDataToServer:postParams path:[NSString stringWithFormat:@"%@news_article",API_END_POINT]];
    
    [self.flOperation addCompletionHandler:^(MKNetworkOperation* operation) {
        
        jsonData = [[GSApiResponseObjectItem alloc] initWithNSData:[[operation responseString] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (jsonData.statusCode > 0)
        {
            // an error occurred
            HUD.labelText = jsonData.statusMessage;
            [HUD hide:YES afterDelay:2.0];
        } else {
            // no error

            GSNewsArticleViewController *detailViewController = [[GSNewsArticleViewController alloc] initWithNibName:@"GSNewsArticleViewController" bundle:nil];
            detailViewController.jsonData = jsonData;
            [self.navigationController pushViewController:detailViewController animated:YES];
            HUD.progress = 100;
            [HUD hide:YES afterDelay:1.0];
        }
    }
                              errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
                                  HUD.labelText = error.localizedDescription;
                                  [HUD hide:YES afterDelay:2];
                              }
     ];
    
    [self.flOperation onUploadProgressChanged:^(double progress) {
        HUD.progress = progress;
        HUD.labelText = [NSString stringWithFormat:@"%.0f%%",progress*100];
    }];
    
    [self.flUploadEngine enqueueOperation:self.flOperation];
}

@end
