//
//  CalendarView.h
//  CRMStar
//
//  Created by Sunayna Jain on 5/2/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKCalendarViewModes.h"
#import <EventKit/EventKit.h>
#import "EPCalendarCollectionView.h"
#import "EPCalendarTableView.h"

@class EPCalendarView;

@protocol EPCalendarViewSwipeDelegate <NSObject>

-(void)newDateToPassBack:(NSDate*)date;
-(void)changeHeaderView;
-(void)displayModeChangedTo:(CKCalendarDisplayMode)mode;

@end

@protocol CalendarViewDelegate <NSObject>

//  A row is selected in the events table. (Use to push a detail view or whatever.)
- (void)calendarView:(EPCalendarView *)CalendarView didSelectEvent:(EKEvent *)event;

@end

@interface EPCalendarView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, EPCalendarCollectionViewDelegate, EPCalendarTableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) EPCalendarTableView *tableView;
@property (weak, nonatomic) EPCalendarCollectionView *collectionViewLeft;
@property (weak, nonatomic) EPCalendarCollectionView *collectionViewMiddle;
@property (weak, nonatomic) EPCalendarCollectionView *collectionViewRight;

@property (weak, nonatomic) id<EPCalendarViewSwipeDelegate> swipeDelegate;
@property (weak, nonatomic) id<CalendarViewDelegate> calendarViewDelegate;

@property (assign, nonatomic) CKCalendarDisplayMode displayMode;
@property (strong, nonatomic) EKEventStore *eventStore;
@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) NSMutableDictionary *eventsDict;

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSDate *indexDate;

@property CGRect calendarViewFrame;

@property (strong, nonatomic) NSString *headerTitle;
@property (copy, nonatomic)   NSCalendar  *calendar;// default is [NSCalendar currentCalendar]. setting nil returns to default

-(void)layoutSubviewsForWeek;
-(void)layoutSubviewForMonth;
-(void)layoutSubviewForDay;
-(void)calendarViewReload;
-(void)addEventStoreChangeNotification;

@end