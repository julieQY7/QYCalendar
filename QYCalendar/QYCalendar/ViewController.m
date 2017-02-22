//
//  ViewController.m
//  QYCalendar
//
//  Created by ZLJuan on 2017/2/8.
//  Copyright © 2017年 ZLJuan. All rights reserved.
//

#import "ViewController.h"
#import "QYCalendarView.h"

@interface ViewController () <QYCalendarViewDelegate>

@property (nonatomic, strong) QYCalendarView            *calendarView;
@property (weak, nonatomic) IBOutlet UIView             *calendarContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeightConstraint;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCalendarView];
}

- (void)setupCalendarView
{
    self.calendarView = [[[NSBundle mainBundle] loadNibNamed:@"QYCalendarView" owner:nil options:nil] lastObject];
    self.calendarView.currentMonth = [NSDate date];
    self.calendarContentViewHeightConstraint.constant = [self.calendarView getCurrentHeight];
    self.calendarView.frame = self.calendarContentView.bounds;
    self.calendarView.delegate = self;
    [self.calendarContentView addSubview:self.calendarView];
    self.calendarView.delegate = self;
    [self.calendarView markedDateArray:@[[NSDate dateFromString:@"2017/02/15" withFormat:@"yyyy/MM/dd"],[NSDate dateFromString:@"2017/02/17" withFormat:@"yyyy/MM/dd"], [NSDate dateFromString:@"2017/03/07" withFormat:@"yyyy/MM/dd"], [NSDate dateFromString:@"2017/03/12" withFormat:@"yyyy/MM/dd"], [NSDate dateFromString:@"2017/03/15" withFormat:@"yyyy/MM/dd"], [NSDate dateFromString:@"2017/04/22" withFormat:@"yyyy/MM/dd"], [NSDate dateFromString:@"2017/04/01" withFormat:@"yyyy/MM/dd"], [NSDate dateFromString:@"2017/05/01" withFormat:@"yyyy/MM/dd"], [NSDate dateFromString:@"2017/05/02" withFormat:@"yyyy/MM/dd"]]];
}

#pragma mark - QYCalendarViewDelegate
- (void)calendarViewDidSelectedMonth:(NSDate *)month // 滑到了某个月
{
    if (self.calendarContentViewHeightConstraint.constant != [self.calendarView getCurrentHeight]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.calendarContentViewHeightConstraint.constant = [self.calendarView getCurrentHeight];
            self.calendarView.frame = self.calendarContentView.bounds;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)calendarViewDidSelectedDay:(NSDate *)day // 选中了某天
{
    
}

@end
