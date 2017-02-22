//
//  QYCalendarView.m
//  QY
//
//  Created by ZLJuan on 16/12/5.
//  Copyright © 2016年 ZLJuan. All rights reserved.
//

#import "QYCalendarView.h"
#import "NSDate+Extend.h"
#import "QYCalendarCollectionViewCell.h"
#import "QYCalendarEmptyCollectionViewCell.h"
#import "QYCalendarCellEntity.h"
#import "QYCalendarDataManager.h"

@interface QYCalendarView () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel                        *monthLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray   *weekdayLabelCollection;
@property (weak, nonatomic) IBOutlet UICollectionView               *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout     *flowLayout;

@property (nonatomic, strong) NSDate                                *selectedDate;
//@property (nonatomic, assign) BOOL                                  isFirstShow;

@end

@implementation QYCalendarView

- (void)awakeFromNib
{
    [super awakeFromNib];
//    self.isFirstShow = YES;
    [self setupUI];
    [self setupCollectionView];
}

- (void)setupUI
{
    for (int i = 0; i < self.weekdayLabelCollection.count; i++) {
        NSString *localizeStringKey = [NSString stringWithFormat:@"CalendarDiaryList_Weekday_%d", i];
        UILabel *label = self.weekdayLabelCollection[i];
        label.text = LOCALIZE(localizeStringKey);
    }
    self.selectedDate = [NSDate date];
}

- (void)setCurrentMonth:(NSDate *)currentMonth
{
    for (NSDate *monthDate in [QYCalendarDataManager shareManager].monthArray) {
        if ([monthDate year] == [currentMonth year] && [monthDate month] == [currentMonth month]) {
            currentMonth = monthDate;
            [QYCalendarDataManager shareManager].currentMonth = monthDate;
            break;
        }
    }
    if (self.currentMonth == nil) {
        NSInteger section = [[QYCalendarDataManager shareManager].monthArray indexOfObject:currentMonth];
        [self layoutIfNeeded];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
    _currentMonth = currentMonth;
    self.monthLabel.text = [_currentMonth stringWithFormat:LOCALIZE(@"CalendarDiaryList_MonthDateFormat")];
}

/*
- (void)didMoveToSuperview
{
    [self.collectionView reloadData];
    if (self.isFirstShow) {
        NSInteger section = [[QYCalendarDataManager shareManager].monthArray indexOfObject:self.currentMonth];
        [self layoutIfNeeded];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
    self.isFirstShow = NO;
}*/

- (void)setupCollectionView
{
    self.flowLayout.itemSize = CGSizeMake(D_Screen_Width / 7, D_Screen_Width / 7);
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView.delegate = self;
    self.collectionView.decelerationRate = 0;
    self.collectionView.allowsSelection = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:@"QYCalendarCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"QYCalendarCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"QYCalendarEmptyCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"QYCalendarEmptyCollectionViewCell"];
    self.collectionView.scrollsToTop = NO;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [QYCalendarDataManager shareManager].monthArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[QYCalendarDataManager shareManager].monthArray[section] weekOfMonth] * 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *monthKey = [[QYCalendarDataManager shareManager].monthArray[indexPath.section] monthString];
    NSArray *cellEntityArray = [[QYCalendarDataManager shareManager].dataSourceDict objectForKey:monthKey];
    QYCalendarCellEntity *cellEntity = cellEntityArray[indexPath.item];
    if (cellEntity.cellType == QYCalendarCellType_CurrentMonth) {
        QYCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QYCalendarCollectionViewCell" forIndexPath:indexPath];
        [cell updateCellWithCalendarCellEntity:cellEntity];
        cell.selected = [cellEntity.gregorianDate isSomeDay:self.selectedDate];
        return cell;
    } else {
        QYCalendarEmptyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QYCalendarEmptyCollectionViewCell" forIndexPath:indexPath];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *monthKey = [[QYCalendarDataManager shareManager].monthArray[indexPath.section] monthString];
    NSArray *cellEntityArray = [[QYCalendarDataManager shareManager].dataSourceDict objectForKey:monthKey];
    QYCalendarCellEntity *cellEntity = cellEntityArray[indexPath.item];
    if (cellEntity.cellType == QYCalendarCellType_CurrentMonth) {
            NSDate *lastSelectedDate = self.selectedDate;
            NSInteger lastMonthCount = [lastSelectedDate firstWeekDayInMouth] - 1;
            NSInteger item = lastMonthCount + [lastSelectedDate day] - 1;
            NSInteger section = [[QYCalendarDataManager shareManager].monthArray indexOfObject:self.currentMonth];
            self.selectedDate = cellEntity.gregorianDate;
            [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:item inSection:section]]];
        if ([self.delegate respondsToSelector:@selector(calendarViewDidSelectedDay:)]) {
            [self.delegate calendarViewDidSelectedDay:cellEntity.gregorianDate];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollToWillShowSection];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollToWillShowSection];
}

