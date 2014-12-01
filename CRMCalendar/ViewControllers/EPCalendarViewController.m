//
//  CalendarVC1.m
//  CRMStar
//
//  Created by Sunayna Jain on 4/25/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.

#import "EPCalendarViewController.h"
#import "EPCreateEventTableViewController.h"
#import "EventStore.h"

@interface EPCalendarViewController ()

@property (weak, nonatomic) UIView *headerView;
@property (weak, nonatomic) UIImageView *noAccessImageView;

@end

@implementation EPCalendarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

#pragma mark-view life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.date = [NSDate date];
    self.eventStore= [[EventStore sharedInstance] eventStore];
    self.displayMode = CKCalendarViewModeWeek;
    self.calendar = [NSCalendar currentCalendar];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 44)];
    [self.view addSubview:view];
    view.alpha = 0.95;
    self.headerView = view;
    self.headerView.backgroundColor = [UIColor primaryColor];
    [self addPlusButton];
    [self setupToolBar];
    [self setupHeaderView];
    [self setupCalendarView];
    [self setNavigationBarTitle];

    self.navigationController.navigationBar.tintColor = [UIColor primaryColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor primaryColor]}];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkCalendarPermissions];
    [self.calendarView addEventStoreChangeNotification];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self.calendarView];
}

- (void)checkCalendarPermissions
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.eventStore reset];
                [self setNavigationBarTitle];
                [self addPlusButton];
                [self removeNoAccessImageView];
                [self.calendarView calendarViewReload];
            });
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self loadImage];
                [self removePlusButton];
                
            });
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"did receive memory warning");
}

#pragma mark- view setup methods

- (void)addPlusButton
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithImage:[UIImage imageNamed:@"B22_taskbar__add-icon-outline.png"]
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(addEventPressed:)];
}

- (void)setNavigationBarTitle
{
    self.title = [self.date monthAndYearOnCalendar:self.calendar];
}

- (void)removePlusButton
{
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)removeNoAccessImageView
{
    if (self.noAccessImageView) {
        [self.noAccessImageView removeFromSuperview];
    }
}

- (void)loadImage
{
    self.navigationItem.title = @"";
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.backgroundColor= [UIColor secondaryColor];
    CGRect imageViewFrame = imageView.frame;
    imageViewFrame.origin.x = 0;
    imageViewFrame.origin.y = 64;
    imageViewFrame.size.width =  CGRectGetWidth(self.view.frame);
    imageViewFrame.size.height = CGRectGetHeight(self.view.frame)-64;
    imageView.frame = imageViewFrame;
    self.noAccessImageView = imageView;
    if (CGRectGetHeight(self.view.frame)<568) { //3.5 inch screen
        imageView.image = [UIImage imageNamed:@"calendaraccess"];
        imageView.contentMode = UIViewContentModeScaleToFill;
    } else { //4 inch screen
        imageView.image = [UIImage imageNamed:@"calendaraccess"];
    }
    [self.view addSubview:imageView];
}

- (void)setupCalendarView
{
    EPCalendarView *calendarView = [[EPCalendarView alloc] initWithFrame:CGRectMake(0, 64+44, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-64-44-44)];
    [self.view addSubview:calendarView];
    calendarView.calendarViewFrame = self.view.frame;
    self.calendarView = calendarView;
    self.calendarView.swipeDelegate = self;
    self.calendarView.calendarViewDelegate = self;
    self.calendarView.displayMode = self.displayMode;
}

- (void)setupToolBar
{
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-44, CGRectGetWidth(self.view.frame), 44)];
    toolBar.tintColor = [UIColor primaryColor];
    toolBar.tintColor = [UIColor primaryColor];
    [self.view addSubview:toolBar];
    self.toolBar = toolBar;
    UIBarButtonItem *monthButton = [[UIBarButtonItem alloc] initWithTitle:@"Month"
                                                                    style:UIBarButtonItemStylePlain target:self
                                                                   action:@selector(monthPressed:)];
    UIBarButtonItem *weekButton = [[UIBarButtonItem alloc] initWithTitle:@"Week"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(weekPressed:)];
    UIBarButtonItem *dayButton = [[UIBarButtonItem alloc] initWithTitle:@"Day"
                                                                  style:UIBarButtonItemStylePlain target:self
                                                                 action:@selector(dayPressed:)];
    UIBarButtonItem *spacer = [UIBarButtonItem flexSpacerItem];
    
    self.toolBar.items = @[monthButton, spacer, weekButton, spacer, dayButton];
}

