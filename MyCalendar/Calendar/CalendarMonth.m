//
//  CalendarMonth.m
//  Calendar
//
//  Created by Lloyd Bottomley on 29/04/10.
//  Copyright 2010 Savage Media Pty Ltd. All rights reserved.
//

#import "CalendarMonth.h"
#import "CalendarLogic.h"
#import <QuartzCore/QuartzCore.h>


#define kCalendarDayWidth	46.0f
#define kCalendarDayHeight	44.0f
#define kHeaderHeight	50.0f


@implementation CalendarMonth


#pragma mark -
#pragma mark Getters / setters

@synthesize calendarLogic;
@synthesize datesIndex;
@synthesize buttonsIndex;
@synthesize myActivitys;

@synthesize numberOfDaysInWeek;
@synthesize selectedButton;
@synthesize selectedDate;



#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	self.calendarLogic = nil;
	self.datesIndex = nil;
	self.buttonsIndex = nil;
	self.selectedDate = nil;
    self.myActivitys=nil;
	
    [super dealloc];
}



#pragma mark -
#pragma mark Initialization

// Calendar object init
- (id)initWithFrame:(CGRect)frame logic:(CalendarLogic *)aLogic {
	
	// Size is static
	NSInteger numberOfWeeks = 5;
	frame.size.width = 320;
	frame.size.height = ((numberOfWeeks + 1) * kCalendarDayHeight) + kHeaderHeight+1;
	selectedButton = -1;
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];	
	NSDate *todayDate = [calendar dateFromComponents:components];
	
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.backgroundColor=[UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.0f];
		self.opaque = YES;
		self.clipsToBounds = NO;
		self.clearsContextBeforeDrawing = NO;
		
		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
		//NSArray *daySymbols = [formatter shortWeekdaySymbols];
        NSArray *daySymbols = [[NSArray alloc] initWithObjects:@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六", nil];
		self.numberOfDaysInWeek = [daySymbols count];
		
		UILabel *aLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 30)] autorelease];
		aLabel.backgroundColor = [UIColor clearColor];
		aLabel.textAlignment = NSTextAlignmentCenter;
		aLabel.font = [UIFont boldSystemFontOfSize:20];
		aLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CalendarTitleColor.png"]];
		aLabel.shadowColor = [UIColor whiteColor];
		aLabel.shadowOffset = CGSizeMake(0, 1);
		
		[formatter setDateFormat:@"yyyy年M月"];
		aLabel.text = [formatter stringFromDate:aLogic.referenceDate];
		[self addSubview:aLabel];
		
		
		UIView *lineView = [[[UIView alloc] initWithFrame:CGRectMake(0, kHeaderHeight-1, 320, 1)] autorelease];
		lineView.backgroundColor = [UIColor lightGrayColor];
		[self addSubview:lineView];
        
        UIView *lineView2 = [[[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, 320, 1)] autorelease];
		lineView2.backgroundColor = [UIColor lightGrayColor];
		[self addSubview:lineView2];
		
		
		// Setup weekday names
		NSInteger firstWeekday = [calendar firstWeekday] - 1;
		for (NSInteger aWeekday = 0; aWeekday < numberOfDaysInWeek; aWeekday ++) {
 			NSInteger symbolIndex = aWeekday + firstWeekday;
			if (symbolIndex >= numberOfDaysInWeek) {
				symbolIndex -= numberOfDaysInWeek;
			}
			
			NSString *symbol = [daySymbols objectAtIndex:symbolIndex];
			CGFloat positionX = (aWeekday * kCalendarDayWidth) - 1;
			CGRect aFrame = CGRectMake(positionX, 30, kCalendarDayWidth, 20);
			
			aLabel = [[[UILabel alloc] initWithFrame:aFrame] autorelease];
			aLabel.backgroundColor = [UIColor clearColor];
			aLabel.textAlignment = NSTextAlignmentCenter;
			aLabel.text = symbol;
			aLabel.textColor = [UIColor darkGrayColor];
			aLabel.font = [UIFont systemFontOfSize:12];
			aLabel.shadowColor = [UIColor whiteColor];
			aLabel.shadowOffset = CGSizeMake(0, 1);
			[self addSubview:aLabel];
		}
		
		// Build calendar buttons (6 weeks of 7 days)
		NSMutableArray *aDatesIndex = [[[NSMutableArray alloc] init] autorelease];
		NSMutableArray *aButtonsIndex = [[[NSMutableArray alloc] init] autorelease];
		
		for (NSInteger aWeek = 0; aWeek <= numberOfWeeks; aWeek ++) {
			CGFloat positionY = (aWeek * kCalendarDayHeight) + kHeaderHeight;
			
			for (NSInteger aWeekday = 1; aWeekday <= numberOfDaysInWeek; aWeekday ++) {
				CGFloat positionX = ((aWeekday - 1) * kCalendarDayWidth) - 1;
				CGRect dayFrame = CGRectMake(positionX, positionY, kCalendarDayWidth, kCalendarDayHeight);
				NSDate *dayDate = [CalendarLogic dateForWeekday:aWeekday 
														 onWeek:aWeek 
												  referenceDate:[aLogic referenceDate]];
				NSDateComponents *dayComponents = [calendar 
												   components:NSDayCalendarUnit fromDate:dayDate];
				
				UIColor *titleColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CalendarTitleColor.png"]];
				if ([aLogic distanceOfDateFromCurrentMonth:dayDate] != 0) {
					titleColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CalendarTitleDimColor.png"]];
				}
				
				UIButton *dayButton = [UIButton buttonWithType:UIButtonTypeCustom];
				dayButton.opaque = YES;
				dayButton.clipsToBounds = NO;
				dayButton.clearsContextBeforeDrawing = NO;
				dayButton.frame = dayFrame;
				dayButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
				dayButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
				dayButton.tag = [aDatesIndex count];
				dayButton.adjustsImageWhenHighlighted = NO;
				dayButton.adjustsImageWhenDisabled = NO;
				dayButton.showsTouchWhenHighlighted = YES;
                //设置边框线的颜色
                [dayButton.layer setBorderWidth:0.5];
                UIColor *button_sep=[UIColor colorWithRed:0.901961f green:0.901961f blue:0.901961f alpha:1.0f];
                [dayButton.layer setBorderColor:[button_sep CGColor]];
				
				
				// Normal
				[dayButton setTitle:[NSString stringWithFormat:@"%d", [dayComponents day]] 
						   forState:UIControlStateNormal];
				
                UIColor *background=[UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.0f];
                [dayButton setBackgroundColor:background];
				[dayButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
				[dayButton setTitleColor:titleColor forState:UIControlStateNormal];
				if ([dayDate compare:todayDate] != NSOrderedSame) {
					// Normal
                    [dayButton setBackgroundImage:nil forState:UIControlStateNormal];
					
					// Selected
                    if ([self isActivityDay:dayDate]) {
                        UIColor *color=[UIColor colorWithRed:103/255.0f green:141/255.0f blue:22/255.0f alpha:1.0f];
                        [dayButton setBackgroundColor:color];
                        [dayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [dayButton setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
                    }
					
				} else {
					// Normal
                    [dayButton setBackgroundImage:[UIImage imageNamed:@"today_bg.png"] forState:UIControlStateNormal];
                    // Selected
                    if ([self isActivityDay:dayDate]) {
                        UIColor *color=[UIColor colorWithRed:103/255.0f green:141/255.0f blue:22/255.0f alpha:1.0f];
                        [dayButton setBackgroundColor:color];
                        [dayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [dayButton setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
                    }
				}

				
				[dayButton addTarget:self action:@selector(dayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
				[self addSubview:dayButton];
				
				// Save
				[aDatesIndex addObject:dayDate];
				[aButtonsIndex addObject:dayButton];
			}
		}
		
		// save
		self.calendarLogic = aLogic;
		self.datesIndex = [[aDatesIndex copy] autorelease];
		self.buttonsIndex = [[aButtonsIndex copy] autorelease];
    }
    return self;
}

- (BOOL)isActivityDay:(NSDate*)date{
    for (NSDictionary *activity in myActivitys) {
        //
    }
    if(rand()%3==1){
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark UI Controls

- (void)dayButtonPressed:(id)sender {
	[calendarLogic setReferenceDate:[datesIndex objectAtIndex:[sender tag]]];
}
- (void)selectButtonForDate:(NSDate *)aDate {
	if (selectedButton >= 0) {
		NSDate *todayDate = [CalendarLogic dateForToday];
		UIButton *button = [buttonsIndex objectAtIndex:selectedButton];
		
		CGRect selectedFrame = button.frame;
		if ([selectedDate compare:todayDate] != NSOrderedSame) {
			selectedFrame.origin.y = selectedFrame.origin.y;
			selectedFrame.size.width = kCalendarDayWidth;
			selectedFrame.size.height = kCalendarDayHeight;
		}
		
		button.selected = NO;
		button.frame = selectedFrame;
		
		self.selectedButton = -1;
		self.selectedDate = nil;
	}
	
	if (aDate != nil) {
		// Save
		self.selectedButton = [calendarLogic indexOfCalendarDate:aDate];
		self.selectedDate = aDate;
		
		NSDate *todayDate = [CalendarLogic dateForToday];
		UIButton *button = [buttonsIndex objectAtIndex:selectedButton];
		
		CGRect selectedFrame = button.frame;
		if ([aDate compare:todayDate] != NSOrderedSame) {
			selectedFrame.origin.y = selectedFrame.origin.y;
			selectedFrame.size.width = kCalendarDayWidth;
			selectedFrame.size.height = kCalendarDayHeight;
		}
		
		button.selected = YES;
		button.frame = selectedFrame;
		[self bringSubviewToFront:button];	
	}
}


@end
