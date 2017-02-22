//
//  QYCalendarEntity.h
//  QY
//
//  Created by ZLJuan on 16/12/6.
//  Copyright © 2016年 ZLJuan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QYCalendarCellType) {
    QYCalendarCellType_LastMonth,
    QYCalendarCellType_CurrentMonth,
    QYCalendarCellType_NextMonth
};

@interface QYCalendarCellEntity : NSObject

@property (nonatomic, strong) NSDate                *gregorianDate;
//@property (nonatomic, strong) NSDate                *chineseDate;
@property (nonatomic, copy) NSString                *gregorianShowString;
@property (nonatomic, copy) NSString                *chineseShowString;
@property (nonatomic, assign) BOOL                  marked;
@property (nonatomic, assign) QYCalendarCellType   cellType;

- (instancetype)initWithDate:(NSDate *)date cellType:(QYCalendarCellType)cellType;

@end
