//
//  EPCalendarWeekViewController.h
//  CRMCalendar
//
//  Created by Sunayna Jain on 12/3/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "EPCalendarCollectionView.h"
#import "EPCalendarTableView.h"

@interface EPCalendarWeekViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, EPCalendarCollectionViewDelegate, EPCalendarTableViewDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *headerToolbar;
@property (weak, nonatomic) IBOutlet UIView *tableViewContainer;


@property (copy, nonatomic)   NSCalendar  *calendar;// default is [NSCalendar currentCalendar]. setting nil returns to default
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) EKEventStore *eventStore;
@property (strong, nonatomic) NSMutableDictionary *eventsDict;
@end
