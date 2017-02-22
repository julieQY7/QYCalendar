//
//  QYCalendarCollectionViewCell.h
//  QY
//
//  Created by ZLJuan on 16/12/5.
//  Copyright © 2016年 ZLJuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYCalendarCellEntity.h"

@interface QYCalendarCollectionViewCell : UICollectionViewCell

- (void)updateCellWithCalendarCellEntity:(QYCalendarCellEntity *)cellEntity;

@end
