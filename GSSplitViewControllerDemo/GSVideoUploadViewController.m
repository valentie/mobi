//
//  GSFavouritesViewController.m
//  GSSplitViewControllerDemo
//
//  Created by Renee van der Kooi on 8/24/2558 BE.
//  Copyright (c) 2558 Mindzone Company Limited. All rights reserved.
//

#import "GSVideoUploadViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"

@interface GSVideoUploadViewController ()

@end

@implementation GSVideoUploadViewController

#define PLACEHOLDER_TEXT NSLocalizedString(@"Enter a description", @"Enter a description")
#define PLACEHOLDER_TEXT_CAT NSLocalizedString(@"Select Category...",@"Select Category...")

- (void)viewDidLoad {
    [super viewDidLoad];
    
    hasLoaded = NO;
    
    _txtDescription.text = PLACEHOLDER_TEXT;
    _txtDescription.textColor = [UIColor lightGrayColor];
    
    
    // ADD LOADER
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    
    appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
  
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectVideo)];
    [_imageView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tapLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPicker)];
    [_txtCategory addGestureRecognizer:tapLabel];

    _picker.hidden = YES;
    _txtCategory.text = PLACEHOLDER_TEXT_CAT;
    _picker.backgroundColor = [UIColor whiteColor];
    
    self.flUploadEngine = [[fileUploadEngine alloc] initWithHostName:API_HOST customHeaderFields:nil];
    
}

-(IBAction)btnBackPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (hasLoaded == NO)
        [self selectVideo];
    
    [super viewDidAppear:animated];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)openPicker
{
    [self.view endEditing:YES];
    _picker.hidden=NO;
}

- (void)selectVideo
{
    hasLoaded = YES;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
    if (![sourceTypes containsObject:(NSString *)kUTTypeMovie ])
    {
        [self alertStatus:@"Can't select a video." :@"No Camera Available" :0];
        return;
    }
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}
#pragma mark - Image Picker

- (NSData*)loadImageForURL:(NSURL *)vidURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:vidURL options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    
    NSLog(@"err==%@, imageRef==%@", err, imgRef);
    
    UIImage *img = [[UIImage alloc] initWithCGImage:imgRef];
    
    
    _imageView.image = img;
    
    return UIImagePNGRepresentation(img);
}


- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}

- (void)imagePickerController: (UIImagePickerController *)picker2 didFinishPickingMediaWithInfo: (NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:@"public.movie"])
    {
        videoUrl= (NSURL*)[info objectForKey:@"UIImagePickerControllerMediaURL"];
        
        if( [[[videoUrl absoluteString] pathExtension] caseInsensitiveCompare:@"mp4"] == NSOrderedSame || [[[videoUrl absoluteString] pathExtension] caseInsensitiveCompare:@"mov"] == NSOrderedSame) {

            
            [self loadImageForURL:videoUrl];
            
        } else {
            
            [self alertStatus:NSLocalizedString(@"Only MP4 is supported.", @"Only MP4 is supported.") :NSLocalizedString(@"Incorrect Format", @"Incorrect Format") :0];
            
        }
    }
}


-(IBAction)btnAddTagPressed:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TAG", @"TAG") message:NSLocalizedString(@"Enter a tag:", @"Enter a tag:") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:NSLocalizedString(@"Cancel", @"Cancel"),nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag=10;
    [alert show];
}

