//
//  CalendarViewController.m
//  MyCalendar
//
//  Created by ZhenzhenXu on 2/11/13.
//  Copyright (c) 2013 ZhenzhenXu. All rights reserved.
//

#import "CalendarViewController.h"
#import "CalendarLogic.h"
#import "CalendarMonth.h"

@implementation CalendarViewController

#pragma mark -
#pragma mark Getters / setters

@synthesize calendarViewControllerDelegate;

@synthesize headerCalendarView=_headerCalendarView;
@synthesize calendarLogic=_calendarLogic;
@synthesize calendarView=_calendarView;
@synthesize calendarViewNew=_calendarViewNew;
@synthesize selectedDate=_selectedDate;
@synthesize leftButton;
@synthesize rightButton;

- (void)setSelectedDate:(NSDate *)aDate {
	_selectedDate = aDate;
	[_calendarLogic setReferenceDate:aDate];
	[_calendarView selectButtonForDate:aDate];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Calendar", @"");
	_headerCalendarView.bounds = CGRectMake(0, 0, 320, 314);
	_headerCalendarView.clearsContextBeforeDrawing = NO;
	_headerCalendarView.opaque = YES;
	_headerCalendarView.clipsToBounds = NO;
	
	NSDate *aDate = _selectedDate;
	if (aDate == nil) {
		aDate = [CalendarLogic dateForToday];
	}
	
	self.calendarLogic = [[CalendarLogic alloc] initWithDelegate:self referenceDate:aDate];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
									 initWithTitle:NSLocalizedString(@"Clear", @"") style:UIBarButtonItemStylePlain
									 target:self action:@selector(actionClearDate:)];    
	
	self.calendarView = [[CalendarMonth alloc] initWithFrame:CGRectMake(0, 0, 320, 314) logic:_calendarLogic];
	[self.calendarView selectButtonForDate:_selectedDate];
	[self.headerCalendarView addSubview:self.calendarView];
		
	
	UIButton *aLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
	aLeftButton.frame = CGRectMake(0, 0, 60, 60);
	aLeftButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 20);
	[aLeftButton setImage:[UIImage imageNamed:@"CalendarArrowLeft.png"] forState:UIControlStateNormal];
	[aLeftButton addTarget:_calendarLogic
					action:@selector(selectPreviousMonth)
		  forControlEvents:UIControlEventTouchUpInside];
	[self.headerCalendarView addSubview:aLeftButton];
	self.leftButton = aLeftButton;
	
	UIButton *aRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
	aRightButton.frame = CGRectMake(260, 0, 60, 60);
	aRightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 20, 0);
	[aRightButton setImage:[UIImage imageNamed:@"CalendarArrowRight.png"] forState:UIControlStateNormal];
	[aRightButton addTarget:_calendarLogic
					 action:@selector(selectNextMonth)
		   forControlEvents:UIControlEventTouchUpInside];
	[self.headerCalendarView addSubview:aRightButton];
	self.rightButton = aRightButton;
    
    //UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"page-bg.png"]];
    //self.view.backgroundColor = background;
}
- (void)viewDidUnload {
	self.calendarLogic.calendarLogicDelegate = nil;
	self.calendarLogic = nil;
	
	self.calendarView = nil;
	self.calendarViewNew = nil;
	
	self.selectedDate = nil;
	
	self.leftButton = nil;
	self.rightButton = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UI events

- (void)actionClearDate:(id)sender {
	self.selectedDate = nil;
	[_calendarView selectButtonForDate:nil];
	
	// Delegate called later.
	//[calendarViewControllerDelegate calendarViewController:self dateDidChange:nil];
}



#pragma mark -
#pragma mark CalendarLogic delegate

- (void)calendarLogic:(CalendarLogic *)aLogic dateSelected:(NSDate *)aDate {
	_selectedDate = aDate;
	
	if ([_calendarLogic distanceOfDateFromCurrentMonth:_selectedDate] == 0) {
		[_calendarView selectButtonForDate:_selectedDate];
	}
	
	[calendarViewControllerDelegate calendarViewController:self dateDidChange:aDate];
}
- (void)calendarLogic:(CalendarLogic *)aLogic monthChangeDirection:(NSInteger)aDirection {
	BOOL animate = self.isViewLoaded;
	
	CGFloat distance = 320;
	if (aDirection < 0) {
		distance = -distance;
	}
	
	leftButton.userInteractionEnabled = NO;
	rightButton.userInteractionEnabled = NO;
	
	CalendarMonth *aCalendarView = [[CalendarMonth alloc] initWithFrame:CGRectMake(distance, 0, 320, 314) logic:aLogic];
	aCalendarView.userInteractionEnabled = NO;
	if ([_calendarLogic distanceOfDateFromCurrentMonth:_selectedDate] == 0) {
		[aCalendarView selectButtonForDate:_selectedDate];
	}
	[self.headerCalendarView insertSubview:aCalendarView belowSubview:_calendarView];
	
	self.calendarViewNew = aCalendarView;
	
	if (animate) {
		[UIView beginAnimations:NULL context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationMonthSlideComplete)];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	}
	
	_calendarView.frame = CGRectOffset(_calendarView.frame, -distance, 0);
	aCalendarView.frame = CGRectOffset(aCalendarView.frame, -distance, 0);
	
	if (animate) {
		[UIView commitAnimations];
		
	} else {
		[self animationMonthSlideComplete];
	}
}

- (void)animationMonthSlideComplete {
	// Get rid of the old one.
	[_calendarView removeFromSuperview];
	
	// replace
	self.calendarView = _calendarViewNew;
	self.calendarViewNew = nil;
    
	leftButton.userInteractionEnabled = YES;
	rightButton.userInteractionEnabled = YES;
	_calendarView.userInteractionEnabled = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActivityCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
