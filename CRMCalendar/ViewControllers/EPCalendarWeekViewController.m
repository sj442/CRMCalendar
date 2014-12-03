//
//  EPCalendarWeekViewController.m
//  CRMCalendar
//
//  Created by Sunayna Jain on 12/3/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarWeekViewController.h"
#import "EPCalendarTableViewController.h"
#import "EPCalendarCell.h"
#import "NSDate+Format.h"
#import "NSCalendar+Juncture.h"
#import "NSCalendar+Components.h"
#import "NSDate+Description.h"
#import "NSCalendar+Ranges.h"
#import "NSCalendar+DateManipulation.h"
#import "UIColor+EH.h"

@interface EPCalendarWeekViewController ()

{
    NSInteger todayDay;
    NSInteger todayMonth;
    NSInteger todayYear;
}
@property (strong, nonatomic) NSDate *today;
@property (weak, nonatomic) UIView *headerView;
@property (weak, nonatomic) UICollectionView *collectionView;

@end

@implementation EPCalendarWeekViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    EPCalendarTableViewController *tableVC = [[EPCalendarTableViewController alloc]initWithFrame:self.tableViewContainer.frame];
    ((EPCalendarTableView *)tableVC.tableView).myDelegate = self;
    [self.tableViewContainer addSubview:tableVC.view];
    [tableVC didMoveToParentViewController:self];
    tableVC.view.frame = self.tableViewContainer.bounds;
    [self addChildViewController:tableVC];
    
    [self addHeaderView];
    [self addCollectionView];
}

- (void)addHeaderView
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerToolbar.frame), self.view.frame.size.width, 30)];
    for (int i=0; i<7; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(i*CGRectGetWidth(headerView.frame)/7, 0, CGRectGetWidth(headerView.frame)/7, 30)];
        label.text = [self dayLabelForWeekday:i];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [headerView addSubview:label];
    }
    
    self.headerView = headerView;
    self.headerView.backgroundColor =[UIColor primaryColor];
    [self.view addSubview:headerView];
}

- (NSString *)dayLabelForWeekday:(NSInteger)weekday
{
    if (weekday ==0) {
        return @"S";
    } else if (weekday ==1) {
        return @"M";
    } else if (weekday ==2) {
        return @"T";
    } else if (weekday ==3) {
        return @"W";
    } else if (weekday ==4) {
        return @"T";
    } else if (weekday ==5) {
        return @"F";
    }
    return @"S";
}

- (void)addCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 0;
    [flowLayout setItemSize:CGSizeMake(CGRectGetWidth(self.view.frame)/7, 50)];
    flowLayout.minimumInteritemSpacing = 0;
    EPCalendarCollectionView *cv = [[EPCalendarCollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), self.view.frame.size.width, 300) collectionViewLayout:flowLayout];
    cv.myDelegate = self;
    cv.backgroundColor = [UIColor yellowColor];
    cv.scrollEnabled = NO;
    self.collectionView = cv;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"EPCalendarCell" bundle:nil] forCellWithReuseIdentifier:@"CalendarCell"];
    [self.view insertSubview:cv belowSubview:self.tableViewContainer];
}

#pragma mark - UICollectionView DataSource & Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 42;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EPCalendarCell *cell = (EPCalendarCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"CalendarCell" forIndexPath:indexPath];
    [cell configureCell];
    if (indexPath.section==0) {
        cell.dayLabel.text = [self dayLabelForWeekday:indexPath.item+1];
        [self configureForCurrentWeekModeCell:cell ForIndex:indexPath.item+1];
    } else if (indexPath.section==1) {
        cell.dayLabel.text = [self dayLabelForWeekday:indexPath.item+1];
        [self configureForNextWeekModeCell:cell ForIndex:indexPath.item+1];
    }
    return cell;
}

