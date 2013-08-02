//
//  CalendarViewController.h
//  MyCalendar
//
//  Created by ZhenzhenXu on 2/11/13.
//  Copyright (c) 2013 ZhenzhenXu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CalendarLogicDelegate.h"
#import "CalendarViewControllerDelegate.h"

@class CalendarLogic;
@class CalendarMonth;

@interface CalendarViewController : UITableViewController<CalendarLogicDelegate>

@property (nonatomic, assign) id <CalendarViewControllerDelegate> calendarViewControllerDelegate;

@property (nonatomic, strong) IBOutlet UIView *headerCalendarView;
@property (nonatomic, strong) CalendarLogic *calendarLogic;
@property (nonatomic, strong) CalendarMonth *calendarView;
@property (nonatomic, strong) CalendarMonth *calendarViewNew;
@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

- (void)animationMonthSlideComplete;

@end
