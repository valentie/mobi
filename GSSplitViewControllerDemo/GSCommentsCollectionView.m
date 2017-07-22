//
//  GSLiveTvCollectionView.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/19/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import "GSCommentsCollectionView.h"
#import "Constants.h"
#import "GSMasterCellObjectItem.h"
#import "URLConnection.h"
#import "DAKeyboardControl.h"

@implementation GSCommentsCollectionView

@synthesize delegate;



- (void)initialize
{

    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f,
                                                                        0.0f,
                                                                        self.bounds.size.width,
                                                                        self.bounds.size.height - 40.0f) collectionViewLayout:flowLayout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:collectionView];
    collectionView.delegate = self;
    collectionView.dataSource =self;
    nibMyCommentsCellloaded = NO;
    [collectionView registerClass:[CommentListCollectionViewCell class] forCellWithReuseIdentifier:@"cellComments"];
    collectionView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:248.0/255.0 blue:251.0/255.0 alpha:1];
    
    
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                     self.bounds.size.height - 40.0f,
                                                                     self.bounds.size.width,
                                                                     40.0f)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    toolBar.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0];
    [self addSubview:toolBar];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f,
                                                                           6.0f,
                                                                           toolBar.bounds.size.width - 20.0f - 68.0f,
                                                                           30.0f)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField.placeholder = @"  เขียนข้อความ";
    [textField setBorderStyle:UITextBorderStyleNone];
    textField.backgroundColor = [UIColor whiteColor];
    textField.delegate = self;
    [toolBar addSubview:textField];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [sendButton setTitle:@"ส่ง" forState:UIControlStateNormal];
    sendButton.backgroundColor = [UIColor colorWithRed:11/255.0 green:167/255.0 blue:157/255.0 alpha:1.0];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(submitComment:) forControlEvents:UIControlEventTouchUpInside];
    sendButton.frame = CGRectMake(toolBar.bounds.size.width - 68.0f,
                                  6.0f,
                                  58.0f,
                                  29.0f);
    [toolBar addSubview:sendButton];
    
    
    
    [self addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing)
    {
        if (closing)
        {
            
            CGRect toolBarFrame = toolBar.frame;
            toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
            toolBar.frame = toolBarFrame;
            CGRect collectionViewFrame = collectionView.frame;
            collectionViewFrame.origin.x = 0;
            collectionViewFrame.origin.y = 0;
            collectionViewFrame.size.height = self.frame.size.height - toolBarFrame.size.height;
            collectionView.frame = collectionViewFrame;
        } else if (opening)
        {
            CGRect toolBarFrame = toolBar.frame;
            toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
            toolBar.frame = toolBarFrame;
            CGRect collectionViewFrame = collectionView.frame;
            collectionViewFrame.origin.x = 0;
            collectionViewFrame.origin.y = 0;
            collectionViewFrame.size.height = self.frame.size.height - toolBarFrame.size.height - keyboardFrameInView.size.height;
            collectionView.frame = collectionViewFrame;
            
            
        }
        

        
    } constraintBasedActionHandler:nil];
    
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor lightGrayColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [collectionView addSubview:refreshControl];
    collectionView.alwaysBounceVertical = YES;
    
    [self performSelector:@selector(reloadData)  withObject:self afterDelay:2.0];
    

    noitemslabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 30)];
    noitemslabel.text = @"No items found";
    noitemslabel.textAlignment = NSTextAlignmentCenter;
    [collectionView addSubview:noitemslabel];
    
    
    // ADD LOADER
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

-(void)loadCommentsForChannel:(int)cid
{
    cellItems = [[NSArray alloc] init];
    [self->collectionView reloadData];
    channel_id = cid;
    video_id = 0;
    [self reloadData];
}

-(void)loadCommentsForVideo:(int)vid andSection:(NSString *)s
{
    cellItems = [[NSArray alloc] init];
    [self->collectionView reloadData];
    channel_id = 0;
    video_id = vid;
    section = s;
    [self reloadData];
}