- (void)configureForNextWeekModeCell:(EPCalendarCell*)cell ForIndex:(NSInteger)index
{
    NSInteger selfDateDay = [self.calendar daysInDate:self.date];
    NSInteger selfDateMonth = [self.calendar monthsInDate:self.date];
    NSInteger selfDateYear = [self.calendar yearsInDate:self.date];
    NSInteger weekOfMonth = [self.calendar weekOfMonthInDate:self.date];
    NSInteger weeksInMonth = [self.calendar weeksPerMonthUsingReferenceDate:self.date];
    NSInteger day = 0;
    NSInteger month = selfDateMonth;
    NSInteger year = selfDateYear;
    NSInteger week = weekOfMonth;
    NSDate *firstDayOfNextMonth;
    NSInteger weeksInNextMonth =weeksInMonth;
    
    if (weekOfMonth == weeksInMonth) {
        if (month == 12) {
            year = year+1;
        }
        month = month+1;
        firstDayOfNextMonth = [NSDate createDateFromComponentsYear:year andMonth:month andDay:1 ForCalendar:self.calendar];
        NSInteger firstDateWeekday = [self.calendar weekdayInDate:firstDayOfNextMonth];
        weeksInNextMonth = [self.calendar weeksPerMonthUsingReferenceDate:firstDayOfNextMonth];
        NSInteger weeksInNextMonth = [self.calendar weeksPerMonthUsingReferenceDate:firstDayOfNextMonth];
        if (firstDateWeekday<7) {
            week = weeksInNextMonth+1;
            firstDayOfNextMonth = [NSDate createDateFromComponentsYear:year andMonth:month andDay:1+firstDateWeekday-index ForCalendar:self.calendar];
        } else {
            week = weeksInNextMonth;
        }
    } else {
        week = weekOfMonth+1;
        firstDayOfNextMonth = [NSDate createDateFromComponentsYear:year andMonth:month andDay:selfDateDay+7 ForCalendar:self.calendar];
    }
    
    if (week == 1) {
        day = [self populateCalendarCell:cell forFirstWeekForIndex:index referenceDate:firstDayOfNextMonth];
    } else if (week == weeksInNextMonth) {
        day = [self populateCalendarCell:cell ForLastWeekForIndex:index referenceDate:firstDayOfNextMonth];
    } else {
        day = [self populateCalendarCell:cell forAllOtherWeeksForIndex:index referenceDate:firstDayOfNextMonth];
    }
    //to display dots on dates that have events
 //   NSDate *indexDate = [NSDate createDateFromComponentsYear:year andMonth:month andDay:day ForCalendar:self.calendar];
  //  NSArray *events = [self fetchCalendarEventsForDate:indexDate];
//    if ([events count]>0) {
//        NSDictionary *tempDict = [NSDictionary dictionaryWithObject:events forKey:indexDate];
//        [self.eventsDict addEntriesFromDictionary:tempDict];
//    }
//    if (cell.indexDate && [events count]>0) {
//        cell.dotImageView.hidden = NO;
//    }
//    else {
//        cell.dotImageView.hidden = YES;
//    }
}


