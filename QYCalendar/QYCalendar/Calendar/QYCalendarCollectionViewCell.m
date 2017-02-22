//
//  QYCalendarCollectionViewCell.m
//  QY
//
//  Created by ZLJuan on 16/12/5.
//  Copyright © 2016年 ZLJuan. All rights reserved.
//

#import "QYCalendarCollectionViewCell.h"

@interface QYCalendarCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel        *gregorianLabel;
@property (weak, nonatomic) IBOutlet UILabel        *chineseLabel;
@property (weak, nonatomic) IBOutlet UIView         *bgView;
@property (weak, nonatomic) IBOutlet UIImageView    *flagIconImageView;

@property (nonatomic, strong) QYCalendarCellEntity *cellEntity;

@end

@implementation QYCalendarCollectionViewCell

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selected"];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.bgView.layer.cornerRadius = 21;
    self.bgView.layer.masksToBounds = YES;
    [self addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        self.bgView.backgroundColor = RGB(0x97, 0x97, 0x96);
        self.gregorianLabel.textColor = [UIColor whiteColor];
        self.chineseLabel.textColor = [UIColor whiteColor];
    } else {
        [self updateUI];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.bgView.backgroundColor = RGB(0x97, 0x97, 0x96);
        self.gregorianLabel.textColor = [UIColor whiteColor];
        self.chineseLabel.textColor = [UIColor whiteColor];
    } else {
        [self updateUI];
    }
}

- (void)updateCellWithCalendarCellEntity:(QYCalendarCellEntity *)cellEntity
{
    self.cellEntity = cellEntity;
    [self updateUI];
    self.gregorianLabel.text = cellEntity.gregorianShowString ? cellEntity.gregorianShowString : @"";
    self.chineseLabel.text = cellEntity.chineseShowString ? cellEntity.chineseShowString : @"";
    self.flagIconImageView.hidden = YES;
    if ([self.cellEntity.gregorianDate month] == 2 && [self.cellEntity.gregorianDate day] == 14) {
        self.flagIconImageView.hidden = NO;
        self.flagIconImageView.image = [UIImage imageNamed:@"calendardiarylist_0214.png"];
    } else if ([self.cellEntity.gregorianDate month] == 12 && [self.cellEntity.gregorianDate day] == 25) {
        self.flagIconImageView.hidden = NO;
        self.flagIconImageView.image = [UIImage imageNamed:@"calendardiarylist_1225.png"];
    }
}

- (void)updateUI
{
    if (self.cellEntity.marked) {
        self.gregorianLabel.textColor = [UIColor whiteColor];
        self.chineseLabel.textColor = [UIColor whiteColor];
        self.bgView.backgroundColor = RGB(0xbd, 0x23, 0x33);
    } else if ([self.cellEntity.gregorianDate isSomeDay:[NSDate date]]){
        self.gregorianLabel.textColor = RGB(0xbd, 0x23, 0x33);
        self.chineseLabel.textColor = RGB(0xbd, 0x23, 0x33);
        self.bgView.backgroundColor = [UIColor clearColor];
    } else if ([self.cellEntity.gregorianDate weekday] == 1 || [self.cellEntity.gregorianDate weekday] == 7) {
        self.gregorianLabel.textColor = RGB(129, 129, 129);
        self.chineseLabel.textColor = RGB(129, 129, 129);
        self.bgView.backgroundColor = [UIColor clearColor];
    } else {
        self.gregorianLabel.textColor = [UIColor blackColor];
        self.chineseLabel.textColor = [UIColor blackColor];
        self.bgView.backgroundColor = [UIColor clearColor];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.selected) {
        self.bgView.backgroundColor = RGB(0x97, 0x97, 0x96);
        self.gregorianLabel.textColor = [UIColor whiteColor];
        self.chineseLabel.textColor = [UIColor whiteColor];
    } else {
        [self updateUI];
    }
}

@end
