//
//  QYCalendarTextManager.m
//  QY
//
//  Created by ZLJuan on 16/12/7.
//  Copyright © 2016年 ZLJuan. All rights reserved.
//

#import "QYCalendarDataManager.h"
#import "QYCalendarCellEntity.h"
#import <UIKit/UIKit.h>

@interface QYCalendarDataManager ()

@property (nonatomic, strong) NSArray           *chineseMonthArray;
@property (nonatomic, strong) NSArray           *chineseDayArray;
@property (nonatomic, strong) NSDictionary      *chineseFestivalDict;
@property (nonatomic, strong) NSDictionary      *gregorianFestivalDict;

@end

static QYCalendarDataManager *_manager;

@implementation QYCalendarDataManager

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[QYCalendarDataManager alloc] init];
        _manager.currentMonth = [NSDate date];
    });
    return _manager;
}

- (NSArray *)chineseDayArray
{
    if (_chineseDayArray == nil) {
        NSMutableArray *mArray = [NSMutableArray array];
        for (int i = 1; i <= 30; i++) {
            NSString *key = [NSString stringWithFormat:@"CalendarDiaryList_Day_%d", i];
            [mArray addObject:LOCALIZE(key)];
        }
        _chineseDayArray = mArray.copy;
    }
    return _chineseDayArray;
}

- (NSArray *)chineseMonthArray
{
    if (_chineseMonthArray == nil) {
        NSMutableArray *mArray = [NSMutableArray array];
        for (int i = 1; i <= 12; i++) {
            NSString *key = [NSString stringWithFormat:@"CalendarDiaryList_Month_%d", i];
            [mArray addObject:LOCALIZE(key)];
        }
        _chineseMonthArray = mArray.copy;
    }
    return _chineseMonthArray;
}

- (NSDictionary *)chineseFestivalDict
{
    if (_chineseFestivalDict == nil) {
        _chineseFestivalDict = @{@"1_1"     : LOCALIZE(@"CalendarDiaryList_ChineseFestival_1_1"),
                                 @"5_5"     : LOCALIZE(@"CalendarDiaryList_ChineseFestival_5_5"),
                                 @"8_15"    : LOCALIZE(@"CalendarDiaryList_ChineseFestival_8_15")};
    }
    return _chineseFestivalDict;
}

- (NSDictionary *)gregorianFestivalDict
{
    if (_gregorianFestivalDict == nil) {
        _gregorianFestivalDict = @{@"1_1"   : LOCALIZE(@"CalendarDiaryList_Festival_1_1"),
                                   @"2_14"  : LOCALIZE(@"CalendarDiaryList_Festival_2_14"),
                                   @"5_1"   : LOCALIZE(@"CalendarDiaryList_Festival_5_1"),
                                   @"10_1"  : LOCALIZE(@"CalendarDiaryList_Festival_10_1"),
                                   @"12_25" : LOCALIZE(@"CalendarDiaryList_Festival_12_25")};
    }
    return _gregorianFestivalDict;
}

- (NSString *)chineseTextOfDate:(NSDate *)date
{
    NSInteger chineseMonth = [date chineseMonth];
    NSInteger chineseDay = [date chineseDay];
    NSString *resultString = @"";
    if (chineseDay == 1) {
        resultString = self.chineseMonthArray[chineseMonth - 1];
    } else {
        resultString = self.chineseDayArray[chineseDay - 1];
    }
    NSString *festivalKey = [NSString stringWithFormat:@"%ld_%ld", (long)chineseMonth, (long)chineseDay];
    if ([self.chineseFestivalDict objectForKey:festivalKey]) {
        resultString = [self.chineseFestivalDict objectForKey:festivalKey];
    }
    NSInteger month = [date month];
    NSInteger day = [date day];
    festivalKey = [NSString stringWithFormat:@"%ld_%ld", (long)month, (long)day];
    if ([_manager.gregorianFestivalDict objectForKey:festivalKey]) {
        resultString = [self.gregorianFestivalDict objectForKey:festivalKey];
    }
    if (chineseMonth == 12 && chineseDay >= 29) {
        if ([[date nextDay] chineseDay] == 1) {
            return LOCALIZE(@"CalendarDiaryList_Festival_Chuxi");
        }
    }
    
    if ([date year] >= 1900 && [date year] <= 2100) {
        if (month == 4 && day >= 4 && day <= 6) {
            if (day == [self qingmingFestivalDay:date]) {
                return LOCALIZE(@"CalendarDiaryList_Festival_Qingming");
            }
        }
    }
    return resultString;
}

- (void)createData
{
    self.monthArray = nil;
    self.dataSourceDict = nil;
    self.chineseDayArray = nil;
    self.chineseMonthArray = nil;
    self.chineseFestivalDict = nil;
    self.gregorianFestivalDict = nil;
    NSInteger year = [self.currentMonth year];
    for (NSInteger i = year - 1; i <= year + 1; i++) {
        NSDate *yearDate = [NSDate dateFromString:[NSString stringWithFormat:@"%ld-1-1", (long)i] withFormat:@"yyyy-M-d"];
        NSArray *monthArray = [self creatYearDataWithYearDate:yearDate];
        [self.monthArray insertObjects:monthArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.monthArray.count, 12)]];
    }
}

- (NSArray *)creatYearDataWithYearDate:(NSDate *)yearDate
{
    NSMutableArray *monthMArray = [NSMutableArray array];
    NSInteger year = [yearDate year];
    for (NSInteger i = 1; i <= 12; i++) {
        NSDate *monthDate = [NSDate dateFromString:[NSString stringWithFormat:@"%ld-%ld-1", (long)year, (long)i] withFormat:@"yyyy-M-d"];
        [self.dataSourceDict setObject:[self createMonthDataArrayWithMonthDate:monthDate] forKey:[monthDate monthString]];
        [monthMArray addObject:monthDate];
        if (year == [self.currentMonth year] && i == [self.currentMonth month]) {
            self.currentMonth = monthDate;
        }
    }
    return monthMArray.copy;
}

- (NSArray *)createMonthDataArrayWithMonthDate:(NSDate *)monthDate
{
    NSInteger totalCount = [monthDate weekOfMonth] * 7;
    NSInteger lastMonthCount = [monthDate firstWeekDayInMouth] - 1;
    NSInteger currentMonthCount = [monthDate dayOfMonth];
    NSInteger nextMonthCount = totalCount - lastMonthCount - currentMonthCount;
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:totalCount];
    for (int i = 0; i < lastMonthCount; i++) {
        QYCalendarCellEntity *cellEntity = [[QYCalendarCellEntity alloc] initWithDate:nil cellType:QYCalendarCellType_LastMonth];
        [mArray addObject:cellEntity];
    }
    for (int i = 0; i < currentMonthCount; i++) {
        NSDate *date = [monthDate dayInMonthWithIndex:i + 1];
        QYCalendarCellEntity *cellEntity = [[QYCalendarCellEntity alloc] initWithDate:date cellType:QYCalendarCellType_CurrentMonth];
        NSArray *markedArray = [self.markedDict objectForKey:[monthDate monthString]];
        for (NSDate *markedDate in markedArray) {
            if ([date isSomeDay:markedDate]) {
                cellEntity.marked = YES;
                break;
            }
        }
        [mArray addObject:cellEntity];
    }
    for (int i = 0; i < nextMonthCount; i++) {
        QYCalendarCellEntity *cellEntity = [[QYCalendarCellEntity alloc] initWithDate:nil cellType:QYCalendarCellType_NextMonth];
        [mArray addObject:cellEntity];
    }
    return mArray.copy;
}

- (void)markedDateArray:(NSArray *)dateArray inMonth:(NSDate *)monthDate isMarked:(BOOL)isMarked
{
    NSMutableArray *dateMArray = dateArray.mutableCopy;
    NSString *monthKey = [monthDate monthString];
    NSArray *cellEntityArray = [self.dataSourceDict objectForKey:monthKey];
    for (QYCalendarCellEntity *cellEntity in cellEntityArray) {
        NSDate *markedDate = nil;
        for (NSDate *date in dateMArray) {
            if ([date isSomeDay:cellEntity.gregorianDate]) {
                cellEntity.marked = isMarked;
                markedDate = date;
                break;
            }
        }
        [dateMArray removeObject:markedDate];
        if (dateMArray.count == 0) {
            break;
        }
    }
    
    NSArray *oldDateArray = [self.markedDict objectForKey:monthKey];
    NSMutableArray *mArray = [NSMutableArray arrayWithArray:oldDateArray];
    if (isMarked) {
        for (NSDate *newDate in dateArray) {
            BOOL isHas = NO;
            for (NSDate *oldDate in oldDateArray) {
                if ([newDate isSomeDay:oldDate]) {
                    isHas = YES;
                    break;
                }
            }
            if (!isHas) {
                [mArray addObject:newDate];
            }
        }
    } else {
        if (mArray.count) {
            for (NSDate *newDate in dateArray) {
                for (NSDate *oldDate in oldDateArray) {
                    if ([newDate isSomeDay:oldDate]) {
                        [mArray removeObject:oldDate];
                        break;
                    }
                }
            }
        }
    }
    if (mArray.count != 0) {
        [self.markedDict setObject:mArray.copy forKey:monthKey];
    }
}

- (void)cancelAllMarked
{
    for (NSString *key in self.markedDict) {
        NSArray *monthArray = [self.markedDict objectForKey:key];
        [self markedDateArray:monthArray inMonth:[NSDate dateFromString:key withFormat:@"yyyy-M-d"] isMarked:NO];
    }
    self.markedDict = nil;
}

- (NSMutableDictionary *)markedDict
{
    if (_markedDict == nil) {
        _markedDict = [NSMutableDictionary dictionary];
    }
    return _markedDict;
}

- (NSMutableDictionary *)dataSourceDict
{
    if (_dataSourceDict == nil) {
        _dataSourceDict = [NSMutableDictionary dictionary];
    }
    return _dataSourceDict;
}

