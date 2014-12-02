//
//  CalendarView.m
//  CRMStar
//
//  Created by Sunayna Jain on 5/2/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.

#import "EPCalendarView.h"
#import "EPCalendarCell.h"
#import "NSCalendar+Juncture.h"
#import "NSCalendar+Components.h"
#import "NSDate+Format.h"
#import "NSDate+Description.h"
#import <QuartzCore/QuartzCore.h>
#import "NSCalendar+Ranges.h"
#import "NSCalendar+DateManipulation.h"
#import "UIColor+EH.h"
#import "EventStore.h"

@interface EPCalendarView()
{
    NSInteger todayDay;
    NSInteger todayMonth;
    NSInteger todayYear;
}
@property (strong, nonatomic) NSArray *dayEvents;
@property (strong, nonatomic) NSDate *today;
@property CGFloat lastContentOffset;

@property (weak, nonatomic) UIScrollView *scrollView;

@end

@implementation EPCalendarView

@synthesize swipeDelegate;
@synthesize calendarViewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.today = [NSDate date];
        self.calendar = [NSCalendar currentCalendar];
        todayDay = [self.calendar daysInDate:self.today];
        todayMonth =[self.calendar monthsInDate:self.today];
        todayYear = [self.calendar yearsInDate:self.today];
        self.date = [NSDate date];
        self.eventsDict = [[NSMutableDictionary alloc] init];
        [self setUpCollectionView];
        [self setUpTableView];
    }
    return self;
}

- (void)addEventStoreChangeNotification
{
    [self setupEventStore];
}

#pragma mark-Layout methods

- (void)setUpCollectionView
{
    //setting up week collection view
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.delegate = self;
    NSInteger numberOfSubViews = 3;
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * numberOfSubViews, self.frame.size.height);
    for (int i=0; i<numberOfSubViews; i++) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        EPCalendarCollectionView *collectionView = [[EPCalendarCollectionView alloc] initWithFrame:CGRectMake((i-1)*CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), [self cellSize].height) collectionViewLayout:flowLayout];
        collectionView.myDelegate = self;
        collectionView.scrollViewIndex = i;
        [self.scrollView addSubview:collectionView];
        [flowLayout setItemSize:[self cellSize]];
        [flowLayout setMinimumLineSpacing:1];
        [flowLayout setMinimumInteritemSpacing:1];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        UINib *nib = [UINib nibWithNibName:@"EPCalendarCell" bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:@"CalendarCell"];
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.scrollEnabled = NO;
        if (i==0) {
            self.collectionViewLeft = collectionView;
        } else if (i==1) {
            self.collectionViewMiddle = collectionView;
        } else if (i==2) {
            self.collectionViewRight = collectionView;
        }
        [self.scrollView setContentInset:UIEdgeInsetsMake(0, 320, 0, 0)];
    }
}

- (void)setUpTableView
{
    EPCalendarTableView *tableView = [[EPCalendarTableView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.collectionViewLeft.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-CGRectGetHeight(self.collectionViewLeft.frame))];
    [self addSubview:tableView];
    self.tableView = tableView;
    self.tableView.myDelegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)layoutSubviewForMonth
{
    self.collectionViewLeft.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.collectionViewMiddle.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.collectionViewRight.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.tableView.frame = CGRectMake(0, CGRectGetHeight(self.collectionViewLeft.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-CGRectGetHeight(self.collectionViewLeft.frame));
    [self.collectionViewLeft reloadData];
    [self.collectionViewMiddle reloadData];
    [self.collectionViewRight reloadData];
}

- (void)layoutSubviewsForWeek
{
    self.collectionViewLeft.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), [self cellSize].height);
    self.tableView.frame = CGRectMake(0, CGRectGetHeight(self.collectionViewLeft.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-CGRectGetHeight(self.collectionViewLeft.frame));
    self.collectionViewLeft.scrollEnabled = NO;
    [self calendarViewReload];
}

- (void)layoutSubviewForDay
{
    self.tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.collectionViewLeft.frame = CGRectMake(0, CGRectGetHeight(self.tableView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(self.tableView.frame));
    [self calendarViewReload];
}

- (void)calendarViewReload
{
    [self.collectionViewLeft reloadData];
    [self.tableView reloadData];
}

#pragma mark-UICollectionView DataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 7;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.displayMode==CKCalendarViewModeMonth) {
        return 6;
    } else if (self.displayMode==CKCalendarViewModeWeek) {
        return 1;
    }
    return 0;
}

