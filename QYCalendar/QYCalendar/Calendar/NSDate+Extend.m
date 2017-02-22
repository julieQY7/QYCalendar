//
//  NSDate+Extend.m
//  MGC
//
//  Created by ZLJuan on 16/12/5.
//  Copyright © 2016年 ZLJuan. All rights reserved.
//

#import "NSDate+Extend.h"

@implementation NSDate (Extend)

- (NSInteger)weekOfMonth
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [gregorianCalendar rangeOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:self].length;
}

- (NSInteger)dayOfMonth
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [gregorianCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self].length;
}

-(NSInteger)year
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [gregorianCalendar component:NSCalendarUnitYear fromDate:self];
}

-(NSInteger)month
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [gregorianCalendar component:NSCalendarUnitMonth fromDate:self];
}

-(NSInteger)day
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [gregorianCalendar component:NSCalendarUnitDay fromDate:self];
}

- (NSInteger)firstWeekDayInMouth
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self];
    components.day = 1;
    NSDate *firstDay = [gregorianCalendar dateFromComponents:components];
    return [gregorianCalendar component:NSCalendarUnitWeekday fromDate:firstDay];
}

- (NSDate *)lastMonthDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    components.day = 1;
    if (components.month == 1) {
        components.month = 12;
        components.year -= 1;
    } else {
        components.month -= 1;
    }
    return [gregorianCalendar dateFromComponents:components];
}

- (NSDate *)nextMonthDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    components.day = 1;
    if (components.month == 12) {
        components.month = 1;
        components.year += 1;
    } else {
        components.month += 1;
    }
    return [gregorianCalendar dateFromComponents:components];
}

- (NSDate *)nextDay
{
    return [[NSDate alloc] initWithTimeInterval:24 * 60 * 60 sinceDate:self];
}

- (NSDate *)lastDay
{
    return [[NSDate alloc] initWithTimeInterval:-24 * 60 * 60 sinceDate:self];
}

- (NSDate *)dayInMonthWithIndex:(NSInteger)dayIndex
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    components.day = dayIndex;
    return [gregorianCalendar dateFromComponents:components];
}

//- (NSDate *)chineseDate
//{
//    NSCalendar *chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
//    NSDateComponents *components = [chineseCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
//    return [chineseCalendar dateFromComponents:components];
//}

- (NSInteger)chineseDay
{
    NSCalendar *chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    return [chineseCalendar component:NSCalendarUnitDay fromDate:self];
}

- (NSInteger)chineseMonth
{
    NSCalendar *chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    return [chineseCalendar component:NSCalendarUnitMonth fromDate:self];
}

- (BOOL)isToday
{
    NSDate *today = [NSDate date];
    return [self year] == [today year] && [self month] == [today month] && [self day] == [today day];
}

- (BOOL)isSomeDay:(NSDate *)otherDate
{
    return [self year] == [otherDate year] && [self month] == [otherDate month] && [self day] == [otherDate day];
}

- (NSString *)yearString
{
    return [NSString stringWithFormat:@"%ld-1-1", (long)[self year]];
}

- (NSString *)monthString
{
    return [NSString stringWithFormat:@"%ld-%ld-1", (long)[self year], (long)[self month]];
}

@end
