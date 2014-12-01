//
//  CalendarVC1.h
//  CRMStar
//
//  Created by Sunayna Jain on 4/25/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.

#import <UIKit/UIKit.h>
#import "CKCalendarViewModes.h"
#import "NSDate+Format.h"
#import "EPCalendarView.h"
#import "NSCalendarCategories.h"
#import "UIColor+EH.h"
#import "UIBarButtonItem+EH.h"
#import "NSDate+Description.h"
#import "NSDate+Format.h"
#import  <EventKit/EventKit.h>

@class EPCalendarViewController;

@interface EPCalendarViewController : UIViewController<UIGestureRecognizerDelegate, EPCalendarViewSwipeDelegate, CalendarViewDelegate>

@property (weak, nonatomic) EPCalendarView *calendarView;
@property (weak, nonatomic) UIToolbar *toolBar;
@property (nonatomic, assign) CKCalendarDisplayMode displayMode;
@property (nonatomic, strong) NSDate *date;
@property(nonatomic, copy)   NSCalendar *calendar;
@property (strong, nonatomic) EKEventStore *eventStore;

@end
