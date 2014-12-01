//
//  NSDate+Format.m
//  CRMStar
//
//  Created by Sunayna Jain on 2/25/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "NSDate+Format.h"
#import "NSDate+Description.h"
#import "NSCalendar+Juncture.h"

@implementation NSDate (Format)

+ (NSString*)formattedDateFromDate:(NSDate*)date ForCalendar:(NSCalendar*)calendar
{
    //get day, month and year components from current Day
    
    NSDate *today = [NSDate date];
    NSDateComponents * todayComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    NSInteger todayYear = [todayComponents year];
    NSInteger todayMonth = [todayComponents month];
    NSInteger todayDay = [todayComponents day];
    
    //get year , month and day components from date parameter
    
    NSDateComponents * dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    NSInteger year = [dateComponents year];
    NSInteger month = [dateComponents month];
    NSInteger day = [dateComponents day];
    
    if (year==todayYear && month==todayMonth && day==todayDay){
        return @"Today";
    } else if (year==todayYear && month==todayMonth && day==todayDay-1) {
        return @"Yesterday";
    } else if (year==todayYear && month==todayMonth && day==todayDay+1) {
        return @"Tomorrow";
    } else {
        return [self datestringFromDate:date];
    }
}

+ (NSString*)datestringFromDate:(NSDate*)date
{
    NSDate  *now = [NSDate date];
    NSTimeInterval timeDifference = [now timeIntervalSinceDate:date];
    if (timeDifference<60 && timeDifference>0) {//upto 60 seconds
        return [NSString stringWithFormat:@"%ds", (int)timeDifference];
    } else if (timeDifference>=60 && timeDifference<3600) {//upto 60 mins
        NSInteger roundedMin = roundf(timeDifference/60);
        return [NSString stringWithFormat:@"%ldm", (long)roundedMin];
    } else if (timeDifference>=3600 && timeDifference<43200) {//upto 12 hrs
        NSInteger roundedHour = roundf(timeDifference/3600);
        return [NSString stringWithFormat:@"%ldh",(long)roundedHour];
    } else if (timeDifference>43200 && timeDifference<86400) {//upto 24 hrs
        return @"1d";
    } else {
        NSDateFormatter *dateFromatter = [[NSDateFormatter alloc] init];
        [dateFromatter setDateFormat:@"MM/dd/yy"];
        return [dateFromatter stringFromDate:date];
    }
}

+ (NSString *)formattedTimeFromDate:(NSDate *)date
{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    return [timeFormatter stringFromDate:date];
}

+ (NSDate*)calendarStartDateFromDate:(NSDate*)date ForCalendar:(NSCalendar*)calendar
{    
    NSDateComponents * dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit
                                                              | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    
    NSInteger year = [dateComponents year];
    NSInteger month = [dateComponents month];
    NSInteger day = [dateComponents day];
    NSInteger startHour = 00;
    NSInteger startMinute =01;
    
    NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
    [startDateComponents setYear:year];
    [startDateComponents setMonth:month];
    [startDateComponents setDay:day];
    [startDateComponents setHour:startHour];
    [startDateComponents setMinute:startMinute];
    
    return [calendar dateFromComponents:startDateComponents];
}

+ (NSDate*)calendarEndDateFromDate:(NSDate*)date ForCalendar:(NSCalendar*)calendar
{
    NSDateComponents * dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit
                                                              | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    NSInteger year = [dateComponents year];
    NSInteger month = [dateComponents month];
    NSInteger day = [dateComponents day];
    NSInteger endHour = 23;
    NSInteger endMinute = 59;
    
    NSDateComponents *endDateComponents = [[NSDateComponents alloc]init];
    [endDateComponents setYear:year];
    [endDateComponents setMonth:month];
    [endDateComponents setDay:day];
    [endDateComponents setHour:endHour];
    [endDateComponents setMinute:endMinute];
    
    return [calendar dateFromComponents:endDateComponents];
}

+ (NSDate*)createDateFromComponentsYear:(NSInteger)year andMonth:(NSInteger)month andDay:(NSInteger)day ForCalendar:(NSCalendar*)calendar
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    return [calendar dateFromComponents:components];
}

+ (NSString*)checkWeekOfDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger todayWeek = [calendar weekOfMonthInDate:[NSDate date]];
    NSInteger dateWeek =[calendar weekOfMonthInDate:date];
    if (dateWeek==todayWeek) {
        return @"This Week";
    } else if (dateWeek==todayWeek+1) {
        return @"Next Week";
    } else {
        return @"None";
    }
}

+ (NSString*)checkMonthOfDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger todayMonth = [calendar monthsInDate:[NSDate date]];
    NSInteger dateMonth = [calendar monthsInDate:date];
    if (todayMonth==dateMonth) {
        return @"This Month";
    } else if (dateMonth==todayMonth+1) {
        return @"Next Month";
    } else {
        return @"None";
    }
}

+ (NSString*)checkDayOfDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger todayDay = [calendar daysInDate:[NSDate date]];
    NSInteger dateDay = [calendar daysInDate:date];
    if (todayDay==dateDay) {
        return @"Today";
    } else if (dateDay ==todayDay+1) {
        return @"Tomorrow";
    } else {
        return @"None";
    }
}

+ (NSString*)getOrdinalSuffixForDate: (NSDate*)date forCalendar:(NSCalendar *)calendar{
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitDay fromDate:date];
    NSInteger day= [components day];
    NSString *monthName = [date monthNameOnCalendar:[NSCalendar currentCalendar]];
    NSInteger year = [components year];
	NSArray *suffixLookup = [NSArray arrayWithObjects:@"th",@"st",@"nd",@"rd",@"th",@"th",@"th",@"th",@"th",@"th", nil];
	if (day % 100 >= 11 && day % 100 <= 13) {
		return [NSString stringWithFormat:@"%ld%@ %@ %ld", (long)day, @"th", monthName, (long)year];
	}
	return [NSString stringWithFormat:@"%ld%@ %@ %ld ",(long)day, [suffixLookup objectAtIndex:(day % 10)], monthName, (long)year];
}

