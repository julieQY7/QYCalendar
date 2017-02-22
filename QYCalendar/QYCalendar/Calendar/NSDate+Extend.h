//
//  NSDate+Extend.h
//  MGC
//
//  Created by ZLJuan on 16/12/5.
//  Copyright © 2016年 ZLJuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extend)

- (NSInteger)dayOfMonth;
- (NSInteger)weekOfMonth;
- (NSInteger)firstWeekDayInMouth;
- (NSInteger)year;
- (NSInteger)month;
- (NSInteger)day;
- (NSDate *)nextDay;
- (NSDate *)lastDay;
- (NSDate *)lastMonthDate;
- (NSDate *)nextMonthDate;
- (NSDate *)dayInMonthWithIndex:(NSInteger)dayIndex;
//- (NSDate *)chineseDate;
- (NSInteger)chineseDay;
- (NSInteger)chineseMonth;
- (BOOL)isToday;
- (BOOL)isSomeDay:(NSDate *)otherDate;
- (NSString *)yearString;
- (NSString *)monthString;

@end