- (NSMutableArray *)monthArray
{
    if (_monthArray == nil) {
        _monthArray = [NSMutableArray array];
    }
    return _monthArray;
}

- (NSInteger)qingmingFestivalDay:(NSDate *)yearDate
{
    NSInteger year = [yearDate year];
    CGFloat c = 4.81;
    CGFloat d = 0.2422;
    if (year / 100 == 19) {
        c = 5.59;
    }
    return ((year % 100) * d + c) - (year % 100) / 4;
}

/*
double CalcSunEclipticLongitudeEC(double dt)
{
    double L0 = CalcPeriodicTerm(Earth_L0, sizeof(Earth_L0) / sizeof(VSOP87_COEFFICIENT), dt);
    double L1 = CalcPeriodicTerm(Earth_L1, sizeof(Earth_L1) / sizeof(VSOP87_COEFFICIENT), dt);
    double L2 = CalcPeriodicTerm(Earth_L2, sizeof(Earth_L2) / sizeof(VSOP87_COEFFICIENT), dt);
    double L3 = CalcPeriodicTerm(Earth_L3, sizeof(Earth_L3) / sizeof(VSOP87_COEFFICIENT), dt);
    double L4 = CalcPeriodicTerm(Earth_L4, sizeof(Earth_L4) / sizeof(VSOP87_COEFFICIENT), dt);
    double L5 = CalcPeriodicTerm(Earth_L5, sizeof(Earth_L5) / sizeof(VSOP87_COEFFICIENT), dt);
    double L = (((((L5 * dt + L4) * dt + L3) * dt + L2) * dt + L1) * dt + L0) / 100000000.0;
    return (Mod360Degree(Mod360Degree(L / RADIAN_PER_ANGLE) + 180.0));
    
}

double CalcPeriodicTerm(const VSOP87_COEFFICIENT *coff, int count, double dt)
{
    double val = 0.0;
    for(int i = 0; i < count; i++)
        val += (coff[i].A * cos((coff[i].B + coff[i].C * dt)));
    return val;
}

double CalcSunEclipticLatitudeEC(double dt)
{
    double B0 = CalcPeriodicTerm(Earth_B0, sizeof(Earth_B0) / sizeof(VSOP87_COEFFICIENT), dt);
    double B1 = CalcPeriodicTerm(Earth_B1, sizeof(Earth_B1) / sizeof(VSOP87_COEFFICIENT), dt);
    double B2 = CalcPeriodicTerm(Earth_B2, sizeof(Earth_B2) / sizeof(VSOP87_COEFFICIENT), dt);
    double B3 = CalcPeriodicTerm(Earth_B3, sizeof(Earth_B3) / sizeof(VSOP87_COEFFICIENT), dt);
    double B4 = CalcPeriodicTerm(Earth_B4, sizeof(Earth_B4) / sizeof(VSOP87_COEFFICIENT), dt);
    double B = (((((B4 * dt) + B3) * dt + B2) * dt + B1) * dt + B0) / 100000000.0;
    return -(B / RADIAN_PER_ANGLE);
}

double AdjustSunEclipticLongitudeEC(double dt, double longitude, double latitude)
{
    double T = dt * 10;
    double dbLdash = longitude - 1.397 * T - 0.00031 * T * T;
    dbLdash *= RADIAN_PER_ANGLE;
    return (-0.09033 + 0.03916 * (cos(dbLdash) + sin(dbLdash)) * tan(latitude * RADIAN_PER_ANGLE)) / 3600.0;
}

double CalcEarthLongitudeNutation(double dt)
{
    double T = dt * 10;
    double D,M,Mp,F,Omega;
    GetEarthNutationParameter(dt, &D, &M, &Mp, &F, &Omega);
    double resulte = 0.0 ;
    for(int i = 0; i < sizeof(nutation) / sizeof(nutation[0]); i++)
    {
        double sita = nutation[i].D * D + nutation[i].M * M + nutation[i].Mp * Mp + nutation[i].F * F + nutation[i].omega * Omega;
        resulte += (nutation[i].sine1 + nutation[i].sine2 * T ) * sin(sita);
    }
    return resulte * 0.0001 / 3600.0;
    
}

void GetEarthNutationParameter(double dt, double *D, double *M, double *Mp, double *F, double *Omega)

{
    double T = dt * 10;
    double T2 = T * T;
    double T3 = T2 * T;
    *D = 297.85036 + 445267.111480 * T - 0.0019142 * T2 + T3 / 189474.0;
    *M = 357.52772 + 35999.050340 * T - 0.0001603 * T2 - T3 / 300000.0;
    *Mp = 134.96298 + 477198.867398 * T + 0.0086972 * T2 + T3 / 56250.0;
    *F = 93.27191 + 483202.017538 * T - 0.0036825 * T2 + T3 / 327270.0;
    *Omega = 125.04452 - 1934.136261 * T + 0.0020708 * T2 + T3 / 450000.0;
}

double CalcEarthObliquityNutation(double dt)
{
    double T = dt * 10;
    double D,M,Mp,F,Omega;
    GetEarthNutationParameter(dt, &D, &M, &Mp, &F, &Omega);
    double resulte = 0.0 ;
    for(int i = 0; i < sizeof(nutation) / sizeof(nutation[0]); i++)
    {
        double sita = nutation[i].D * D + nutation[i].M * M + nutation[i].Mp * Mp + nutation[i].F * F + nutation[i].omega * Omega;
        resulte += (nutation[i].cosine1 + nutation[i].cosine2 * T ) * cos(sita);
    }
    return resulte * 0.0001 / 3600.0;
    
}

double CalcSunEarthRadius(double dt)
{
    double R0 = CalcPeriodicTerm(Earth_R0, sizeof(Earth_R0) / sizeof(VSOP87_COEFFICIENT), dt);
    double R1 = CalcPeriodicTerm(Earth_R1, sizeof(Earth_R1) / sizeof(VSOP87_COEFFICIENT), dt);
    double R2 = CalcPeriodicTerm(Earth_R2, sizeof(Earth_R2) / sizeof(VSOP87_COEFFICIENT), dt);
    double R3 = CalcPeriodicTerm(Earth_R3, sizeof(Earth_R3) / sizeof(VSOP87_COEFFICIENT), dt);
    double R4 = CalcPeriodicTerm(Earth_R4, sizeof(Earth_R4) / sizeof(VSOP87_COEFFICIENT), dt);
    double R = (((((R4 * dt) + R3) * dt + R2) * dt + R1) * dt + R0) / 100000000.0;
    return R;
    
}

double GetSunEclipticLongitudeEC(double jde)
{
    double dt = (jde - JD2000) / 365250.0;
    double longitude = CalcSunEclipticLongitudeEC(dt);
    double latitude = CalcSunEclipticLatitudeEC(dt) * 3600.0;
    longitude += AdjustSunEclipticLongitudeEC(dt, longitude, latitude);
    longitude += CalcEarthLongitudeNutation(dt);
    longitude -= (20.4898 / CalcSunEarthRadius(dt)) / (20 * PI);
    return longitude;
    
}

double CalculateSolarTerms(int year, int angle)
{
    double lJD, rJD;
    EstimateSTtimeScope(year, angle, lJD, rJD);
    double solarTermsJD = 0.0;
    double longitude = 0.0;
    do
    {
        solarTermsJD = ((rJD - lJD) * 0.618) + lJD;
        longitude = GetSunEclipticLongitudeECDegree(solarTermsJD);
        longitude = ((angle == 0) && (longitude > 345.0)) ? longitude - 360.0 : longitude;
        (longitude > double(angle)) ? rJD = solarTermsJD : lJD = solarTermsJD;
            
    }while((rJD - lJD) > 0.0000001);
    return solarTermsJD;
    
}
 
double CalculateSolarTermsNewton(int year, int angle)
{
    double JD0, JD1,stDegree,stDegreep;
    JD1 = GetInitialEstimateSolarTerms(year, angle);
    do
    {
        JD0 = JD1;
        stDegree = GetSunEclipticLongitudeECDegree(JD0) - angle;
 
        stDegreep = (GetSunEclipticLongitudeECDegree(JD0 + 0.000005) - GetSunEclipticLongitudeECDegree(JD0 - 0.000005)) / 0.00001;
        JD1 = JD0 - stDegree / stDegreep;
    }while((fabs(JD1 - JD0) > 0.0000001));
    return JD1;
}
*/