#pragma mark-UICollectionView Delegate

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EPCalendarCell *cell = (EPCalendarCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"CalendarCell" forIndexPath:indexPath];
    NSInteger index = indexPath.section*7 +indexPath.row +1;
    [cell configureCell];
    
    if (self.displayMode==CKCalendarViewModeDay) {
        cell.dateLabel.text = @"";
        cell.indexDate = nil;
    }
    else if (self.displayMode ==CKCalendarViewModeMonth) { //month mode
        [self configureForMonthModeCell:cell ForIndex:index];
    }
    else //week mode
    {
        if (indexPath.section==0) {
            [self configureForWeekModeCell:cell ForIndex:index];
        }
            else {
            cell.dateLabel.text = @"";
        }
    }
    return cell;
}

- (void)configureForMonthModeCell:(EPCalendarCell*)cell ForIndex:(NSInteger)index
{
    if (index< [self getFirstVisibleDateDay]) {
        cell.dateLabel.text = @"";
        cell.indexDate = nil;
    }
    else if (index>=[self getFirstVisibleDateDay] && index < [self.calendar daysInDate:[self getLastVisibleDate]]+[self getFirstVisibleDateDay]) { //visible dates
        NSInteger day = index-[self.calendar weekdayInDate:[self getFirstVisibleDate]]+1;
        cell.dateLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        NSInteger month = [self.calendar monthsInDate:self.date];
        NSInteger year = [self.calendar yearsInDate:self.date];
        NSDate *indexDate = [NSDate createDateFromComponentsYear:year andMonth:month andDay:day ForCalendar:self.calendar];
        
        cell.indexDate = indexDate;
        
        //hightlight today's date if its in the month that's visible
        if (day==todayDay && month==todayMonth && year==todayYear) {
            cell.dateLabel.backgroundColor = [UIColor whiteColor];
            cell.dateLabel.textColor = [UIColor primaryColor];
        }
        NSArray *events = [self fetchCalendarEventsForDate:indexDate];
        if ([events count]>0) {
            NSDictionary *tempDict = [NSDictionary dictionaryWithObject:events forKey:indexDate];
            [self.eventsDict addEntriesFromDictionary:tempDict];
            cell.dotImageView.hidden = NO;
        }
        else {
            cell.dotImageView.hidden = YES;
        }
    }
    else { //if date beyond last visible date
        cell.dateLabel.text = @"";
    }
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

- (void)configureForWeekModeCell:(EPCalendarCell*)cell ForIndex:(NSInteger)index
{
    NSInteger selfDateDay = [self.calendar daysInDate:self.date];
    NSInteger selfDateMonth = [self.calendar monthsInDate:self.date];
    NSInteger selfDateYear = [self.calendar yearsInDate:self.date];
    NSInteger weeksInMonth = [self.calendar weeksPerMonthUsingReferenceDate:self.date];
    NSInteger weekOfMonth = [self.calendar weekOfMonthInDate:self.date];
    NSInteger day = 0;
        
        if (weekOfMonth==weeksInMonth) { //last week
           day= [self populateCalendarCell:cell ForLastWeekForIndex:index];
        }
        else if (weekOfMonth==1){//first week
            day =[self populateCalendarCell:cell forFirstWeekForInidex:index];
        }
        else { //all other weeks
            day =[self populateCalendarCell:cell forAllOtherWeeksForIndex:index];
        }
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
}


- (NSInteger)populateCalendarCell:(EPCalendarCell*)cell ForLastWeekForIndex:(NSInteger)index
{
    NSInteger day;
    NSDate *lastDate = [self.calendar lastDayOfTheMonthUsingReferenceDate:self.date];
    NSInteger lastDay = [self.calendar weekdayInDate:lastDate];
    NSDate *weekFirstDate = [self.calendar firstDayOfTheWeekUsingReferenceDate:self.date];
    NSInteger daysInWeekFirstDate = [self.calendar daysInDate:weekFirstDate];
    if (index<=lastDay){
        day = daysInWeekFirstDate+index-1;
        cell.dateLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        NSInteger month = [self.calendar monthsInDate:self.date];
        NSInteger year = [self.calendar yearsInDate:self.date];
        NSDate *indexDate = [NSDate createDateFromComponentsYear:year andMonth:month andDay:day ForCalendar:self.calendar];
        cell.indexDate = indexDate;
    }
    else {
        day=0;
        cell.dateLabel.text = @"";
    }
    return day;
}

- (NSInteger)populateCalendarCell:(EPCalendarCell*)cell forFirstWeekForInidex:(NSInteger)index
{
    NSInteger day;
    NSDate *firstDate = [self.calendar firstDayOfTheMonthUsingReferenceDate:self.date];
    NSInteger firstDateWeekday = [self.calendar weekdayInDate:firstDate];
    
    if (index>=firstDateWeekday){
        day = 1+index-firstDateWeekday;
        cell.dateLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        NSInteger month = [self.calendar monthsInDate:self.date];
        NSInteger year = [self.calendar yearsInDate:self.date];
        NSDate *indexDate = [NSDate createDateFromComponentsYear:year andMonth:month andDay:day ForCalendar:self.calendar];
        cell.indexDate = indexDate;
    }
    else {
        day=0;
        cell.dateLabel.text = @"";
    }
    return day;
}

- (NSInteger)populateCalendarCell:(EPCalendarCell*)cell forAllOtherWeeksForIndex:(NSInteger)index
{
    NSDate *firstDate = [self.calendar firstDayOfTheWeekUsingReferenceDate:self.date];
    NSInteger daysInFirstDate = [self.calendar daysInDate:firstDate];
    NSInteger day = daysInFirstDate+index-1;
    cell.dateLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
    NSInteger month = [self.calendar monthsInDate:self.date];
    NSInteger year = [self.calendar yearsInDate:self.date];
    NSDate *indexDate = [NSDate createDateFromComponentsYear:year andMonth:month andDay:day ForCalendar:self.calendar];
    cell.indexDate = indexDate;
    return day;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EPCalendarCell *cell= (EPCalendarCell*)[self.collectionViewLeft cellForItemAtIndexPath:indexPath];
    NSDate *indexDate = ((EPCalendarCell*)cell).indexDate;
    if (!indexDate){
        [self.collectionViewLeft deselectItemAtIndexPath:indexPath animated:NO];
    }
    else {
        self.date = indexDate;
        [self.swipeDelegate newDateToPassBack:indexDate];
        if (self.displayMode == CKCalendarViewModeMonth) { //month view
            [self.swipeDelegate displayModeChangedTo:CKCalendarViewModeDay];
            [self.swipeDelegate changeHeaderView];
            [self layoutSubviewForDay];
        }
        else { //week view
            [self calendarViewReload];
        }
    }
}

- (CGSize)cellSize
{
    if (self.frame.size.height>328) {
        return CGSizeMake(CGRectGetWidth(self.frame)/8,(CGRectGetHeight(self.frame))/7+5);
    } else {
        return CGSizeMake(CGRectGetWidth(self.frame)/8,(CGRectGetHeight(self.frame))/7);
    }
}

- (NSArray*)checkEventsDictionaryForPresenceOfDateKey:(NSDate*)date
{
    NSInteger year = [self.calendar yearsInDate:date];
    NSInteger month = [self.calendar monthsInDate:date];
    NSInteger day = [self.calendar daysInDate:date];
    date = [NSDate createDateFromComponentsYear:year andMonth:month andDay:day ForCalendar:self.calendar];
    NSArray *keys = [self.eventsDict allKeys];
    NSArray *events;
    for (NSDate *aDate in keys) {
        if ([aDate isEqualToDate:date]) {
            events = [self.eventsDict objectForKey:aDate];
        }
    }
    return events;
}

#pragma mark- UITableView Delegate & DataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *events = [self checkEventsDictionaryForPresenceOfDateKey:self.date];
    
    if ([events count]>0) {
        return [events count];
    }
    else {
        return 10;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = @"";
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    NSArray *events;
    
    if (![self.eventsDict objectForKey:self.date]) {
        events = [self fetchCalendarEventsForDate:self.date];
    }
    else {
        events = [self checkEventsDictionaryForPresenceOfDateKey:self.date];
    }
    if ([events count]>indexPath.row) {
        cell.textLabel.text = ((EKEvent*)events[indexPath.row]).title;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row==2 && [events count]==0) {
        cell.textLabel.text = @"No Events";
        cell.textLabel.textColor = [UIColor secondaryColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *events = [self checkEventsDictionaryForPresenceOfDateKey:self.date];
    if ([events count]>indexPath.row) {
        [self.calendarViewDelegate calendarView:self didSelectEvent:events[indexPath.row]];
    }
}

- (NSInteger)getFirstVisibleDateDay
{
    return [self.calendar weekdayInDate:[self getFirstVisibleDate]];
}

- (NSDate*)getFirstVisibleDate
{
    if (self.displayMode==CKCalendarViewModeMonth) {
        return [self.calendar firstDayOfTheMonthUsingReferenceDate:self.date];
    }
    else if (self.displayMode==CKCalendarViewModeWeek) {
        return [self.calendar firstDayOfTheWeekUsingReferenceDate:self.date];
    }
    else {
        return [NSDate date];
    }
}

- (NSDate*)getLastVisibleDate
{
    if (self.displayMode==CKCalendarViewModeMonth) {
        return [self.calendar lastDayOfTheMonthUsingReferenceDate:self.date];
    }
    else if (self.displayMode == CKCalendarViewModeWeek) {
        return [self.calendar lastDayOfTheWeekUsingReferenceDate:self.date];
    }
    else {
        return [NSDate date];
    }
}

- (NSInteger)getLastVisibleDateDay
{
    return [self.calendar weekdayInDate:[self getLastVisibleDate]];
}

#pragma mark-UISwipeGestureRecognizer methods

- (void)upSwipeHappened
{
    NSInteger month = [self.calendar monthsInDate:self.date];
    NSInteger year = [self.calendar yearsInDate:self.date];
    NSDate *newDate = [NSDate createDateFromComponentsYear:year andMonth:month+1 andDay:1 ForCalendar:self.calendar];
    self.date = newDate;
    [self.swipeDelegate newDateToPassBack:newDate];
    [self.collectionViewLeft reloadData];
}

- (void)downSwipeHappened
{
    NSInteger month = [self.calendar monthsInDate:self.date];
    NSInteger year = [self.calendar yearsInDate:self.date];
    NSDate *newDate = [NSDate createDateFromComponentsYear:year andMonth:month-1 andDay:1 ForCalendar:self.calendar];
    self.date = newDate;
    [self.swipeDelegate newDateToPassBack:newDate];
    [self.collectionViewLeft reloadData];
}

- (void)leftSwipeHappended
{
    NSInteger days= [self.calendar daysInDate:self.date];
    NSDate *lastDate = [self.calendar lastDayOfTheMonthUsingReferenceDate:self.date];
    NSInteger lastDay = [self.calendar daysInDate:lastDate];
    NSInteger weeksInMonth = [self.calendar weeksPerMonthUsingReferenceDate:self.date];
    NSInteger weekOfMonth = [self.calendar weekOfMonthInDate:self.date];
    if (lastDay-days<7) {
        if (weekOfMonth==weeksInMonth) {
            self.date = [self.calendar dateByAddingMonths:1 toDate:self.date];
            self.date = [self.calendar firstDayOfTheMonthUsingReferenceDate:self.date];
        } else {
            self.date = [self.calendar lastDayOfTheMonthUsingReferenceDate:self.date];
            self.date = [self.calendar firstDayOfTheWeekUsingReferenceDate:self.date];
        }
    } else {
        self.date = [self.calendar dateByAddingDays:7 toDate:self.date];
        self.date = [self.calendar firstDayOfTheWeekUsingReferenceDate:self.date];
    }
    [self.swipeDelegate newDateToPassBack:self.date];
    [self calendarViewReload];
}

- (void)rightSwipeHappened
{
    NSInteger days = [self.calendar daysInDate:self.date];
    NSInteger weekOfMonth = [self.calendar weekOfMonthInDate:self.date];
    if (days<8) {
        if (weekOfMonth==1) {
            self.date = [self.calendar dateBySubtractingMonths:1 fromDate:self.date];//go back 1 month
            self.date = [self.calendar lastDayOfTheMonthUsingReferenceDate:self.date]; //reset to last day of month
            self.date = [self.calendar firstDayOfTheWeekUsingReferenceDate:self.date];//first day of last week
        } else {
            self.date = [self.calendar firstDayOfTheMonthUsingReferenceDate:self.date];//second week, go to first week
        }
    } else {
        self.date = [self.calendar dateBySubtractingDays:7 fromDate:self.date]; //go back 1 week
        self.date = [self.calendar firstDayOfTheWeekUsingReferenceDate:self.date]; //reset to first day of the week
    }
    [self.swipeDelegate newDateToPassBack:self.date];
    [self calendarViewReload];
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
    [self calendarViewReload];
}

#pragma mark - UIScrollViewDelegate 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x>320 || scrollView.contentOffset.x<-320 ) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.lastContentOffset = scrollView.contentOffset.x;
}

-(void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (self.lastContentOffset < scrollView.contentOffset.x) {
        //moved right
        NSLog(@"moved right");
    } else if (self.lastContentOffset> scrollView.contentOffset.x) {
        //moved left
        NSLog(@"moved left");
    }
}

- (void)goBackOneWeek
{
    
}

- (void)goForwardOneWeek
{
    
}

- (void)goBackOneMonth
{
    
}

- (void)goForwardOneMonth
{
    
}

@end
