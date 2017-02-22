//
//  QYCalendarEntity.m
//  QY
//
//  Created by ZLJuan on 16/12/6.
//  Copyright © 2016年 ZLJuan. All rights reserved.
//

#import "QYCalendarCellEntity.h"
#import "QYCalendarDataManager.h"

@implementation QYCalendarCellEntity

- (instancetype)initWithDate:(NSDate *)date cellType:(QYCalendarCellType)cellType
{
    if (self = [super init]) {
        self.gregorianDate = date;
        self.cellType = cellType;
        if (date != nil) {
            if ([self.gregorianDate isToday]) {
                self.gregorianShowString = LOCALIZE(@"CalendarDiaryList_Today");
            } else {
                self.gregorianShowString = [NSString stringWithFormat:@"%ld", (long)[self.gregorianDate day]];
            }
            self.chineseShowString = [[QYCalendarDataManager shareManager] chineseTextOfDate:self.gregorianDate];
        }
    }
    return self;
}

@end