/*
rad = 180*3600/M_PI; //每弧度的角秒数
RAD = 180/M_PI; //每弧度的角度数
function int2(v){ //取整数部分
    v=Math.floor(v);
    if(v<0) return v+1;
    else return v;
}
function rad2mrad(v){ //对超过0-2PI的角度转为0-2PI
    v=v % (2*Math.PI);
    if(v<0) return v+2*Math.PI;
    return v;
}
function rad2str(d,tim){ //将弧度转为字串
    //tim=0输出格式示例: -23°59' 48.23"
    //tim=1输出格式示例: 18h 29m 44.52s
    var s="+";
    var w1="°",w2="’",w3="”";
    if(d<0) d=-d,s='-';
    if(tim){ d*=12/Math.PI; w1="h ",w2="m ",w3="s "; }
    else d*=180/Math.PI;
    var a=Math.floor(d); d=(d-a)*60;
    var b=Math.floor(d); d=(d-b)*60;
    var c=Math.floor(d); d=(d-c)*100;
    d=Math.floor(d+0.5);
    if(d>=100) d-=100, c++;
    if(c>=60) c-=60, b++;
    if(b>=60) b-=60, a++;
    a=" "+a, b="0"+b, c="0"+c, d="0"+d;
    s+=a.substr(a.length-3,3)+w1;
    s+=b.substr(b.length-2,2)+w2;
    s+=c.substr(c.length-2,2)+".";
    s+=d.substr(d.length-2,2)+w3;
    return s;
}
//================日历计算===============
var J2000=2451545; //2000年前儒略日数(2000-1-1 12:00:00格林威治平时)
var JDate={ //日期元件
Y:2000, M:1, D:1, h:12, m:0, s:0,
dts:new Array( //世界时与原子时之差计算表
              -4000,108371.7,-13036.80,392.000, 0.0000, -500, 17201.0, -627.82, 16.170,-0.3413,
              -150, 12200.6, -346.41, 5.403,-0.1593, 150, 9113.8, -328.13, -1.647, 0.0377,
              500, 5707.5, -391.41, 0.915, 0.3145, 900, 2203.4, -283.45, 13.034,-0.1778,
              1300, 490.1, -57.35, 2.085,-0.0072, 1600, 120.0, -9.81, -1.532, 0.1403,
              1700, 10.2, -0.91, 0.510,-0.0370, 1800, 13.4, -0.72, 0.202,-0.0193,
              1830, 7.8, -1.81, 0.416,-0.0247, 1860, 8.3, -0.13, -0.406, 0.0292,
              1880, -5.4, 0.32, -0.183, 0.0173, 1900, -2.3, 2.06, 0.169,-0.0135,
              1920, 21.2, 1.69, -0.304, 0.0167, 1940, 24.2, 1.22, -0.064, 0.0031,
              1960, 33.2, 0.51, 0.231,-0.0109, 1980, 51.0, 1.29, -0.026, 0.0032,
              2000, 64.7, -1.66, 5.224,-0.2905, 2150, 279.4, 732.95,429.579, 0.0158, 6000),
deltatT:function(y){ //计算世界时与原子时之差,传入年
    var i,d=this.dts;
    for(i=0;i<100;i+=5)
        if(y<d[i+5]||i==95) break;
    var t1=(y-d[i])/(d[i+5]-d[i])*10, t2=t1*t1, t3=t2*t1;
    return d[i+1] +d[i+2]*t1 +d[i+3]*t2 +d[i+4]*t3;
},
deltatT2:function(jd){ //传入儒略日(J2000起算),计算UTC与原子时的差(单位:日)
    return this.deltatT(jd/365.2425+2000)/86400.0;
},
toJD:function(UTC){ //公历转儒略日,UTC=1表示原日期是UTC
    var y=this.Y, m=this.M, n=0; //取出年月
    if(m<=2) m+=12,y--;
    if(this.Y*372+this.M*31+this.D>=588829)//判断是否为格里高利历日1582*372+10*31+15
        n =int2(y/100), n =2-n+int2(n/4);//加百年闰
    n +=int2(365.2500001*(y+4716)) ; //加上年引起的偏移日数
    n +=int2(30.6*(m+1))+this.D; //加上月引起的偏移日数及日偏移数
    n +=((this.s/60+this.m)/60+this.h)/24 - 1524.5;
    if(UTC) return n+this.deltatT2(n-J2000);
    return n;
},
setFromJD:function(jd,UTC){ //儒略日数转公历,UTC=1表示目标公历是UTC
    if(UTC) jd-=this.deltatT2(jd-J2000);
    jd+=0.5;
    var A=int2(jd), F=jd-A, D; //取得日数的整数部份A及小数部分F
    if(A>2299161) D=int2((A-1867216.25)/36524.25),A+=1+D-int2(D/4);
    A +=1524; //向前移4年零2个月
    this.Y =int2((A-122.1)/365.25);//年
    D =A-int2(365.25*this.Y); //去除整年日数后余下日数
    this.M =int2(D/30.6001); //月数
    this.D =D-int2(this.M*30.6001);//去除整月日数后余下日数
    this.Y-=4716; this.M--;
    if(this.M>12) this.M-=12;
    if(this.M<=2) this.Y++;
    //日的小数转为时分秒
    F*=24; this.h=int2(F); F-=this.h;
    F*=60; this.m=int2(F); F-=this.m;
    F*=60; this.s=F;
},
setFromStr:function(s){ //设置时间,参数例:"20000101 120000"或"20000101"
    this.Y=s.substr(0,4)-0; this.M=s.substr(4, 2)-0; this.D=s.substr(6, 2)-0;
    this.h=s.substr(9,2)-0; this.m=s.substr(11,2)-0; this.s=s.substr(13,5)-0;
},
toStr:function(){ //日期转为串
    var Y=" "+this.Y,M="0"+this.M, D="0"+this.D;
    var h=this.h,m=this.m,s=Math.floor(this.s+.5);
    if(s>=60) s-=60,m++;
    if(m>=60) m-=60,h++;
    h="0"+h; m="0"+m; s="0"+s;
    Y=Y.substr(Y.length-5,5); M=M.substr(M.length-2,2); D=D.substr(D.length-2,2);
    h=h.substr(h.length-2,2); m=m.substr(m.length-2,2); s=s.substr(s.length-2,2);
    return Y+"-"+M+"-"+D+" "+h+":"+m+":"+s;
},
Dint_dec:function(jd,shiqu,int_dec){ //算出:jd转到当地UTC后,UTC日数的整数部分或小数部分
    //基于J2000力学时jd的起算点是12:00:00时,所以跳日时刻发生在12:00:00,这与日历计算发生矛盾
    //把jd改正为00:00:00起算,这样儒略日的跳日动作就与日期的跳日同步
    //改正方法为jd=jd+0.5-deltatT+shiqu/24
    //把儒略日的起点移动-0.5(即前移12小时)
    //式中shiqu是时区,北京的起算点是-8小时,shiqu取8
    var u=jd+0.5-this.deltatT2(jd)+shiqu/24;
    if(int_dec) return Math.floor(u); //返回整数部分
    else return u-Math.floor(u); //返回小数部分
},
d1_d2:function(d1,d2){ //计算两个日期的相差的天数,输入字串格式日期,如:"20080101"
    var Y=this.Y,M=this.M,D=this.D,h=this.h,m=this.m,s=this.s; //备份原来的数据
    this.setFromStr(d1.substr(0,8)+" 120000"); var jd1=this.toJD(0);
    this.setFromStr(d2.substr(0,8)+" 120000"); var jd2=this.toJD(0);
  	 
    this.Y=Y,this.M=M,this.D=D,this.h=h,this.m=m,this.s=s; //还原
    if(jd1>jd2) return Math.floor(jd1-jd2+.0001);
    else return -Math.floor(jd2-jd1+.0001);
}
};
//=========黄赤交角及黄赤坐标变换===========
var hcjjB =new Array(84381.448, -46.8150, -0.00059, 0.001813);//黄赤交角系数表
var preceB=new Array(0,50287.92262,111.24406,0.07699,-0.23479,-0.00178,0.00018,0.00001);//Date黄道上的岁差p

function hcjj1 (t){ //返回黄赤交角(常规精度),短期精度很高
    var t1=t/36525, t2=t1*t1, t3=t2*t1;
    return (hcjjB[0] +hcjjB[1]*t1 +hcjjB[2]*t2 +hcjjB[3]*t3)/rad;
}
function HCconv(JW,E){ //黄赤转换(黄赤坐标旋转)
    //黄道赤道坐标变换,赤到黄E取负
    var HJ=rad2mrad(JW[0]), HW=JW[1];
    var sinE =Math.sin(E),cosE =Math.cos(E);
    var sinW=cosE*Math.sin(HW)+sinE*Math.cos(HW)*Math.sin(HJ);
    var J=Math.atan2( Math.sin(HJ)*cosE-Math.tan(HW)*sinE, Math.cos(HJ) );
    JW[0]=rad2mrad(J);
    JW[1]=Math.asin(sinW);
}
function addPrece(jd,zb){ //补岁差
    var i,t=1,v=0, t1=jd/365250;
    for(i=1;i<8;i++) t*=t1, v+=preceB[i]*t;
    zb[0]=rad2mrad(zb[0]+(v+2.9965*t1)/rad);
}
//===============光行差==================
var GXC_e=new Array(0.016708634, -0.000042037,-0.0000001267); //离心率
var GXC_p=new Array(102.93735/RAD,1.71946/RAD, 0.00046/RAD); //近点
var GXC_l=new Array(280.4664567/RAD,36000.76982779/RAD,0.0003032028/RAD,1/49931000/RAD,-1/153000000/RAD); //太平黄经
var GXC_k=20.49552/rad; //光行差常数
function addGxc(t,zb){//恒星周年光行差计算(黄道坐标中)
    var t1=t/36525, t2=t1*t1, t3=t2*t1,t4=t3*t1;
    var L=GXC_l[0] +GXC_l[1]*t1 +GXC_l[2]*t2 +GXC_l[3]*t3 +GXC_l[4]*t4;
    var p=GXC_p[0] +GXC_p[1]*t1 +GXC_p[2]*t2;
    var e=GXC_e[0] +GXC_e[1]*t1 +GXC_e[2]*t2;
    var dL=L-zb[0], dP=p-zb[0];
    zb[0]-=GXC_k * (Math.cos(dL)-e*Math.cos(dP)) / Math.cos(zb[1]);
    zb[1]-=GXC_k * Math.sin(zb[1]) * (Math.sin(dL)-e*Math.sin(dP));
    zb[0]=rad2mrad(zb[0]);
}

//===============章动计算==================
var nutB=new Array(//章动表
                   2.1824391966, -33.757045954, 0.0000362262, 3.7340E-08,-2.8793E-10,-171996,-1742,92025, 89,
                   3.5069406862, 1256.663930738, 0.0000105845, 6.9813E-10,-2.2815E-10, -13187, -16, 5736,-31,
                   1.3375032491, 16799.418221925,-0.0000511866, 6.4626E-08,-5.3543E-10, -2274, -2, 977, -5,
                   4.3648783932, -67.514091907, 0.0000724525, 7.4681E-08,-5.7586E-10, 2062, 2, -895, 5,
                   0.0431251803, -628.301955171, 0.0000026820, 6.5935E-10, 5.5705E-11, -1426, 34, 54, -1,
                   2.3555557435, 8328.691425719, 0.0001545547, 2.5033E-07,-1.1863E-09, 712, 1, -7, 0,
                   3.4638155059, 1884.965885909, 0.0000079025, 3.8785E-11,-2.8386E-10, -517, 12, 224, -6,
                   5.4382493597, 16833.175267879,-0.0000874129, 2.7285E-08,-2.4750E-10, -386, -4, 200, 0,
                   3.6930589926, 25128.109647645, 0.0001033681, 3.1496E-07,-1.7218E-09, -301, 0, 129, -1,
                   3.5500658664, 628.361975567, 0.0000132664, 1.3575E-09,-1.7245E-10, 217, -5, -95, 3);
function nutation(t){ //计算黄经章动及交角章动
    var d=new Array();
    d.Lon=0; d.Obl=0; t/=36525;
    var i,c,t1=t, t2=t1*t1, t3=t2*t1, t4=t3*t1, t5=t4*t1;
    for(i=0;i<nutB.length;i+=9){
        c=nutB[i] +nutB[i+1]*t1 +nutB[i+2]*t2 +nutB[i+3]*t3 +nutB[i+4]*t4;
        d.Lon+=(nutB[i+5]+nutB[i+6]*t/10)*Math.sin(c); //黄经章动
        d.Obl+=(nutB[i+7]+nutB[i+8]*t/10)*Math.cos(c); //交角章动
    }
    d.Lon/=rad*10000; //黄经章动
    d.Obl/=rad*10000; //交角章动
    return d;
}
function nutationRaDec(t,zb){ //本函数计算赤经章动及赤纬章动
    var Ra=zb[0],Dec=zb[1];
    var E=hcjj1(t), sinE=Math.sin(E), cosE=Math.cos(E); //计算黄赤交角
    var d=nutation(t); //计算黄经章动及交角章动
    var cosRa=Math.cos(Ra), sinRa=Math.sin(Ra);
    var tanDec=Math.tan(Dec);
    zb[0]+=(cosE+sinE*sinRa*tanDec)*d.Lon-cosRa*tanDec*d.Obl; //赤经章动
    zb[1]+= sinE*cosRa*d.Lon+sinRa*d.Obl; //赤纬章动
    zb[0]=rad2mrad(zb[0]);
}
*/
//=================以下是月球及地球运动参数表===================
/***************************************
 * 如果用记事本查看此代码,请在"格式"菜单中去除"自动换行"
 * E10是关于地球的,格式如下:
 * 它是一个数组,每3个数看作一条记录,每条记录的3个数记为A,B,C
 * rec=A*cos(B+C*t); 式中t是J2000起算的儒略千年数
 * 每条记录的计算结果(即rec)取和即得地球的日心黄经的周期量L0
 * E11格式如下: rec = A*cos*(B+C*t) *t, 取和后得泊松量L1
 * E12格式如下: rec = A*cos*(B+C*t) *t*t, 取和后得泊松量L2
 * E13格式如下: rec = A*cos*(B+C*t) *t*t*t, 取和后得泊松量L3
 * 最后地球的地心黄经:L = L0+L1+L2+L3+...
 * E20,E21,E22,E23...用于计算黄纬
 * M10,M11等是关于月球的,参数的用法请阅读Mnn()函数
 *****************************************/
