//
//  CalendarCollectionView.m
//  CRMStar
//
//  Created by Sunayna Jain on 7/15/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarCollectionView.h"

static CGFloat EPCalendarCollectionViewMinimumDetectDistance = 20;

@interface EPCalendarCollectionView ()

@property CGPoint initialPosition;

@end

@implementation EPCalendarCollectionView

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
    if (touch.tapCount ==0) {
        CGPoint endPoint = [touch locationInView:self];
        CGFloat moveX = endPoint.x - self.initialPosition.x;
        CGFloat moveY = endPoint.y - self.initialPosition.y;
        if (moveX>EPCalendarCollectionViewMinimumDetectDistance && !self.monthMode) {
        //right swipe
            [self.myDelegate rightSwipeHappened];
        } else if (moveX<-EPCalendarCollectionViewMinimumDetectDistance && !self.monthMode) {
        //left swipe
            [self.myDelegate leftSwipeHappended];
        } else if (moveY> EPCalendarCollectionViewMinimumDetectDistance && self.monthMode) {
        //down swipe
            [self.myDelegate downSwipeHappened];
        } else if (moveY<-EPCalendarCollectionViewMinimumDetectDistance && self.monthMode) {
        //up swipe
            [self.myDelegate upSwipeHappened];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

@end