-(void)reloadData
{
    
    collectionView.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
    [refreshControl beginRefreshing];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@comments",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"video_id=%i&channel_id=%i&section=%@",video_id,channel_id, section];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [URLConnection asyncConnectionWithRequest:request completionBlock:^(NSData *data, NSURLResponse *response)
     {
         [refreshControl endRefreshing];
         jsonData = [[GSApiResponseObjectItem alloc] initWithNSData:data];
         
         if (jsonData.statusCode > 0)
         {
             // an error occurred
             //[self alertStatus:jsonData.statusMessage :@"Error" :0];
             
         } else {
             // no error
             
             int count = [[jsonData.responseData valueForKey:@"count"] intValue];
             if (count == 0)
             {
                 noitemslabel.hidden = NO;
             } else {
                 
                 // cellitems
                 cellItems = [jsonData.responseData valueForKey:@"comments"];
                 
                 // Reload table data
                 [self->collectionView reloadData];
                 noitemslabel.hidden = YES;
             }
             
             
             
         }
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         [self alertStatus:@"Could not connect." :@"Error" :0];
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




-(void)submitComment:(id)sender
{
    NSLog(@"submit comment %i - %i", video_id, channel_id);
    [self endEditing:YES];
    [textField resignFirstResponder];
    
    if ([textField.text length] == 0)
    {
        [self alertStatus:@"Please enter a comment before submitting." :@"No Message" :0];
        return;
    }
    
    [HUD show:YES];
    HUD.labelText = @"Sending...";
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@comments_add",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"video_id=%i&channel_id=%i&comment=%@&user_id=%@&section=%@",video_id,channel_id,textField.text,user_id, section];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [URLConnection asyncConnectionWithRequest:request completionBlock:^(NSData *data, NSURLResponse *response)
    {
         NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         jsonData = [[GSApiResponseObjectItem alloc] initWithNSData:data];
         
         NSLog(@"got comment %@", newStr);
         
         if (jsonData.statusCode > 0)
         {
             // an error occurred
             HUD.labelText = jsonData.statusMessage;
             [HUD show:YES];
             [HUD hide:YES afterDelay:2.0];
         } else {
             
             // no error
             [HUD hide:YES];
             [self alertStatus:@"Your comment has been saved." :@"Complete" :0];
             [self reloadData];
             textField.text = @"";
         }
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         HUD.labelText = @"Could not connect.";
         HUD.progress = 100;
         
         [HUD hide:YES afterDelay:2.0];
         
         [self alertStatus:@"Could not connect" :@"Error" :0];
         
     } uploadProgressBlock:^(float progress) {
         // when upload progresses
         
     } downloadProgressBlock:^(float progress) {
         // when download progressses
         
     }];

    
}



#pragma UITextField Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"DID BEGIN EDIT");
    [self.delegate prepareCommentForPosting];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"DID END EDIT");
    [self endEditing:YES];
    [textField resignFirstResponder];
    [self.delegate resignCommentsFromPosting];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"logged_in"]) {
        // not logged in!
        [self endEditing:YES];
        [self alertStatus:@"You must be logged in to make comments." :@"Log in" :0];
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}


#pragma UICollectionView Delegate



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [cellItems count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *identifier = @"cellComments";
    if(!nibMyCommentsCellloaded)
    {
        UINib *nib = [UINib nibWithNibName:@"CommentListCollectionViewCell" bundle: nil];
        [cv registerNib:nib forCellWithReuseIdentifier:identifier];
        nibMyCommentsCellloaded = YES;
    }
    NSDictionary *comment = [[cellItems objectAtIndex:indexPath.row] objectForKey:@"comment"];
   
    NSLog(@"%@",comment);
    
    NSString *fb_id =[comment valueForKey:@"fb_id"];
    
    int comment_approved = [[comment valueForKey:@"comment_approved"] intValue];
    
    
    CommentListCollectionViewCell *cell = (CommentListCollectionViewCell*)[cv dequeueReusableCellWithReuseIdentifier:@"cellComments" forIndexPath:indexPath];
    cell.lblHeader.text = [comment valueForKey:@"user_name"];
    cell.lblSubheader.text = [comment valueForKey:@"comment_text"];
    cell.lblSubHeaderMinimum.text = [comment valueForKey:@"comment_created"];
    
    
    if (comment_approved == 0)
    {
        cell.lblSubheader.textColor = [UIColor lightGrayColor];
        [cell.lblSubheader setFont:[UIFont systemFontOfSize:FONTSIZE14]];
    } else {
         cell.lblSubheader.textColor = [UIColor darkGrayColor];
        [cell.lblSubheader setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    }
    
    cell.imageView.image = nil;
    
    if (fb_id != nil && [fb_id length] > 0)
    {
        cell.imageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=640&height=640",fb_id]];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"empty-profile"];
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
