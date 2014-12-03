//
//  EPCalendarTableViewController.m
//  CRMCalendar
//
//  Created by Sunayna Jain on 12/3/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarTableViewController.h"

@interface EPCalendarTableViewController ()

@property CGRect frame;

@end

@implementation EPCalendarTableViewController


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithNibName:@"EPCalendarTableViewController" bundle:nil];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    return cell;
}

@end
