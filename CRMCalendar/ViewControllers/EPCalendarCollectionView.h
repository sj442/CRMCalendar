//
//  CalendarCollectionView.h
//  CRMStar
//
//  Created by Sunayna Jain on 7/15/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EPCalendarCollectionViewDelegate <NSObject>

- (void)rightSwipeHappened;
- (void)leftSwipeHappended;
- (void)upSwipeHappened;
- (void)downSwipeHappened;

@end

@interface EPCalendarCollectionView : UICollectionView

@property (weak, nonatomic) id <EPCalendarCollectionViewDelegate> myDelegate;
@property (assign) BOOL monthMode;

@end