- (void)configureForCurrentWeekModeCell:(EPCalendarCell*)cell ForIndex:(NSInteger)index
{
    NSInteger selfDateDay = [self.calendar daysInDate:self.date];
    NSInteger selfDateMonth = [self.calendar monthsInDate:self.date];
    NSInteger selfDateYear = [self.calendar yearsInDate:self.date];
    NSInteger weeksInMonth = [self.calendar weeksPerMonthUsingReferenceDate:self.date];
    NSInteger weekOfMonth = [self.calendar weekOfMonthInDate:self.date];
    NSInteger day = 0;
    
    //to highlight date when cell.indexDate == self.date or when cell.indexDate==today's date
    
    if ((day==todayDay && day!=selfDateDay) && (todayMonth==selfDateMonth) && (todayYear==selfDateYear)) {
        cell.dateLabel.textColor = [UIColor primaryColor];
    } else if (day==selfDateDay) {
        cell.dateLabel.backgroundColor = [UIColor primaryColor];
        cell.dateLabel.textColor = [UIColor whiteColor];
        cell.dateLabel.layer.cornerRadius = CGRectGetWidth(cell.dateLabel.frame)/2;
        cell.dateLabel.layer.masksToBounds = YES;
    } else {
        cell.dateLabel.backgroundColor = [UIColor clearColor];
        cell.dateLabel.textColor = [UIColor blackColor];
    }
    //to display dots on dates that have events
  //  NSDate *indexDate = [NSDate createDateFromComponentsYear:selfDateYear andMonth:selfDateMonth andDay:day ForCalendar:self.calendar];
  //  NSArray *events = [self fetchCalendarEventsForDate:indexDate];
//    if ([events count]>0) {
//        NSDictionary *tempDict = [NSDictionary dictionaryWithObject:events forKey:indexDate];
//        [self.eventsDict addEntriesFromDictionary:tempDict];
//    }
//    if (cell.indexDate && [events count]>0) {
//        cell.dotImageView.hidden = NO;
//    }
//    else {
//        cell.dotImageView.hidden = YES;
//    }
    if (weekOfMonth==weeksInMonth) { //last week
        day= [self populateCalendarCell:cell ForLastWeekForIndex:index referenceDate:self.date];
    } else if (weekOfMonth==1) {//first week
        day =[self populateCalendarCell:cell forFirstWeekForIndex:index referenceDate:self.date];
    } else { //all other weeks
        day =[self populateCalendarCell:cell forAllOtherWeeksForIndex:index referenceDate:self.date];
    }
}

- (NSInteger)populateCalendarCell:(EPCalendarCell*)cell ForLastWeekForIndex:(NSInteger)index referenceDate:(NSDate *)date
{
    NSInteger day;
    NSDate *lastDate = [self.calendar lastDayOfTheMonthUsingReferenceDate:date];
    NSInteger lastDay = [self.calendar weekdayInDate:lastDate];
    NSDate *firstDayOfLastWeek = [self.calendar firstDayOfTheWeekUsingReferenceDate:lastDate];
    NSInteger daysInWeekFirstDate = [self.calendar daysInDate:firstDayOfLastWeek];
    if (index<=lastDay){
        day = daysInWeekFirstDate+index-1;
        cell.dateLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        NSInteger month = [self.calendar monthsInDate:date];
        NSInteger year = [self.calendar yearsInDate:date];
        NSDate *indexDate = [NSDate createDateFromComponentsYear:year andMonth:month andDay:day ForCalendar:self.calendar];
        cell.indexDate = indexDate;
    }
    else {
        NSInteger month = [self.calendar monthsInDate:lastDate];
        NSInteger year = [self.calendar yearsInDate:lastDate];
        NSDate *firstDayOfNextMonth = [NSDate createDateFromComponentsYear:year andMonth:month+1 andDay:1 ForCalendar:self.calendar];
        NSDate *lastDayOfFirstWeek = [self.calendar lastDayOfTheWeekUsingReferenceDate:firstDayOfNextMonth];
        NSInteger daysInFirstDayOfLastWeek = [self.calendar weekdayInDate:lastDayOfFirstWeek];
        NSDate *date = [NSDate createDateFromComponentsYear:year andMonth:month andDay:1+daysInFirstDayOfLastWeek-index ForCalendar:self.calendar];
        day= [self.calendar daysInDate:date];
        cell.dateLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        NSDate *indexDate = [NSDate createDateFromComponentsYear:year andMonth:month andDay:day ForCalendar:self.calendar];
        cell.indexDate = indexDate;
        
    }
    return day;
}