- (void)scrollToWillShowSection
{
    NSInteger willShowSection = [self getWillShowSection];
    self.currentMonth = [QYCalendarDataManager shareManager].monthArray[willShowSection];
    if ([self.delegate respondsToSelector:@selector(calendarViewDidSelectedMonth:)]) {
        [self.delegate calendarViewDidSelectedMonth:self.currentMonth];
    }
    if (willShowSection <= 5) {
        NSDate *firstYear = [[QYCalendarDataManager shareManager].monthArray firstObject];
        NSArray *monthArray = [[QYCalendarDataManager shareManager] creatYearDataWithYearDate:[firstYear lastMonthDate]];
        [[QYCalendarDataManager shareManager].monthArray insertObjects:monthArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 12)]];
        [self.collectionView reloadData];
        willShowSection += 12;
        CGFloat changeHeight = 0;
        for (NSDate *date in monthArray) {
            changeHeight += date.weekOfMonth * D_Screen_Width / 7;
        }
        [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y + changeHeight) animated:NO];
    } else if ([QYCalendarDataManager shareManager].monthArray.count - willShowSection <= 5) {
        NSDate *lastYear = [[QYCalendarDataManager shareManager].monthArray lastObject];
        NSArray *monthArray = [[QYCalendarDataManager shareManager] creatYearDataWithYearDate:[lastYear nextMonthDate]];
        [[QYCalendarDataManager shareManager].monthArray insertObjects:monthArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([QYCalendarDataManager shareManager].monthArray.count, 12)]];
        [self.collectionView reloadData];
    }
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:willShowSection] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

// 想要更改选中哪一个月，在此处更改代码
- (NSInteger)getWillShowSection
{
    NSArray *indexPathArray = [self.collectionView indexPathsForVisibleItems];
//    for (NSIndexPath *indexPath in indexPathArray) {
//        if (indexPath.section != [[[QYCalendarDataManager shareManager] monthArray] indexOfObject:self.currentMonth]) {
//            return indexPath.section;
//        }
//    }
    
    NSInteger section1Count = 0;
    NSInteger section2Count = 0;
    NSInteger section1 = [[indexPathArray firstObject] section];
    NSInteger section2 = section1;
    for (NSIndexPath *indexPath in indexPathArray) {
        if (indexPath.section == section1) {
            section1Count++;
        } else {
            section2 = indexPath.section;
            section2Count++;
        }
    }
    return section1Count >= section2Count ? section1 : section2;
}

- (CGFloat)getCurrentHeight
{
    return 62 + [self.currentMonth weekOfMonth] * D_Screen_Width / 7;
}

- (void)markedDateArray:(NSArray *)dateArray inMonth:(NSDate *)monthDate
{
    [self markedDateArray:dateArray inMonth:monthDate isMarked:YES];
}

- (void)markedDateArray:(NSArray *)dateArray
{
    for (NSDate *date in dateArray) {
        [self markedDateArray:@[date] inMonth:[NSDate dateFromString:[NSString stringWithFormat:@"%ld-%ld", (long)[date year], (long)[date month]] withFormat:@"yyyy-M"]];
    }
}

- (void)cancelMarkedDateArray:(NSArray *)dateArray inMonth:(NSDate *)monthDate
{
    [self markedDateArray:dateArray inMonth:monthDate isMarked:NO];
}

- (void)cancelMarkedDateArray:(NSArray *)dateArray
{
    for (NSDate *date in dateArray) {
        [self cancelMarkedDateArray:@[date] inMonth:[NSDate dateFromString:[NSString stringWithFormat:@"%ld-%ld", (long)[date year], (long)[date month]] withFormat:@"yyyy-M"]];
    }
}

- (void)markedDateArray:(NSArray *)dateArray inMonth:(NSDate *)monthDate isMarked:(BOOL)isMarked
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[QYCalendarDataManager shareManager] markedDateArray:dateArray inMonth:monthDate isMarked:isMarked];
//        dispatch_async(dispatch_get_main_queue(), ^{
            for (int i = 0; i < [QYCalendarDataManager shareManager].monthArray.count; i++) {
                if ([[QYCalendarDataManager shareManager].monthArray[i] isSomeDay:monthDate]) {
                    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:i]];
                    return;
                }
            }
//        });
//    });
}

- (void)cancelAllMarked
{
    [[QYCalendarDataManager shareManager] cancelAllMarked];
}

@end