- (void)setupHeaderView
{
    CGFloat labelWidth = CGRectGetWidth(self.view.frame)/7;
    NSArray *labels = @[@"S", @"M", @"T", @"W", @"T", @"F", @"S"];
    for (int i=0; i<7; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*labelWidth, 0, labelWidth, self.headerView.frame.size.height)];
        label.text = labels[i];
        label.font = [UIFont boldSystemFontOfSize:19];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.headerView addSubview:label];
        
    }
}

- (void)addEventPressed:(id)sender
{    
    EPCreateEventTableViewController *createEventVC;
    if (self.displayMode == CKCalendarViewModeMonth) {
        createEventVC = [[EPCreateEventTableViewController alloc] init];
    } else {
        createEventVC = [[EPCreateEventTableViewController alloc] initWithDate:self.date];
    }
    createEventVC.editMode = YES;
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:createEventVC];
    createEventVC.title = @"New Event";
    [self presentViewController:navC animated:YES completion:nil];
}

- (void)headerViewForDayView
{
    for (UIView *view in self.headerView.subviews) {
        [view removeFromSuperview];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.headerView.frame), CGRectGetHeight(self.headerView.frame))];
    label.text = [NSDate getOrdinalSuffix:self.date forCalendar:self.calendar];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:22];
    
    [self.headerView addSubview:label];
}

- (void)headerViewForMonthView
{
    for (UIView *view in self.headerView.subviews) {
        [view removeFromSuperview];
    }
    [self setupHeaderView];
}

- (void)monthPressed:(id)sender
{
    self.displayMode = CKCalendarViewModeMonth;
    self.calendarView.displayMode = CKCalendarViewModeMonth;
    self.calendarView.collectionView.monthMode = YES;
    [self.calendarView layoutSubviewForMonth];
    
    [self changeHeaderView];
}

- (void)weekPressed:(id)sender
{
    self.displayMode = CKCalendarViewModeWeek;
    
    self.calendarView.displayMode = CKCalendarViewModeWeek;
    self.calendarView.collectionView.monthMode = NO;
    [self.calendarView layoutSubviewsForWeek];
    [self changeHeaderView];
}

- (void)dayPressed:(id)sender
{
    self.displayMode = CKCalendarViewModeDay;
    self.calendarView.displayMode = CKCalendarViewModeDay;
    NSDate *today = [NSDate date];
    NSInteger day = [self.calendar daysInDate:today];
    NSInteger month = [self.calendar monthsInDate:today];
    NSInteger year = [self.calendar yearsInDate:today];
    self.date = [NSDate createDateFromComponentsYear:year andMonth:month andDay:day ForCalendar:self.calendar];
    self.calendarView.date = self.date;
    self.calendarView.indexDate = self.date;
    
    [self setNavigationBarTitle];
    [self.calendarView layoutSubviewForDay];
    
    [self changeHeaderView];
}

#pragma mark-CalendarViewSwipeDelegate

- (void)newDateToPassBack:(NSDate*)date
{
    self.date = date;
    [self setNavigationBarTitle];
}

- (void)changeHeaderView
{
    if (self.displayMode==CKCalendarViewModeDay) {
        [self headerViewForDayView];
    } else {
        [self headerViewForMonthView];
    }
}

- (void)displayModeChangedTo:(CKCalendarDisplayMode)mode
{
    self.displayMode = mode;
}

#pragma mark-CKCalendarViewDelegate methods

- (void)calendarView:(EPCalendarView *)CalendarView didSelectEvent:(EKEvent *)event
{
    EPCreateEventTableViewController *newEventTVC = nil;
        newEventTVC = [[EPCreateEventTableViewController alloc] initWithEvent:event
                                                                    eventName:event.title
                                                                     location:event.location
                                                                        notes:event.notes
                                                                    startDate:event.startDate
                                                                      endDate:event.endDate
                                                                      contact:nil];
    newEventTVC.eventSelected = 1;
    newEventTVC.title = @"Event";
    [self.navigationController pushViewController:newEventTVC animated:YES];
}

@end