//地球运动VSOP87参数
/*
var E10=new Array( //黄经周期项
                  1.75347045673, 0.00000000000, 0.0000000000, 0.03341656456, 4.66925680417, 6283.0758499914, 0.00034894275, 4.62610241759, 12566.1516999828, 0.00003417571, 2.82886579606, 3.5231183490,
                  0.00003497056, 2.74411800971, 5753.3848848968, 0.00003135896, 3.62767041758, 77713.7714681205, 0.00002676218, 4.41808351397, 7860.4193924392, 0.00002342687, 6.13516237631, 3930.2096962196,
                  0.00001273166, 2.03709655772, 529.6909650946, 0.00001324292, 0.74246356352, 11506.7697697936, 0.00000901855, 2.04505443513, 26.2983197998, 0.00001199167, 1.10962944315, 1577.3435424478,
                  0.00000857223, 3.50849156957, 398.1490034082, 0.00000779786, 1.17882652114, 5223.6939198022, 0.00000990250, 5.23268129594, 5884.9268465832, 0.00000753141, 2.53339053818, 5507.5532386674,
                  0.00000505264, 4.58292563052, 18849.2275499742, 0.00000492379, 4.20506639861, 775.5226113240, 0.00000356655, 2.91954116867, 0.0673103028, 0.00000284125, 1.89869034186, 796.2980068164,
                  0.00000242810, 0.34481140906, 5486.7778431750, 0.00000317087, 5.84901952218, 11790.6290886588, 0.00000271039, 0.31488607649, 10977.0788046990, 0.00000206160, 4.80646606059, 2544.3144198834,
                  0.00000205385, 1.86947813692, 5573.1428014331, 0.00000202261, 2.45767795458, 6069.7767545534, 0.00000126184, 1.08302630210, 20.7753954924, 0.00000155516, 0.83306073807, 213.2990954380,
                  0.00000115132, 0.64544911683, 0.9803210682, 0.00000102851, 0.63599846727, 4694.0029547076, 0.00000101724, 4.26679821365, 7.1135470008, 0.00000099206, 6.20992940258, 2146.1654164752,
                  0.00000132212, 3.41118275555, 2942.4634232916, 0.00000097607, 0.68101272270, 155.4203994342, 0.00000085128, 1.29870743025, 6275.9623029906, 0.00000074651, 1.75508916159, 5088.6288397668,
                  0.00000101895, 0.97569221824, 15720.8387848784, 0.00000084711, 3.67080093025, 71430.6956181291, 0.00000073547, 4.67926565481, 801.8209311238, 0.00000073874, 3.50319443167, 3154.6870848956,
                  0.00000078756, 3.03698313141, 12036.4607348882, 0.00000079637, 1.80791330700, 17260.1546546904, 0.00000085803, 5.98322631256,161000.6857376741, 0.00000056963, 2.78430398043, 6286.5989683404,
                  0.00000061148, 1.81839811024, 7084.8967811152, 0.00000069627, 0.83297596966, 9437.7629348870, 0.00000056116, 4.38694880779, 14143.4952424306, 0.00000062449, 3.97763880587, 8827.3902698748,
                  0.00000051145, 0.28306864501, 5856.4776591154, 0.00000055577, 3.47006009062, 6279.5527316424, 0.00000041036, 5.36817351402, 8429.2412664666, 0.00000051605, 1.33282746983, 1748.0164130670,
                  0.00000051992, 0.18914945834, 12139.5535091068, 0.00000049000, 0.48735065033, 1194.4470102246, 0.00000039200, 6.16832995016, 10447.3878396044, 0.00000035566, 1.77597314691, 6812.7668150860,
                  0.00000036770, 6.04133859347, 10213.2855462110, 0.00000036596, 2.56955238628, 1059.3819301892, 0.00000033291, 0.59309499459, 17789.8456197850, 0.00000035954, 1.70876111898, 2352.8661537718);
var E11=new Array( //黄经泊松1项
                  6283.31966747491,0.00000000000, 0.0000000000, 0.00206058863, 2.67823455584, 6283.0758499914, 0.00004303430, 2.63512650414, 12566.1516999828, 0.00000425264, 1.59046980729, 3.5231183490,
                  0.00000108977, 2.96618001993, 1577.3435424478, 0.00000093478, 2.59212835365, 18849.2275499742, 0.00000119261, 5.79557487799, 26.2983197998, 0.00000072122, 1.13846158196, 529.6909650946,
                  0.00000067768, 1.87472304791, 398.1490034082, 0.00000067327, 4.40918235168, 5507.5532386674, 0.00000059027, 2.88797038460, 5223.6939198022, 0.00000055976, 2.17471680261, 155.4203994342,
                  0.00000045407, 0.39803079805, 796.2980068164, 0.00000036369, 0.46624739835, 775.5226113240, 0.00000028958, 2.64707383882, 7.1135470008, 0.00000019097, 1.84628332577, 5486.7778431750,
                  0.00000020844, 5.34138275149, 0.9803210682, 0.00000018508, 4.96855124577, 213.2990954380, 0.00000016233, 0.03216483047, 2544.3144198834, 0.00000017293, 2.99116864949, 6275.9623029906);
var E12=new Array( //黄经泊松2项
                  0.00052918870, 0.00000000000, 0.0000000000, 0.00008719837, 1.07209665242, 6283.0758499914, 0.00000309125, 0.86728818832, 12566.1516999828, 0.00000027339, 0.05297871691, 3.5231183490,
                  0.00000016334, 5.18826691036, 26.2983197998, 0.00000015752, 3.68457889430, 155.4203994342, 0.00000009541, 0.75742297675, 18849.2275499742, 0.00000008937, 2.05705419118, 77713.7714681205,
                  0.00000006952, 0.82673305410, 775.5226113240, 0.00000005064, 4.66284525271, 1577.3435424478);
var E13=new Array( 0.00000289226, 5.84384198723, 6283.0758499914, 0.00000034955, 0.00000000000, 0.0000000000, 0.00000016819, 5.48766912348, 12566.1516999828);
var E14=new Array( 0.00000114084, 3.14159265359, 0.0000000000, 0.00000007717, 4.13446589358, 6283.0758499914, 0.00000000765, 3.83803776214, 12566.1516999828);
var E15=new Array( 0.00000000878, 3.14159265359, 0.0000000000 );
var E20=new Array( //黄纬周期项
                  0.00000279620, 3.19870156017, 84334.6615813083, 0.00000101643, 5.42248619256, 5507.5532386674, 0.00000080445, 3.88013204458, 5223.6939198022, 0.00000043806, 3.70444689758, 2352.8661537718,
                  0.00000031933, 4.00026369781, 1577.3435424478, 0.00000022724, 3.98473831560, 1047.7473117547, 0.00000016392, 3.56456119782, 5856.4776591154, 0.00000018141, 4.98367470263, 6283.0758499914,
                  0.00000014443, 3.70275614914, 9437.7629348870, 0.00000014304, 3.41117857525, 10213.2855462110);
var E21=new Array( 0.00000009030, 3.89729061890, 5507.5532386674, 0.00000006177, 1.73038850355, 5223.6939198022);
var E30=new Array( //距离周期项
                  1.00013988799, 0.00000000000, 0.0000000000, 0.01670699626, 3.09846350771, 6283.0758499914, 0.00013956023, 3.05524609620, 12566.1516999828, 0.00003083720, 5.19846674381, 77713.7714681205,
                  0.00001628461, 1.17387749012, 5753.3848848968, 0.00001575568, 2.84685245825, 7860.4193924392, 0.00000924799, 5.45292234084, 11506.7697697936, 0.00000542444, 4.56409149777, 3930.2096962196);
var E31=new Array( 0.00103018608, 1.10748969588, 6283.0758499914, 0.00001721238, 1.06442301418, 12566.1516999828, 0.00000702215, 3.14159265359, 0.0000000000);
var E32=new Array( 0.00004359385, 5.78455133738, 6283.0758499914 );
var E33=new Array( 0.00000144595, 4.27319435148, 6283.0758499914 );
//月球运动参数
var M10=new Array(
                  22639.5858800, 2.3555545723, 8328.6914247251, 1.5231275E-04, 2.5041111E-07,-1.1863391E-09, 4586.4383203, 8.0413790709, 7214.0628654588,-2.1850087E-04,-1.8646419E-07, 8.7760973E-10, 2369.9139357, 10.3969336431, 15542.7542901840,-6.6188121E-05, 6.3946925E-08,-3.0872935E-10, 769.0257187, 4.7111091445, 16657.3828494503, 3.0462550E-04, 5.0082223E-07,-2.3726782E-09,
                  -666.4175399, -0.0431256817, 628.3019552485,-2.6638815E-06, 6.1639211E-10,-5.4439728E-11, -411.5957339, 3.2558104895, 16866.9323152810,-1.2804259E-04,-9.8998954E-09, 4.0433461E-11, 211.6555524, 5.6858244986, -1114.6285592663,-3.7081362E-04,-4.3687530E-07, 2.0639488E-09, 205.4359530, 8.0845047526, 6585.7609102104,-2.1583699E-04,-1.8708058E-07, 9.3204945E-10,
                  191.9561973, 12.7524882154, 23871.4457149091, 8.6124629E-05, 3.1435804E-07,-1.4950684E-09, 164.7286185, 10.4400593249, 14914.4523349355,-6.3524240E-05, 6.3330532E-08,-2.5428962E-10, -147.3213842, -2.3986802540, -7700.3894694766,-1.5497663E-04,-2.4979472E-07, 1.1318993E-09, -124.9881185, 5.1984668216, 7771.3771450920,-3.3094061E-05, 3.1973462E-08,-1.5436468E-10,
                  -109.3803637, 2.3124288905, 8956.9933799736, 1.4964887E-04, 2.5102751E-07,-1.2407788E-09, 55.1770578, 7.1411231536, -1324.1780250970, 6.1854469E-05, 7.3846820E-08,-3.4916281E-10, -45.0996092, 5.6113650618, 25195.6237400061, 2.4270161E-05, 2.4051122E-07,-1.1459056E-09, 39.5333010, -0.9002559173, -8538.2408905558, 2.8035534E-04, 2.6031101E-07,-1.2267725E-09,
                  38.4298346, 18.4383127140, 22756.8171556428,-2.8468899E-04,-1.2251727E-07, 5.6888037E-10, 36.1238141, 7.0666637168, 24986.0742741754, 4.5693825E-04, 7.5123334E-07,-3.5590172E-09, 30.7725751, 16.0827581417, 14428.1257309177,-4.3700174E-04,-3.7292838E-07, 1.7552195E-09, -28.3971008, 7.9982533891, 7842.3648207073,-2.2116475E-04,-1.8584780E-07, 8.2317000E-10,
                  -24.3582283, 10.3538079614, 16171.0562454324,-6.8852003E-05, 6.4563317E-08,-3.6316908E-10, -18.5847068, 2.8429122493, -557.3142796331,-1.8540681E-04,-2.1843765E-07, 1.0319744E-09, 17.9544674, 5.1553411398, 8399.6791003405,-3.5757942E-05, 3.2589854E-08,-2.0880440E-10, 14.5302779, 12.7956138971, 23243.1437596606, 8.8788511E-05, 3.1374165E-07,-1.4406287E-09,
                  14.3796974, 15.1080427876, 32200.1371396342, 2.3843738E-04, 5.6476915E-07,-2.6814075E-09, 14.2514576,-24.0810366320, -2.3011998397, 1.5231275E-04, 2.5041111E-07,-1.1863391E-09, 13.8990596, 20.7938672862, 31085.5085803679,-1.3237624E-04, 1.2789385E-07,-6.1745870E-10, 13.1940636, 3.3302699264, -9443.3199839914,-5.2312637E-04,-6.8728642E-07, 3.2502879E-09,
                  -9.6790568, -4.7542348263,-16029.0808942018,-3.0728938E-04,-5.0020584E-07, 2.3182384E-09, -9.3658635, 11.2971895604, 24080.9951807398,-3.4654346E-04,-1.9636409E-07, 9.1804319E-10, 8.6055318, 5.7289501804, -1742.9305145148,-3.6814974E-04,-4.3749170E-07, 2.1183885E-09, -8.4530982, 7.5540213938, 16100.0685698171, 1.1921869E-04, 2.8238458E-07,-1.3407038E-09,
                  8.0501724, 10.4831850066, 14286.1503796870,-6.0860358E-05, 6.2714140E-08,-1.9984990E-10, -7.6301553, 4.6679834628, 17285.6848046987, 3.0196162E-04, 5.0143862E-07,-2.4271179E-09, -7.4474952, -0.0862513635, 1256.6039104970,-5.3277630E-06, 1.2327842E-09,-1.0887946E-10, 7.3712011, 8.1276304344, 5957.4589549619,-2.1317311E-04,-1.8769697E-07, 9.8648918E-10,
                  7.0629900, 0.9591375719, 33.7570471374,-3.0829302E-05,-3.6967043E-08, 1.7385419E-10, -6.3831491, 9.4966777258, 7004.5133996281, 2.1416722E-04, 3.2425793E-07,-1.5355019E-09, -5.7416071, 13.6527441326, 32409.6866054649,-1.9423071E-04, 5.4047029E-08,-2.6829589E-10, 4.3740095, 18.4814383957, 22128.5152003943,-2.8202511E-04,-1.2313366E-07, 6.2332010E-10,
                  -3.9976134, 7.9669196340, 33524.3151647312, 1.7658291E-04, 4.9092233E-07,-2.3322447E-09, -3.2096876, 13.2398458924, 14985.4400105508,-2.5159493E-04,-1.5449073E-07, 7.2324505E-10, -2.9145404, 12.7093625336, 24499.7476701576, 8.3460748E-05, 3.1497443E-07,-1.5495082E-09, 2.7318890, 16.1258838235, 13799.8237756692,-4.3433786E-04,-3.7354477E-07, 1.8096592E-09,
                  -2.5679459, -2.4418059357, -7072.0875142282,-1.5764051E-04,-2.4917833E-07, 1.0774596E-09, -2.5211990, 7.9551277074, 8470.6667759558,-2.2382863E-04,-1.8523141E-07, 7.6873027E-10, 2.4888871, 5.6426988169, -486.3266040178,-3.7347750E-04,-4.3625891E-07, 2.0095091E-09, 2.1460741, 7.1842488353, -1952.4799803455, 6.4518350E-05, 7.3230428E-08,-2.9472308E-10,
                  1.9777270, 23.1494218585, 39414.2000050930, 1.9936508E-05, 3.7830496E-07,-1.8037978E-09, 1.9336825, 9.4222182890, 33314.7656989005, 6.0925100E-04, 1.0016445E-06,-4.7453563E-09, 1.8707647, 20.8369929680, 30457.2066251194,-1.2971236E-04, 1.2727746E-07,-5.6301898E-10, -1.7529659, 0.4873576771, -8886.0057043583,-3.3771956E-04,-4.6884877E-07, 2.2183135E-09,
                  -1.4371624, 7.0979974718, -695.8760698485, 5.9190587E-05, 7.4463212E-08,-4.0360254E-10, -1.3725701, 1.4552986550, -209.5494658307, 4.3266809E-04, 5.1072212E-07,-2.4131116E-09, 1.2618162, 7.5108957121, 16728.3705250656, 1.1655481E-04, 2.8300097E-07,-1.3951435E-09);
var M11=new Array(
                  1.6768000, -0.0431256817, 628.3019552485,-2.6638815E-06, 6.1639211E-10,-5.4439728E-11, 0.5164200, 11.2260974062, 6585.7609102104,-2.1583699E-04,-1.8708058E-07, 9.3204945E-10, 0.4138300, 13.5816519784, 14914.4523349355,-6.3524240E-05, 6.3330532E-08,-2.5428962E-10, 0.3711500, 5.5402729076, 7700.3894694766, 1.5497663E-04, 2.4979472E-07,-1.1318993E-09,
                  0.2756000, 2.3124288905, 8956.9933799736, 1.4964887E-04, 2.5102751E-07,-1.2407788E-09, 0.2459863,-25.6198212459, -2.3011998397, 1.5231275E-04, 2.5041111E-07,-1.1863391E-09, 0.0711800, 7.9982533891, 7842.3648207073,-2.2116475E-04,-1.8584780E-07, 8.2317000E-10, 0.0612800, 10.3538079614, 16171.0562454324,-6.8852003E-05, 6.4563317E-08,-3.6316908E-10);
var M12=new Array( 0.0048700, -0.0431256817, 628.3019552485,-2.6638815E-06, 6.1639211E-10,-5.4439728E-11, 0.0022800,-27.1705318325, -2.3011998397, 1.5231275E-04, 2.5041111E-07,-1.1863391E-09, 0.0015000, 11.2260974062, 6585.7609102104,-2.1583699E-04,-1.8708058E-07, 9.3204945E-10);
var M20=new Array(
                  18461.2400600, 1.6279052448, 8433.4661576405,-6.4021295E-05,-4.9499477E-09, 2.0216731E-11, 1010.1671484, 3.9834598170, 16762.1575823656, 8.8291456E-05, 2.4546117E-07,-1.1661223E-09, 999.6936555, 0.7276493275, -104.7747329154, 2.1633405E-04, 2.5536106E-07,-1.2065558E-09, 623.6524746, 8.7690283983, 7109.2881325435,-2.1668263E-06, 6.8896872E-08,-3.2894608E-10,
                  199.4837596, 9.6692843156, 15647.5290230993,-2.8252217E-04,-1.9141414E-07, 8.9782646E-10, 166.5741153, 6.4134738261, -1219.4032921817,-1.5447958E-04,-1.8151424E-07, 8.5739300E-10, 117.2606951, 12.0248388879, 23976.2204478244,-1.3020942E-04, 5.8996977E-08,-2.8851262E-10, 61.9119504, 6.3390143893, 25090.8490070907, 2.4060421E-04, 4.9587228E-07,-2.3524614E-09,
                  33.3572027, 11.1245829706, 15437.9795572686, 1.5014592E-04, 3.1930799E-07,-1.5152852E-09, 31.7596709, 3.0832038997, 8223.9166918098, 3.6864680E-04, 5.0577218E-07,-2.3928949E-09, 29.5766003, 8.8121540801, 6480.9861772950, 4.9705523E-07, 6.8280480E-08,-2.7450635E-10, 15.5662654, 4.0579192538, -9548.0947169068,-3.0679233E-04,-4.3192536E-07, 2.0437321E-09,
                  15.1215543, 14.3803934601, 32304.9118725496, 2.2103334E-05, 3.0940809E-07,-1.4748517E-09, -12.0941511, 8.7259027166, 7737.5900877920,-4.8307078E-06, 6.9513264E-08,-3.8338581E-10, 8.8681426, 9.7124099974, 15019.2270678508,-2.7985829E-04,-1.9203053E-07, 9.5226618E-10, 8.0450400, 0.6687636586, 8399.7091105030,-3.3191993E-05, 3.2017096E-08,-1.5363746E-10,
                  7.9585542, 12.0679645696, 23347.9184925760,-1.2754553E-04, 5.8380585E-08,-2.3407289E-10, 7.4345550, 6.4565995078, -1847.7052474301,-1.5181570E-04,-1.8213063E-07, 9.1183272E-10, -6.7314363, -4.0265854988,-16133.8556271171,-9.0955337E-05,-2.4484477E-07, 1.1116826E-09, 6.5795750, 16.8104074692, 14323.3509980023,-2.2066770E-04,-1.1756732E-07, 5.4866364E-10,
                  -6.4600721, 1.5847795630, 9061.7681128890,-6.6685176E-05,-4.3335556E-09,-3.4222998E-11, -6.2964773, 4.8837157343, 25300.3984729215,-1.9206388E-04,-1.4849843E-08, 6.0650192E-11, -5.6323538, -0.7707750092, 733.0766881638,-2.1899793E-04,-2.5474467E-07, 1.1521161E-09, -5.3683961, 6.8263720663, 16204.8433027325,-9.7115356E-05, 2.7023515E-08,-1.3414795E-10,
                  -5.3112784, 3.9403341353, 17390.4595376141, 8.5627574E-05, 2.4607756E-07,-1.2205621E-09, -5.0759179, 0.6845236457, 523.5272223331, 2.1367016E-04, 2.5597745E-07,-1.2609955E-09, -4.8396143, -1.6710309265, -7805.1642023920, 6.1357413E-05, 5.5663398E-09,-7.4656459E-11, -4.8057401, 3.5705615768, -662.0890125485, 3.0927234E-05, 3.6923410E-08,-1.7458141E-10,
                  3.9840545, 8.6945689615, 33419.5404318159, 3.9291696E-04, 7.4628340E-07,-3.5388005E-09, 3.6744619, 19.1659620415, 22652.0424227274,-6.8354947E-05, 1.3284380E-07,-6.3767543E-10, 2.9984815, 20.0662179587, 31190.2833132833,-3.4871029E-04,-1.2746721E-07, 5.8909710E-10, 2.7986413, -2.5281611620,-16971.7070481963, 3.4437664E-04, 2.6526096E-07,-1.2469893E-09,
                  2.4138774, 17.7106633865, 22861.5918885581,-5.0102304E-04,-3.7787833E-07, 1.7754362E-09, 2.1863132, 5.5132179088, -9757.6441827375, 1.2587576E-04, 7.8796768E-08,-3.6937954E-10, 2.1461692, 13.4801375428, 23766.6709819937, 3.0245868E-04, 5.6971910E-07,-2.7016242E-09, 1.7659832, 11.1677086523, 14809.6776020201, 1.5280981E-04, 3.1869159E-07,-1.4608454E-09,
                  -1.6244212, 7.3137297434, 7318.8375983742,-4.3483492E-04,-4.4182525E-07, 2.0841655E-09, 1.5813036, 5.4387584720, 16552.6081165349, 5.2095955E-04, 7.5618329E-07,-3.5792340E-09, 1.5197528, 16.7359480324, 40633.6032972747, 1.7441609E-04, 5.5981921E-07,-2.6611908E-09, 1.5156341, 1.7023646816,-17876.7861416319,-4.5910508E-04,-6.8233647E-07, 3.2300712E-09,
                  1.5102092, 5.4977296450, 8399.6847301375,-3.3094061E-05, 3.1973462E-08,-1.5436468E-10, -1.3178223, 9.6261586339, 16275.8309783478,-2.8518605E-04,-1.9079775E-07, 8.4338673E-10, -1.2642739, 11.9817132061, 24604.5224030729,-1.3287330E-04, 5.9613369E-08,-3.4295235E-10, 1.1918723, 22.4217725310, 39518.9747380084,-1.9639754E-04, 1.2294390E-07,-5.9724197E-10,
                  1.1346110, 14.4235191419, 31676.6099173011, 2.4767216E-05, 3.0879170E-07,-1.4204120E-09, 1.0857810, 8.8552797618, 5852.6842220465, 3.1609367E-06, 6.7664088E-08,-2.2006663E-10, -1.0193852, 7.2392703065, 33629.0898976466,-3.9751134E-05, 2.3556127E-07,-1.1256889E-09, -0.8227141, 11.0814572888, 16066.2815125171, 1.4748204E-04, 3.1992438E-07,-1.5697249E-09,
                  0.8042238, 3.5274358950, -33.7870573000, 2.8263353E-05, 3.7539802E-08,-2.2902113E-10, 0.8025939, 6.7832463846, 16833.1452579809,-9.9779237E-05, 2.7639907E-08,-1.8858767E-10, -0.7931866, -6.3821400710,-24462.5470518423,-2.4326809E-04,-4.9525589E-07, 2.2980217E-09, -0.7910153, 6.3703481443, -591.1013369332,-1.5714346E-04,-1.8089785E-07, 8.0295327E-10,
                  -0.6674056, 9.1819266386, 24533.5347274576, 5.5197395E-05, 2.7743463E-07,-1.3204870E-09, 0.6502226, 4.1010449356,-10176.3966721553,-3.0412845E-04,-4.3254175E-07, 2.0981718E-09, -0.6388131, 6.2958887075, 25719.1509623392, 2.3794032E-04, 4.9648867E-07,-2.4069012E-09);
var M21=new Array(
                  0.0743000, 11.9537467337, 6480.9861772950, 4.9705523E-07, 6.8280480E-08,-2.7450635E-10, 0.0304300, 8.7259027166, 7737.5900877920,-4.8307078E-06, 6.9513264E-08,-3.8338581E-10, 0.0222900, 12.8540026510, 15019.2270678508,-2.7985829E-04,-1.9203053E-07, 9.5226618E-10, 0.0199900, 15.2095572232, 23347.9184925760,-1.2754553E-04, 5.8380585E-08,-2.3407289E-10,
                  0.0186900, 9.5981921614, -1847.7052474301,-1.5181570E-04,-1.8213063E-07, 9.1183272E-10, 0.0169600, 7.1681781524, 16133.8556271171, 9.0955337E-05, 2.4484477E-07,-1.1116826E-09, 0.0162300, 1.5847795630, 9061.7681128890,-6.6685176E-05,-4.3335556E-09,-3.4222998E-11, 0.0141900, -0.7707750092, 733.0766881638,-2.1899793E-04,-2.5474467E-07, 1.1521161E-09);
var M30=new Array(
                  385000.5290396, 1.5707963268, 0.0000000000, 0.0000000E+00, 0.0000000E+00, 0.0000000E+00,-20905.3551378, 3.9263508990, 8328.6914247251, 1.5231275E-04, 2.5041111E-07,-1.1863391E-09,-3699.1109330, 9.6121753977, 7214.0628654588,-2.1850087E-04,-1.8646419E-07, 8.7760973E-10,-2955.9675626, 11.9677299699, 15542.7542901840,-6.6188121E-05, 6.3946925E-08,-3.0872935E-10,
                  -569.9251264, 6.2819054713, 16657.3828494503, 3.0462550E-04, 5.0082223E-07,-2.3726782E-09, 246.1584797, 7.2566208254, -1114.6285592663,-3.7081362E-04,-4.3687530E-07, 2.0639488E-09, -204.5861179, 12.0108556517, 14914.4523349355,-6.3524240E-05, 6.3330532E-08,-2.5428962E-10, -170.7330791, 14.3232845422, 23871.4457149091, 8.6124629E-05, 3.1435804E-07,-1.4950684E-09,
                  -152.1378118, 9.6553010794, 6585.7609102104,-2.1583699E-04,-1.8708058E-07, 9.3204945E-10, -129.6202242, -0.8278839272, -7700.3894694766,-1.5497663E-04,-2.4979472E-07, 1.1318993E-09, 108.7427014, 6.7692631483, 7771.3771450920,-3.3094061E-05, 3.1973462E-08,-1.5436468E-10, 104.7552944, 3.8832252173, 8956.9933799736, 1.4964887E-04, 2.5102751E-07,-1.2407788E-09,
                  79.6605685, 0.6705404095, -8538.2408905558, 2.8035534E-04, 2.6031101E-07,-1.2267725E-09, 48.8883284, 1.5276706450, 628.3019552485,-2.6638815E-06, 6.1639211E-10,-5.4439728E-11, -34.7825237, 20.0091090408, 22756.8171556428,-2.8468899E-04,-1.2251727E-07, 5.6888037E-10, 30.8238599, 11.9246042882, 16171.0562454324,-6.8852003E-05, 6.4563317E-08,-3.6316908E-10,
                  24.2084985, 9.5690497159, 7842.3648207073,-2.2116475E-04,-1.8584780E-07, 8.2317000E-10, -23.2104305, 8.6374600436, 24986.0742741754, 4.5693825E-04, 7.5123334E-07,-3.5590172E-09, -21.6363439, 17.6535544685, 14428.1257309177,-4.3700174E-04,-3.7292838E-07, 1.7552195E-09, -16.6747239, 6.7261374666, 8399.6791003405,-3.5757942E-05, 3.2589854E-08,-2.0880440E-10,
                  14.4026890, 4.9010662531, -9443.3199839914,-5.2312637E-04,-6.8728642E-07, 3.2502879E-09, -12.8314035, 14.3664102239, 23243.1437596606, 8.8788511E-05, 3.1374165E-07,-1.4406287E-09, -11.6499478, 22.3646636130, 31085.5085803679,-1.3237624E-04, 1.2789385E-07,-6.1745870E-10, -10.4447578, 16.6788391144, 32200.1371396342, 2.3843738E-04, 5.6476915E-07,-2.6814075E-09,
                  10.3211071, 8.7119194804, -1324.1780250970, 6.1854469E-05, 7.3846820E-08,-3.4916281E-10, 10.0562033, 7.2997465071, -1742.9305145148,-3.6814974E-04,-4.3749170E-07, 2.1183885E-09, -9.8844667, 12.0539813334, 14286.1503796870,-6.0860358E-05, 6.2714140E-08,-1.9984990E-10, 8.7515625, 6.3563649081, -9652.8694498221,-9.0458282E-05,-1.7656429E-07, 8.3717626E-10,
                  -8.3791067, 4.4137085761, -557.3142796331,-1.8540681E-04,-2.1843765E-07, 1.0319744E-09, -7.0026961, -3.1834384995,-16029.0808942018,-3.0728938E-04,-5.0020584E-07, 2.3182384E-09, 6.3220032, 9.1248177206, 16100.0685698171, 1.1921869E-04, 2.8238458E-07,-1.3407038E-09, 5.7508579, 6.2387797896, 17285.6848046987, 3.0196162E-04, 5.0143862E-07,-2.4271179E-09,
                  -4.9501349, 9.6984267611, 5957.4589549619,-2.1317311E-04,-1.8769697E-07, 9.8648918E-10, -4.4211770, 3.0260949818, -209.5494658307, 4.3266809E-04, 5.1072212E-07,-2.4131116E-09, 4.1311145, 11.0674740526, 7004.5133996281, 2.1416722E-04, 3.2425793E-07,-1.5355019E-09, -3.9579827, 20.0522347225, 22128.5152003943,-2.8202511E-04,-1.2313366E-07, 6.2332010E-10,
                  3.2582371, 14.8106422192, 14985.4400105508,-2.5159493E-04,-1.5449073E-07, 7.2324505E-10, -3.1483020, 4.8266068163, 16866.9323152810,-1.2804259E-04,-9.8998954E-09, 4.0433461E-11, 2.6164092, 14.2801588604, 24499.7476701576, 8.3460748E-05, 3.1497443E-07,-1.5495082E-09, 2.3536310, 9.5259240342, 8470.6667759558,-2.2382863E-04,-1.8523141E-07, 7.6873027E-10,
                  -2.1171283, -0.8710096090, -7072.0875142282,-1.5764051E-04,-2.4917833E-07, 1.0774596E-09, -1.8970368, 17.6966801503, 13799.8237756692,-4.3433786E-04,-3.7354477E-07, 1.8096592E-09, -1.7385258, 2.0581540038, -8886.0057043583,-3.3771956E-04,-4.6884877E-07, 2.2183135E-09, -1.5713944, 22.4077892948, 30457.2066251194,-1.2971236E-04, 1.2727746E-07,-5.6301898E-10,
                  -1.4225541, 24.7202181853, 39414.2000050930, 1.9936508E-05, 3.7830496E-07,-1.8037978E-09, -1.4189284, 17.1661967915, 23314.1314352759,-9.9282182E-05, 9.5920387E-08,-4.6309403E-10, 1.1655364, 3.8400995356, 9585.2953352221, 1.4698499E-04, 2.5164390E-07,-1.2952185E-09, -1.1169371, 10.9930146158, 33314.7656989005, 6.0925100E-04, 1.0016445E-06,-4.7453563E-09,
                  1.0656723, 1.4845449633, 1256.6039104970,-5.3277630E-06, 1.2327842E-09,-1.0887946E-10, 1.0586190, 11.9220903668, 8364.7398411275,-2.1850087E-04,-1.8646419E-07, 8.7760973E-10, -0.9333176, 9.0816920389, 16728.3705250656, 1.1655481E-04, 2.8300097E-07,-1.3951435E-09, 0.8624328, 12.4550876470, 6656.7485858257,-4.0390768E-04,-4.0490184E-07, 1.9095841E-09,
                  0.8512404, 4.3705828944, 70.9876756153,-1.8807069E-04,-2.1782126E-07, 9.7753467E-10, -0.8488018, 16.7219647962, 31571.8351843857, 2.4110126E-04, 5.6415276E-07,-2.6269678E-09, -0.7956264, 3.5134526588, -9095.5551701890, 9.4948529E-05, 4.1873358E-08,-1.9479814E-10);
var M31=new Array(
                  0.5139500, 12.0108556517, 14914.4523349355,-6.3524240E-05, 6.3330532E-08,-2.5428962E-10, 0.3824500, 9.6553010794, 6585.7609102104,-2.1583699E-04,-1.8708058E-07, 9.3204945E-10, 0.3265400, 3.9694765808, 7700.3894694766, 1.5497663E-04, 2.4979472E-07,-1.1318993E-09, 0.2639600, 0.7416325637, 8956.9933799736, 1.4964887E-04, 2.5102751E-07,-1.2407788E-09,
                  0.1230200, -1.6139220085, 628.3019552485,-2.6638815E-06, 6.1639211E-10,-5.4439728E-11, 0.0775400, 8.7830116346, 16171.0562454324,-6.8852003E-05, 6.4563317E-08,-3.6316908E-10, 0.0606800, 6.4274570623, 7842.3648207073,-2.2116475E-04,-1.8584780E-07, 8.2317000E-10, 0.0497000, 12.0539813334, 14286.1503796870,-6.0860358E-05, 6.2714140E-08,-1.9984990E-10);
var M1n=new Array(3.81034392032, 8.39968473021E+03,-3.31919929753E-05, //月球平黄经系数
                  3.20170955005E-08,-1.53637455544E-10);

//==================日位置计算===================
var EnnT=0; //调用Enn前先设置EnnT时间变量
function Enn(F){ //计算E10,E11,E20等,即:某一组周期项或泊松项算出,计算前先设置EnnT时间
    var i,v=0;
    for(i=0;i<F.length;i+=3)
        v+=F[i]*Math.cos(F[i+1]+EnnT*F[i+2]);
    return v;
}
function earCal(jd){//返回地球位置,日心Date黄道分点坐标
    EnnT=jd/365250;
    var llr=new Array();
    var t1=EnnT, t2=t1*t1, t3=t2*t1, t4=t3*t1, t5=t4*t1;
    llr[0] =Enn(E10) +Enn(E11)*t1 +Enn(E12)*t2 +Enn(E13)*t3 +Enn(E14)*t4 +Enn(E15)*t5;
    llr[1] =Enn(E20) +Enn(E21)*t1;
    llr[2] =Enn(E30) +Enn(E31)*t1 +Enn(E32)*t2 +Enn(E33)*t3;
    llr[0]=rad2mrad(llr[0]);
    return llr;
}
function sunCal2(jd){ //传回jd时刻太阳的地心视黄经及黄纬
    var sun=earCal(jd); sun[0]+=Math.PI; sun[1]=-sun[1]; //计算太阳真位置
    var d=nutation(jd); sun[0]=rad2mrad(sun[0]+d.Lon); //补章动
    addGxc(jd,sun); //补周年黄经光行差
    return sun; //返回太阳视位置
}

//==================月位置计算===================
var MnnT=0; //调用Mnn前先设置MnnT时间变量
function Mnn(F){ //计算M10,M11,M20等,计算前先设置MnnT时间
    var i,v=0, t1=MnnT, t2=t1*t1, t3=t2*t1, t4=t3*t1;
    for(i=0;i<F.length;i+=6)
        v+=F[i]*Math.sin(F[i+1] +t1*F[i+2] +t2*F[i+3] +t3*F[i+4] +t4*F[i+5]);
    return v;
}
function moonCal(jd){//返回月球位置,返回地心Date黄道坐标
    MnnT=jd/36525;
    var t1=MnnT, t2=t1*t1, t3=t2*t1, t4=t3*t1;
    var llr=new Array();
    llr[0] =(Mnn(M10) +Mnn(M11)*t1 +Mnn(M12)*t2)/rad;
    llr[1] =(Mnn(M20) +Mnn(M21)*t1)/rad;
    llr[2] =(Mnn(M30) +Mnn(M31)*t1)*0.999999949827;
    llr[0] =llr[0] +M1n[0] +M1n[1]*t1 +M1n[2]*t2 +M1n[3]*t3 +M1n[4]*t4;
    llr[0] =rad2mrad(llr[0]); //地心Date黄道原点坐标(不含岁差)
    addPrece(jd,llr); //补岁差
    return llr;
}
function moonCal2(jd){ //传回月球的地心视黄经及视黄纬
    var moon=moonCal(jd);
    var d=nutation(jd);
    moon[0]=rad2mrad(moon[0]+d.Lon); //补章动
    return moon;
}
function moonCal3(jd){ //传回月球的地心视赤经及视赤纬
    var moon=moonCal(jd);
    HCconv(moon,hcjj1(jd));
    nutationRaDec(jd,moon); //补赤经及赤纬章动
    //如果黄赤转换前补了黄经章动及交章动,就不能再补赤经赤纬章动
    return moon;
}

//==================地心坐标中的日月位置计算===================
function jiaoCai(lx,t,jiao){
    //lx=1时计算t时刻日月角距与jiao的差, lx=0计算t时刻太阳黄经与jiao的差
    var sun=earCal(t); //计算太阳真位置(先算出日心坐标中地球的位置)
    sun[0]+=Math.PI; sun[1]=-sun[1]; //转为地心坐标
    addGxc(t,sun); //补周年光行差
    if(lx==0){
        var d=nutation(t); sun[0]+=d.Lon; //补黄经章动
        return rad2mrad(jiao-sun[0]);
    }
    var moon=moonCal(t); //日月角差与章动无关
    return rad2mrad(jiao-(moon[0]-sun[0]));
}

//==================已知位置反求时间===================
function jiaoCal(t1,jiao,lx){ //t1是J2000起算儒略日数
    //已知角度(jiao)求时间(t)
    //lx=0是太阳黄经达某角度的时刻计算(用于节气计算)
    //lx=1是日月角距达某角度的时刻计算(用于定朔望等)
    //传入的t1是指定角度对应真时刻t的前一些天
    //对于节气计算,应满足t在t1到t1+360天之间,对于Y年第n个节气(n=0是春分),t1可取值Y*365.2422+n*15.2
    //对于朔望计算,应满足t在t1到t1+25天之间,在此范围之外,求右边的根
    var t2=t1, t=0,v;
    if(lx==0) t2+=360; //在t1到t2范围内求解(范气360天范围),结果置于t
    else t2+=25;
    jiao*=Math.PI/180; //待搜索目标角
    //利用截弦法计算
    var v1=jiaoCai(lx,t1,jiao); //v1,v2为t1,t2时对应的黄经
    var v2=jiaoCai(lx,t2,jiao);
    if(v1<v2) v2-=2*Math.PI; //减2pi作用是将周期性角度转为连续角度
    var k=1,k2,i; //k是截弦的斜率
    for(i=0;i<10;i++){ //快速截弦求根,通常截弦三四次就已达所需精度
        k2=(v2-v1)/(t2-t1); //算出斜率
        if(Math.abs(k2)>1e-15) k=k2; //差商可能为零,应排除
        t=t1-v1/k; v=jiaoCai(lx,t,jiao);//直线逼近法求根(直线方程的根)
        if(v>1) v-=2*Math.PI; //一次逼近后,v1就已接近0,如果很大,则应减1周
        if(Math.abs(v)<1e-8) break; //已达精度
        t1=t2,v1=v2; t2=t,v2=v; //下一次截弦
    }
    return t;
}

//==================节气计算===================
var jqB=new Array( //节气表
                  "春分","清明","谷雨","立夏","小满","芒种","夏至","小暑","大暑","立秋","处暑","白露",
                  "秋分","寒露","霜降","立冬","小雪","大雪","冬至","小寒","大寒","立春","雨水","惊蛰");

function JQtest(y){ //节气使计算范例,y是年分,这是个测试函数
    var i,jd=365.2422*(y-2000),q,s1,s2;
    document.write("节气:世界时 原子时<br>");
    for(i=0;i<24;i++){
        q=jiaoCal(jd+i*15.2,i*15,0)+J2000+8/24; //计算第i个节气(i=0是春风),结果转为北京时
        JDate.setFromJD(q,1); s1=JDate.toStr(); //将儒略日转成世界时
        JDate.setFromJD(q,0); s2=JDate.toStr(); //将儒略日转成日期格式(输出日期形式的力学时)
        document.write(jqB[i]+" : "+s1+" "+s2+"<br>"); //显示
    }
}
//=================定朔弦望计算========================
function dingSuo(y,arc){ //这是个测试函数
    var i,jd=365.2422*(y-2000),q,s1,s2;
    document.write("月份:世界时 原子时<br>");
    for(i=0;i<12;i++){
        q=jiaoCal(jd+29.5*i,arc,1)+J2000+8/24; //计算第i个节气(i=0是春风),结果转为北京时
        JDate.setFromJD(q,1); s1=JDate.toStr(); //将儒略日转成世界时
        JDate.setFromJD(q,0); s2=JDate.toStr(); //将儒略日转成日期格式(输出日期形式的力学时)
        document.write((i+1)+"月 : "+s1+" "+s2+"<br>"); //显示
    }
}
*/
//=================农历计算========================
/*****
 1.冬至所在的UTC日期保存在A[0],根据"规定1"得知在A[0]之前(含A[0])的那个UTC朔日定为年首日期
 冬至之后的中气分保存在A[1],A[2],A[3]...A[13],其中A[12]又回到了冬至,共计算13次中气
 2.连续计算冬至后14个朔日,即起算时间时A[0]+1
 14个朔日编号为0,1...12,保存在C[0],C[1]...C[13]
 这14个朔日表示编号为0月,1月,...12月0月的各月终止日期,但要注意实际终止日是新月初一,不属本月
 这14个朔日同样表示编号为1月,2月...的开始日期
 设某月编号为n,那么开始日期为C[n-1],结束日期为C[n],如果每月都含中气,该月所含的中气为A[n]
 注:为了全总计算出13个月的大小月情况,须算出14个朔日。
 3.闰年判断:含有13个月的年份是闰年
 当第13月(月编号12月)终止日期大于冬至日, 即C[12]〉A[12], 那么该月是新年,本年没月12月,本年共12个月
 当第13月(月编号12月)终止日期小等于冬至日,即C[12]≤A[12],那么该月是本年的有效月份,本年共13个月
 4.闰年中处理闰月:
 13个月中至少1个月份无中气,首个无中气的月置闰,在n=1...12月中找到闰月,即C[n]≤A[n]
 从农历年首的定义知道,0月一定含有中气冬至,所以不可能是闰月。
 首月有时很贪心,除冬至外还可能再吃掉本年或前年的另一个中气
 定出闰月后,该月及以后的月编号减1
 5.以上所述的月编号不是日常生活中说的"正月","二月"等月名称:
 如果"建子",0月为首月,如果"建寅",2月的月名"正月",3月是"二月",其余类推
 *****/
