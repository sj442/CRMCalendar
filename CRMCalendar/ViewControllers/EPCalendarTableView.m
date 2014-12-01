//
//  CalendarTableView.m
//  CRMStar
//
//  Created by Sunayna Jain on 7/15/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarTableView.h"

static CGFloat EPCalendarTableViewMinimumDetectDistance = 20;

@interface EPCalendarTableView ()

@property CGPoint initialPosition;

@end

@implementation EPCalendarTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.initialPosition = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint endPoint = [touch locationInView:self];
    CGFloat moveX = endPoint.x - self.initialPosition.x;
    if (moveX>EPCalendarTableViewMinimumDetectDistance) {
        //right swipe
        [self.myDelegate rightSwipeHappened];
    } else if (moveX<-EPCalendarTableViewMinimumDetectDistance) {
        //left swipe
        [self.myDelegate leftSwipeHappended];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

@end
