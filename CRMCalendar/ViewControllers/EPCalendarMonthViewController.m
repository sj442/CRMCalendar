//
//  EPCalendarMonthViewController.m
//  CRMCalendar
//
//  Created by Sunayna Jain on 12/2/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarMonthViewController.h"
#import "EPCalendarCell.h"
#import "NSDate+Format.h"
#import "NSCalendar+Juncture.h"
#import "NSCalendar+Components.h"
#import "NSDate+Description.h"
#import <QuartzCore/QuartzCore.h>
#import "NSCalendar+Ranges.h"
#import "NSCalendar+DateManipulation.h"
#import "UIColor+EH.h"
#import "EventStore.h"

@interface EPCalendarMonthViewController ()
{
NSInteger todayDay;
NSInteger todayMonth;
NSInteger todayYear;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSDate *today;

@end

@implementation EPCalendarMonthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *nib = [UINib nibWithNibName:@"EPCalendarCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"CalendarCell"];
    self.collectionView.backgroundColor = [UIColor yellowColor];
    self.collectionView.contentSize = CGSizeMake(320*3, 100);
    [self.collectionView setContentInset:UIEdgeInsetsMake(0,320, 0, 320)];
    self.calendar = [NSCalendar currentCalendar];
    self.date = [NSDate createDateFromComponentsYear:2014 andMonth:6 andDay:6 ForCalendar:self.calendar];
    self.eventsDict = [[NSMutableDictionary alloc] init];
    self.today = [NSDate date];
    todayDay = [self.calendar daysInDate:self.today];
    todayMonth =[self.calendar monthsInDate:self.today];
    todayYear = [self.calendar yearsInDate:self.today];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - UICollectionView DataSource and Delegate methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 21;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EPCalendarCell *cell = (EPCalendarCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"CalendarCell" forIndexPath:indexPath];
    NSInteger index = indexPath.section*7 +indexPath.row +1;
    [cell configureCell];
    if (index<=7) {
        cell.dayLabel.text = [self dayLabelForWeekday:index];
        [self configureForPreviousWeekModeCell:cell ForIndex:index];
    } else if (index>=8 && index<=14) {
        cell.dayLabel.text = [self dayLabelForWeekday:index-7];
        [self configureForCurrentWeekModeCell:cell ForIndex:index];
    } else {
        cell.dayLabel.text = [self dayLabelForWeekday:index-14];
        [self configureForNextWeekModeCell:cell ForIndex:index];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select item");
}

- (CGSize)cellSize
{
    if (self.view.frame.size.height>480) {
        return CGSizeMake(CGRectGetWidth(self.view.bounds)/8,(CGRectGetHeight(self.view.bounds)-64)/7+5);
    } else {
        return CGSizeMake(CGRectGetWidth(self.view.bounds)/8,(CGRectGetHeight(self.view.bounds)-64)/7);
    }
}

- (NSString *)dayLabelForWeekday:(NSInteger)weekday
{
    if (weekday ==1) {
        return @"S";
    } else if (weekday ==2) {
        return @"M";
    } else if (weekday ==3) {
        return @"T";
    } else if (weekday ==4) {
        return @"W";
    } else if (weekday ==5) {
        return @"T";
    } else if (weekday ==6) {
        return @"F";
    }
        return @"S";
}

- (NSArray*)fetchCalendarEventsForDate:(NSDate*)indexDate
{
    //get EKEvents
    NSDate *startDate = [NSDate calendarStartDateFromDate:indexDate ForCalendar:self.calendar]; //starting from 12:01 am
    NSDate *endDate = [NSDate calendarEndDateFromDate:indexDate ForCalendar:self.calendar]; // ending at 11:59 pm
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
    return events;
}

- (void)configureForPreviousWeekModeCell:(EPCalendarCell*)cell ForIndex:(NSInteger)index
{
    NSInteger selfDateDay = [self.calendar daysInDate:self.date];
    NSInteger selfDateMonth = [self.calendar monthsInDate:self.date];
    NSInteger selfDateYear = [self.calendar yearsInDate:self.date];
    NSInteger weekOfMonth = [self.calendar weekOfMonthInDate:self.date];
    NSInteger day = 0;
    NSInteger month = selfDateMonth;
    NSInteger year = selfDateYear;
    NSInteger week = weekOfMonth;
    NSDate *firstDayOfPreviousMonth;
    NSInteger weeksInPreviousMonth =0;
    
    if (weekOfMonth ==1) {
        if (month == 1) {
            year = year-1;
        }
        month = month-1;
        firstDayOfPreviousMonth = [NSDate createDateFromComponentsYear:year andMonth:month andDay:1 ForCalendar:self.calendar];
        weeksInPreviousMonth = [self.calendar weeksPerMonthUsingReferenceDate:firstDayOfPreviousMonth];
        NSDate *lastDayOfPreviousMonth = [self.calendar lastDayOfTheMonthUsingReferenceDate:firstDayOfPreviousMonth];
        NSInteger lastDate = [self.calendar daysInDate:lastDayOfPreviousMonth];
        NSInteger lastDateWeekday = [self.calendar weekdayInDate:lastDayOfPreviousMonth];
        NSInteger weeksInPreviousMonth = [self.calendar weeksPerMonthUsingReferenceDate:firstDayOfPreviousMonth];
        if (lastDateWeekday<7) {
            week = weeksInPreviousMonth-1;
            firstDayOfPreviousMonth = [NSDate createDateFromComponentsYear:year andMonth:month andDay:lastDate-lastDateWeekday-6 ForCalendar:self.calendar];
        } else {
            week = weeksInPreviousMonth;
        }
    } else {
        week = weekOfMonth-1;
        firstDayOfPreviousMonth = [NSDate createDateFromComponentsYear:year andMonth:month andDay:selfDateDay-7 ForCalendar:self.calendar];
    }
    
    if (week == 1) {
        day = [self populateCalendarCell:cell forFirstWeekForIndex:index referenceDate:firstDayOfPreviousMonth];
    } else if (week == weeksInPreviousMonth) {
        day = [self populateCalendarCell:cell ForLastWeekForIndex:index referenceDate:firstDayOfPreviousMonth];
    } else {
        day = [self populateCalendarCell:cell forAllOtherWeeksForIndex:index referenceDate:firstDayOfPreviousMonth];
    }
    //to display dots on dates that have events
    NSDate *indexDate = [NSDate createDateFromComponentsYear:year andMonth:month andDay:day ForCalendar:self.calendar];
    NSArray *events = [self fetchCalendarEventsForDate:indexDate];
    if ([events count]>0) {
        NSDictionary *tempDict = [NSDictionary dictionaryWithObject:events forKey:indexDate];
        [self.eventsDict addEntriesFromDictionary:tempDict];
    }
    if (cell.indexDate && [events count]>0) {
        cell.dotImageView.hidden = NO;
    }
    else {
        cell.dotImageView.hidden = YES;
    }
}

- (void)configureForNextWeekModeCell:(EPCalendarCell*)cell ForIndex:(NSInteger)index
{
    index = index-14;
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
    NSDate *indexDate = [NSDate createDateFromComponentsYear:year andMonth:month andDay:day ForCalendar:self.calendar];
    NSArray *events = [self fetchCalendarEventsForDate:indexDate];
    if ([events count]>0) {
        NSDictionary *tempDict = [NSDictionary dictionaryWithObject:events forKey:indexDate];
        [self.eventsDict addEntriesFromDictionary:tempDict];
    }
    if (cell.indexDate && [events count]>0) {
        cell.dotImageView.hidden = NO;
    }
    else {
        cell.dotImageView.hidden = YES;
    }
}


- (void)configureForCurrentWeekModeCell:(EPCalendarCell*)cell ForIndex:(NSInteger)index
{
    index = index-7;
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
    NSDate *indexDate = [NSDate createDateFromComponentsYear:selfDateYear andMonth:selfDateMonth andDay:day ForCalendar:self.calendar];
    NSArray *events = [self fetchCalendarEventsForDate:indexDate];
    if ([events count]>0) {
        NSDictionary *tempDict = [NSDictionary dictionaryWithObject:events forKey:indexDate];
        [self.eventsDict addEntriesFromDictionary:tempDict];
    }
    if (cell.indexDate && [events count]>0) {
        cell.dotImageView.hidden = NO;
    }
    else {
        cell.dotImageView.hidden = YES;
    }
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

#pragma mark-EventStore methods

- (void)setupEventStore
{
    self.eventStore =[[EventStore sharedInstance] eventStore];
    //For observing external changes to Calendar Database
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventStoreChanged:)
                                                 name:EKEventStoreChangedNotification
                                               object:self.eventStore];
    
}

- (void)eventStoreChanged:(id)sender
{
    NSArray *events = [self fetchCalendarEventsForDate:self.date];
    
    if ([events count]>0) {
        [self.eventsDict setObject:events forKey:self.date];
    } else {
        [self.eventsDict removeObjectForKey:self.date];
    }
    //[self calendarViewReload];
}

#pragma mark - UIScrollView Delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
}


@end
