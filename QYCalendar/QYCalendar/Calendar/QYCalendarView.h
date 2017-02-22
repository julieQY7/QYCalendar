//
//  QYCalendarView.h
//  QY
//
//  Created by ZLJuan on 16/12/5.
//  Copyright © 2016年 ZLJuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QYCalendarViewDelegate <NSObject>

- (void)calendarViewDidSelectedMonth:(NSDate *)month;
- (void)calendarViewDidSelectedDay:(NSDate *)day;

@end

@interface QYCalendarView : UIView

@property (nonatomic, strong) NSDate                    *currentMonth;
@property (nonatomic, weak) id<QYCalendarViewDelegate>  delegate;

- (CGFloat)getCurrentHeight;
// 标记当前有数据的日期
- (void)markedDateArray:(NSArray *)dateArray inMonth:(NSDate *)monthDate;
- (void)markedDateArray:(NSArray *)dateArray;// 当数据较少时使用，数据多时请先按月分割，使用- (void)markedDateArray:(NSArray *)dateArray inMonth:(NSDate *)monthDate
// 取消当前有数据的日期的标记
- (void)cancelMarkedDateArray:(NSArray *)dateArray inMonth:(NSDate *)monthDate;
- (void)cancelMarkedDateArray:(NSArray *)dateArray;// 当数据较少时使用，数据多时请先按月分割，使用- (void)cancelMarkedDateArray:(NSArray *)dateArray inMonth:(NSDate *)monthDate;
- (void)cancelAllMarked;

@end