+ (NSString*)getWeekdayfromDate:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"cccc"];
    return [formatter stringFromDate:date];
}

- (NSDate *)dateOfPrevioiusSunday
{
    NSDate *today = [NSDate date];
    NSDate *previousSunday;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:today];
    NSInteger weekdayAdjustment = -1 * ([weekdayComponents weekday] - 1);
    NSInteger hourAdjustment = -1 * ([[gregorian components:NSHourCalendarUnit fromDate:today] hour]);
    NSInteger minuteAdjustment = -1 * ([[gregorian components:NSMinuteCalendarUnit fromDate:today] minute]);
    NSInteger secondAdjustment = -1 * ([[gregorian components:NSSecondCalendarUnit fromDate:today] second]);
    
    NSDateComponents *adjustmentComponents = [[NSDateComponents alloc] init];
    [adjustmentComponents setDay:weekdayAdjustment];
    [adjustmentComponents setHour:hourAdjustment];
    [adjustmentComponents setMinute:minuteAdjustment];
    [adjustmentComponents setSecond:secondAdjustment];
    
    previousSunday = [gregorian dateByAddingComponents:adjustmentComponents toDate:today options:0];
    
    return previousSunday;
}

- (BOOL)dateLiesWithinOneWeek
{
    NSDate *date = (NSDate *)self;
    NSDate *now = [NSDate date];
    NSDate *previousSunday = [self dateOfPrevioiusSunday];
    NSTimeInterval time1 = [date timeIntervalSince1970];
    NSTimeInterval time2 = [now timeIntervalSince1970];
    NSTimeInterval time3 = [previousSunday timeIntervalSince1970];
    if (time1>time3 && time1<time2) {
        return YES;
    }
    return NO;
}

- (BOOL)dateLiesWithinOneMonth
{
    NSDate *date = (NSDate *)self;
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:now];
    int year = [components year];
    int month = [components month];
    
    NSDateComponents *firstDayOfMonthComponents = [[NSDateComponents alloc]init];
    [firstDayOfMonthComponents setDay:1];
    [firstDayOfMonthComponents setMonth:month];
    [firstDayOfMonthComponents setYear:year];
    NSDate *firstDayOfMonth = [gregorian dateFromComponents:firstDayOfMonthComponents];
    
    NSTimeInterval time1 = [date timeIntervalSince1970];
    NSTimeInterval time2 = [now timeIntervalSince1970];
    NSTimeInterval time3 = [firstDayOfMonth timeIntervalSince1970];
    
    if (time1>time3 && time1<time2) {
        return YES;
    }
    return NO;
}

- (BOOL)dateLiesWithinOneQuarter
{
    NSDate *date = (NSDate *)self;
    NSDate *now = [NSDate date];
    NSNumber *nowQ = @0;
    NSNumber *dateQ = @0;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSMonthCalendarUnit|NSYearCalendarUnit fromDate:now];
    int month = [components month];
    int year = [components year];
    if (month<4) {
        nowQ = @1;
    } else if (month>=4 && month<7) {
        nowQ = @2;
    } else if (month>=7 && month<10) {
        nowQ = @3;
    } else {
        nowQ = @4;
    }
    NSTimeInterval time1 = [date timeIntervalSince1970];
    NSTimeInterval time2 = [now timeIntervalSince1970];
    if (time1<time2) {
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    int dateMonth = [dateComponents month];
    int dateYear  =[dateComponents year];
    if (dateMonth <4 && dateYear == year) {
        dateQ = @1;
    } else if (dateMonth>=4 && dateMonth <7 && dateYear == year) {
        dateQ = @2;
    } else if (dateMonth>= 7 && dateMonth <10 && dateYear == year) {
        dateQ = @3;
    } else if (dateMonth>=10 && dateYear == year) {
        dateQ = @4;
    }
    if ([dateQ isEqualToNumber:nowQ]) {
        return YES;
    }
    return NO;
    }
    return NO;
}

+ (NSDate *)thisYear
{
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear |
                                                          NSCalendarUnitMonth) fromDate:now];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:1];
    [comps setDay:1];
    [comps setYear:[components year]];
    
    return [gregorian dateFromComponents:comps];
}

+ (NSDate *)thisQuarter
{
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSMonthCalendarUnit) fromDate:now];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    int month = [components month];
    if (month<4) {
        [comps setMonth:1];
    } else if (month>=4 && month<7) {
        [comps setMonth:4];
    } else if (month>=7 && month<10) {
        [comps setMonth:7];
    } else {
        [comps setMonth:10];
    }
    
    [comps setDay:1];
    [comps setYear:[components year]];
    
    return [gregorian dateFromComponents:comps];
}

+ (NSDate *)thisMonth
{
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear |
                                                          NSCalendarUnitMonth) fromDate:now];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:[components month]];
    [comps setDay:1];
    [comps setYear:[components year]];
    
    return [gregorian dateFromComponents:comps];
}

+ (NSDate *)thisWeek
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int weekday = [comps weekday];
    NSDate *lastSunday = [[NSDate date] addTimeInterval:-3600*24*(weekday-1)];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear |
                                                          NSCalendarUnitMonth |
                                                          NSCalendarUnitWeekday |
                                                          NSCalendarUnitDay)
                                                fromDate:lastSunday];
    [components setSecond:0];
    [components setMinute:0];
    [components setHour:0];
    return [gregorian dateFromComponents:components];
}

@end
