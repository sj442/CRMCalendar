//
//  NSDate+Format.h
//  CRMStar
//
//  Created by Sunayna Jain on 2/25/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSCalendar+Components.h"

@interface NSDate (Format)

+ (NSString*)datestringFromDate:(NSDate*)date;
+ (NSString*)formattedDateFromDate:(NSDate*)date ForCalendar:(NSCalendar*)calendar;
+ (NSString*)formattedTimeFromDate:(NSDate*)date;
+ (NSDate*)calendarStartDateFromDate:(NSDate*)date ForCalendar:(NSCalendar*)calendar;
+ (NSDate*)calendarEndDateFromDate:(NSDate*)date ForCalendar:(NSCalendar*)calendar;
+ (NSDate*)createDateFromComponentsYear:(NSInteger)year andMonth:(NSInteger)month andDay:(NSInteger)day ForCalendar:(NSCalendar*)calendar;
+ (NSString*)checkWeekOfDate:(NSDate*)date;
+ (NSString*)checkMonthOfDate:(NSDate*)date;
+ (NSString*)checkDayOfDate:(NSDate*)date;
+ (NSString*)getOrdinalSuffixForDate: (NSDate*)date forCalendar:(NSCalendar *)calendar;
+ (NSString*)getWeekdayfromDate:(NSDate*)date;

- (BOOL)dateLiesWithinOneWeek;
- (BOOL)dateLiesWithinOneMonth;
- (BOOL)dateLiesWithinOneQuarter;

+ (NSDate *)thisYear;
+ (NSDate *)thisQuarter;
+ (NSDate *)thisMonth;
+ (NSDate *)thisWeek;

@end
