//
//  GSFilterTableViewController.h
//  MOBITV
//
//  Created by Renee van der Kooi on 10/14/2558 BE.
//  Copyright © 2558 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSFilterView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *tableView;

@end