- (NSInteger)populateCalendarCell:(EPCalendarCell*)cell forFirstWeekForIndex:(NSInteger)index referenceDate:(NSDate *)date
{
    NSInteger day;
    NSDate *firstDate = [self.calendar firstDayOfTheMonthUsingReferenceDate:date];
    NSInteger firstDateWeekday = [self.calendar weekdayInDate:firstDate];
    
    if (index>=firstDateWeekday){
        day = 1+index-firstDateWeekday;
        cell.dateLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        NSInteger month = [self.calendar monthsInDate:date];
        NSInteger year = [self.calendar yearsInDate:date];
        NSDate *indexDate = [NSDate createDateFromComponentsYear:year andMonth:month andDay:day ForCalendar:self.calendar];
        cell.indexDate = indexDate;
    }
    else {
        NSInteger month = [self.calendar monthsInDate:firstDate];
        NSInteger year = [self.calendar yearsInDate:firstDate];
        NSDate *firstDayOfPreviousMonth = [NSDate createDateFromComponentsYear:year andMonth:month-1 andDay:1 ForCalendar:self.calendar];
        NSDate *lastDayOfPreviousMonth = [self.calendar lastDayOfTheMonthUsingReferenceDate:firstDayOfPreviousMonth];
        NSDate *firstDayOfLastWeek = [self.calendar firstDayOfTheWeekUsingReferenceDate:lastDayOfPreviousMonth];
        NSInteger daysInFirstDayOfLastWeek = [self.calendar daysInDate:firstDayOfLastWeek];
        NSDate *date = [NSDate createDateFromComponentsYear:year andMonth:month andDay:daysInFirstDayOfLastWeek+index-1 ForCalendar:self.calendar];
        day= [self.calendar daysInDate:date];
        cell.dateLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        NSDate *indexDate = [NSDate createDateFromComponentsYear:year andMonth:month andDay:day ForCalendar:self.calendar];
        cell.indexDate = indexDate;
    }
    return day;
}

- (NSInteger)populateCalendarCell:(EPCalendarCell*)cell forAllOtherWeeksForIndex:(NSInteger)index referenceDate:(NSDate *)date
{
    NSDate *firstDate = [self.calendar firstDayOfTheWeekUsingReferenceDate:date];
    NSInteger daysInFirstDate = [self.calendar daysInDate:firstDate];
    NSInteger day = daysInFirstDate+index-1;
    cell.dateLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
    NSInteger month = [self.calendar monthsInDate:date];
    NSInteger year = [self.calendar yearsInDate:date];
    NSDate *indexDate = [NSDate createDateFromComponentsYear:year andMonth:month andDay:day ForCalendar:self.calendar];
    cell.indexDate = indexDate;
    return day;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICalendarCollectionViewDelegate

- (void)upSwipeHappened
{
    NSLog(@"up swipe happened");
}

- (void)downSwipeHappened
{
    NSLog(@"down swipe happened");
}

- (void)rightSwipeHappened
{
    NSLog(@"right swipe happened");
    //show full collection view
    [self showFullCollectionView];
}

- (void)leftSwipeHappended
{
    NSLog(@"left swipe happened");
    [self hideCollectionView];
}

#pragma mark - CalendarTableView Delegate

- (void)tableViewLeftSwipeHappened
{
    NSLog(@"tv left Swipe Happened");
}

- (void)tableViewRightSwipeHappened
{
    NSLog(@"tv right Swipe Happened");
}

- (void)tableViewUpSwipeHappened
{
    NSLog(@"tv up Swipe Happened");
    [self hideCollectionView];
}

- (void)tableViewDownSwipeHappened
{
    NSLog(@"tv down Swipe Happened");
    //show full collection view
    [self showFullCollectionView];
}

- (void)showFullCollectionView
{
    [UIView animateWithDuration:0.1 animations:^{
        CGRect frame = self.tableViewContainer.frame;
        frame.origin.y = 500;
        self.tableViewContainer.frame = frame;
    } completion:^(BOOL finished) {
        NSLog(@"animation done");
    }];
}

- (void)hideCollectionView
{
    [UIView animateWithDuration:0.1 animations:^{
        CGRect frame = self.tableViewContainer.frame;
        frame.origin.y = 200;
        self.tableViewContainer.frame = frame;
    } completion:^(BOOL finished) {
        NSLog(@"animation done");
    }];
}

@end
