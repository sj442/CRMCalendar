//
//  CalendarCell.m
//  CalendarApp
//
//  Created by Sunayna Jain on 4/17/14.
//  Copyright (c) 2014 LittleAuk. All rights reserved.
//

#import "EPCalendarCell.h"

@implementation EPCalendarCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){

    }
    return self;
}

-(void)configureCell
{
    self.backgroundColor = [UIColor whiteColor];
    self.dotImageView.hidden = YES;
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.textColor = [UIColor blackColor];
    self.dateLabel.font = [UIFont boldSystemFontOfSize:17];
    self.indexDate = nil;
}

@end
