//
//  EPCalendarMonthViewController.h
//  CRMCalendar
//
//  Created by Sunayna Jain on 12/2/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface EPCalendarMonthViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (copy, nonatomic)   NSCalendar  *calendar;// default is [NSCalendar currentCalendar]. setting nil returns to default
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) EKEventStore *eventStore;
@property (strong, nonatomic) NSMutableDictionary *eventsDict;

@end
