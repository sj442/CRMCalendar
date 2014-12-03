//
//  CalendarCell.h
//  CalendarApp
//
//  Created by Sunayna Jain on 4/17/14.
//  Copyright (c) 2014 LittleAuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EPCalendarCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dotImageView;
@property (strong, nonatomic) NSDate *indexDate;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;



-(void)configureCell;

@end
