//
//  CalendarTableView.h
//  CRMStar
//
//  Created by Sunayna Jain on 7/15/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EPCalendarTableViewDelegate <NSObject>

-(void)rightSwipeHappened;
-(void)leftSwipeHappended;

@end

@interface EPCalendarTableView : UITableView

@property (weak, nonatomic) id <EPCalendarTableViewDelegate> myDelegate;

@end