/*
var yueMing=new Array("正","二","三","四","五","六","七","八","九","十","11","12");
function paiYue(){ //农历排月序计算,可定出农历
    y=in1.value-0;
    var zq=new Array(),jq=new Array(), hs=new Array(); //中气表,节气表,日月合朔表
  	 
    //从冬至开始,连续计算14个中气时刻
    var i,t1=365.2422*(y-2000)-50; //农历年首始于前一年的冬至,为了节气中气一起算,取前年大雪之前
    for(i=0;i<14;i++){ //计算节气(从冬至开始),注意:返回的是力学时
        zq[i]=jiaoCal(t1+i*30.4,i*30-90, 0); //中气计算,冬至的太阳黄经是270度(或-90度)
        jq[i]=jiaoCal(t1+i*30.4,i*30-105,0); //顺便计算节气,它不是农历定朔计算所必需的
    }
    //在冬至过后,连续计算14个日月合朔时刻
    var dongZhiJia1 = zq[0]+1-JDate.Dint_dec(zq[0],8,0); //冬至过后的第一天0点的儒略日数
    hs[0]=jiaoCal(dongZhiJia1,0,1); //首月结束的日月合朔时刻
    for(i=1;i<14;i++) hs[i]=jiaoCal(hs[i-1]+25,0,1);
    //算出中气及合朔时刻的日数(不含小数的日数计数,以便计算日期之间的差值)
    var A=new Array(), B=new Array(), C=new Array();
    for(i=0;i<14;i++){ //取当地UTC日数的整数部分
        A[i]=JDate.Dint_dec(zq[i],8,1);
        B[i]=JDate.Dint_dec(jq[i],8,1);
        C[i]=JDate.Dint_dec(hs[i],8,1);
    }
    //闰月及大小月分析
    var tot=12,nun=-1,yn=new Array(1,2,3,4,5,6,7,8,9,10,11,0,0); //月编号
    if( C[12]<=A[12] ){ //闰月分析
        yn[12]=12,tot=13; //编号为12的月是本年的有效月份,本年总月数13个
        for(i=1;i<13;i++) if( C[i]<=A[i] ) break;
        for(nun=i-1;i<13;i++) yn[i-1]--; //注意yn中不含农历首月(所以取i-1),在公历中农历首月总是去年的所以不多做计算
    }
    for(i=0;i<tot;i++){ //转为建寅月名,并做大小月分析
        yn[i]=yueMing[(yn[i]+10)%12]; //转建寅月名
        if(i==nun) yn[i]+="闰"; else yn[i]+="月"; //标记是否闰月
        if(C[i+1]-C[i]>29) yn[i]+="大"; else yn[i]+="小" //标记大小月
            }
    //显示
    var out="节气 手表时 中气 手表时 农历月 朔的手表时\r\n";
    for(i=0;i<tot;i++){
        var zm=(i*2+18)%24, jm=(i*2+17)%24; //中气名节气名
        JDate.setFromJD(jq[i]+J2000+8/24,1); out+=jqB[jm]+":"+JDate.toStr()+" "; //显示节气
        JDate.setFromJD(zq[i]+J2000+8/24,1); out+=jqB[zm]+":"+JDate.toStr()+" "; //显示中气
        JDate.setFromJD(hs[i]+J2000+8/24,1); out+=yn[i] +":"+JDate.toStr()+"\r\n"; //显示日月合朔
    }
    show1.innerText=out;
}
*/

@end
