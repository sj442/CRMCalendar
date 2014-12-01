//
//  NSCalendar+Juncture.m
//   MBCalendarKit
//
//  Created by Moshe Berman on 4/10/13.
//  Copyright (c) 2013 Moshe Berman. All rights reserved.
//

#import "NSCalendar+DateManipulation.h"
#import "NSCalendar+Ranges.h"       //  To get the number of days in a week
#import "NSCalendar+Components.h"   //  To get specific components
#import "NSCalendar+DateManipulation.h"

@implementation NSCalendar (Juncture)

#pragma mark - First/Last of Week

- (NSDate *)firstDayOfTheWeek
{
    return [self firstDayOfTheWeekUsingReferenceDate:[NSDate date]];
}

- (NSDate *)firstDayOfTheWeekUsingReferenceDate:(NSDate *)date
{    
    NSInteger weekday = [self weekdayInDate:date]-1;
    return [self dateBySubtractingDays:weekday fromDate:date];
}

- (NSDate *)lastDayOfTheWeek
{
    return [self lastDayOfTheWeekUsingReferenceDate:[NSDate date]];
}

- (NSDate *)lastDayOfTheWeekUsingReferenceDate:(NSDate *)date
{
    NSDate *firstDayOfTheWeek = [self firstDayOfTheWeekUsingReferenceDate:date];
    NSUInteger daysPerWeek = [self daysPerWeekUsingReferenceDate:firstDayOfTheWeek];
    return [self dateByAddingDays:daysPerWeek-1 toDate:firstDayOfTheWeek];
}

#pragma mark - First/Last of Month

- (NSDate *)firstDayOfTheMonth
{
    return [self firstDayOfTheMonthUsingReferenceDate:[NSDate date]];
}

- (NSDate *)firstDayOfTheMonthUsingReferenceDate:(NSDate *)date
{
    NSDateComponents *components = [self components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    [components setDay:1];
    return [self dateFromComponents:components];
}

- (NSDate *)lastDayOfTheMonth
{
    return [self firstDayOfTheMonthUsingReferenceDate:[NSDate date]];
}

- (NSDate *)lastDayOfTheMonthUsingReferenceDate:(NSDate *)date
{
    
    NSDateComponents *components = [self components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:date];
    [components setDay:[self daysPerMonthUsingReferenceDate:date]];
    return [self dateFromComponents:components];
}
 
@end