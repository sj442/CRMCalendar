//
//  NewEventTVC.h
//  inlineDatePickerTVC
//
//  Created by Sunayna Jain on 6/13/14.
//  Copyright (c) 2014 LittleAuk. All rights reserved.
//

#import "EPInlineDatePickerTableViewController.h"

@interface EPCreateEventTableViewController : EPInlineDatePickerTableViewController <UITableViewDataSource, UITableViewDelegate>

-(id)initWithEvent:(EKEvent*)event eventName:(NSString*)name location:(NSString*)location notes:(NSString*)notes startDate:(NSDate*)startDate endDate:(NSDate*)endDate contact:(Contact*)contact;
-(id)initWithDate:(NSDate*)date;

@end