-(IBAction)btnUploadPressed:(id)sender
{
   if ([_txtTitle.text length] == 0)
   {
       [self alertStatus:NSLocalizedString(@"Please enter a title", @"Please enter a title") :NSLocalizedString(@"Incomplete", @"Incomplete")  :0];
       return;
   }
       
    if ([_txtTags.text length] == 0)
    {
        [self alertStatus:NSLocalizedString(@"Please enter a tag", @"Please enter a tag"):NSLocalizedString(@"Incomplete", @"Incomplete") :0];
        return;
    }
    if ([_txtCategory.text length] == 0)
    {
        [self alertStatus:NSLocalizedString(@"Please enter a category", @"Please enter a category") :NSLocalizedString(@"Incomplete", @"Incomplete") :0];
        return;
    }
    

    if ([_txtCategory.text isEqualToString:PLACEHOLDER_TEXT_CAT])
    {
        [self alertStatus:NSLocalizedString(@"Please enter a category", @"Please enter a category") :NSLocalizedString(@"Incomplete", @"Incomplete") :0];
        return;
    }
    if ([_txtDescription.text length] == 0)
    {
        [self alertStatus:NSLocalizedString(@"Please enter a description", @"Please enter a description") :NSLocalizedString(@"Incomplete", @"Incomplete") :0];
        return;
    }
    
    if ([_txtDescription.text isEqualToString:PLACEHOLDER_TEXT])
    {
        [self alertStatus:NSLocalizedString(@"Please enter a description", @"Please enter a description")  :NSLocalizedString(@"Incomplete", @"Incomplete") :0];
        return;
    }
    
    [self performUpload];
    
}



- (void)performUpload
{
    NSData *imageData = [self loadImageForURL:videoUrl];
    NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] init];
    [postParams setObject:user_id forKey:@"user_id"];
    [postParams setObject:_txtTitle.text forKey:@"title"];
    [postParams setObject:_txtDescription.text forKey:@"description"];
    [postParams setObject:_txtTags.text forKey:@"tags"];
    [postParams setObject:_txtCategory.text forKey:@"category"];
    
    
    self.flOperation = [self.flUploadEngine postDataToServer:postParams path:[NSString stringWithFormat:@"%@videos_upload",API_END_POINT]];
    
    [self.flOperation addData:imageData forKey:@"userfile_screenshot" mimeType:@"image/jpg" fileName:@"upload.png"];
    [self.flOperation addData:videoData forKey:@"userfile_video" mimeType:@"video/mp4" fileName:@"video.mp4"];
    
    
    HUD.labelText = @"Uploading...";
    [HUD show:YES];
    [self.flOperation addCompletionHandler:^(MKNetworkOperation* operation) {
        NSLog(@"%@",[operation responseString] );
        GSApiResponseObjectItem *uploadData = [[GSApiResponseObjectItem alloc] initWithNSData:[[operation responseString] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (uploadData.statusCode > 0)
        {
            // an error occurred
            HUD.labelText = uploadData.statusMessage;
            [HUD hide:YES afterDelay:2.0];
            
        } else {
            // no error
            HUD.progress = 100;
            [HUD hide:YES afterDelay:0];
            [self alertStatus:NSLocalizedString(@"Your video has been saved and waiting approval.", @"Your video has been saved and waiting approval.") :NSLocalizedString(@"Success", @"Success") :99];
            
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

#pragma UIAlertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99)
    {
        [self btnBackPressed:nil];
    }
    if (alertView.tag == 10)
    {
        NSString *tag = [[alertView textFieldAtIndex:0] text];
        if (tag != nil && ![tag isEqualToString:@""])
        {
            self.txtTags.text = [NSString stringWithFormat:@"%@ #%@",self.txtTags.text, tag ];
        }
       
    }
   
}



#pragma UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height+KEYBOARDHEIGHT)];
    [self.scrollView setContentOffset:CGPointMake(0, self.blockView.frame.origin.y-50) animated:YES];
    
    
    if ([textView.text isEqualToString:PLACEHOLDER_TEXT]) {
        textView.text = @"";
        textView.textColor = [UIColor darkGrayColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
     [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height)];
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = PLACEHOLDER_TEXT;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height+KEYBOARDHEIGHT)];
    [self.scrollView setContentOffset:CGPointMake(0, self.blockView.frame.origin.y-50) animated:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height)];
}


#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if (appDelegate.categories == NULL) return 0;
    
    return [appDelegate.categories count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView  titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    GSMasterCellObjectItem *obj = [appDelegate.categories objectAtIndex:row];

    return [obj.data objectForKey:@"title"];
} 

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    GSMasterCellObjectItem *obj = [appDelegate.categories objectAtIndex:row];
    _txtCategory.text = [obj.data objectForKey:@"title"];
    _picker.hidden = YES;
}
@end
