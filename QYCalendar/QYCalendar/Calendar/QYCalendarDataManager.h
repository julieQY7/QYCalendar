//
//  QYCalendarTextManager.h
//  QY
//
//  Created by ZLJuan on 16/12/7.
//  Copyright © 2016年 ZLJuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYCalendarDataManager : NSObject

@property (nonatomic, strong) NSDate                *currentMonth;
@property (nonatomic, strong) NSMutableDictionary   *dataSourceDict;
@property (nonatomic, strong) NSMutableArray        *monthArray;

@property (nonatomic, strong) NSMutableDictionary   *markedDict;

+ (instancetype)shareManager;
- (void)createData; // 初始化时调用

- (NSString *)chineseTextOfDate:(NSDate *)date;

- (NSArray *)creatYearDataWithYearDate:(NSDate *)yearDate;

- (void)markedDateArray:(NSArray *)dateArray inMonth:(NSDate *)monthDate isMarked:(BOOL)isMarked;
- (void)cancelAllMarked;

@end
