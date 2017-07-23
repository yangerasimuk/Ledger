//
//  YGTools.m
//  Ledger
//
//  Created by Ян on 31/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGTools.h"
#import "YGConfig.h"
#import "YYGLedgerDefine.h"
#import <UIKit/UIKit.h>

#define kFileSizeAcronyms @[@"B", @"KB", @"MB", @"GB", @"TB"]

@implementation YGTools

#pragma mark - Date tools

+ (BOOL) isDayOfDate:(NSDate *)sourceDate equalsDayOfDate:(NSDate *)targetDate {
    
    NSDateComponents *dayOfSourceDate = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:sourceDate];
    
    NSDateComponents *dayOfTargetDate = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:targetDate];
    
    if([dayOfSourceDate day] == [dayOfTargetDate day] &&
       [dayOfSourceDate month] == [dayOfTargetDate month] &&
       [dayOfSourceDate year] == [dayOfTargetDate year] &&
       [dayOfSourceDate era] == [dayOfTargetDate era]) {
        
        return YES;
    }
    else
        return NO;
}

/**
 Problem: NSDate store only absolute time, without timezone.
 */
+ (NSDate *) dayOfDate:(NSDate *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateTimeFormatOnlyDay];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *stringDate = [formatter stringFromDate:date];
    
    NSDate *day = [formatter dateFromString:stringDate];
    
    return day;
}

+ (NSString *) humanViewOfDate:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"]];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    
    NSString *resultString = [formatter stringFromDate:date];
    
    return resultString;
}

+ (NSString *) humanViewWithTodayOfDate:(NSDate *)date {
    
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];

    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era]) {
        
        return @"Today";
    }
    else
        return [YGTools humanViewOfDate:date];
}


+ (NSString *)humanViewShortWithTodayOfDay:(NSDate *)day {
    
    NSString *resultDateString = nil;
    
    // get nsdate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateTimeFormat];
    
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    NSDateComponents *dayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay  | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:day];
    
    
    if([todayComponents day] == [dayComponents day] &&
       [todayComponents month] == [dayComponents month] &&
       [todayComponents year] == [dayComponents year] &&
       [todayComponents era] == [dayComponents era]) {
        
        resultDateString = @"Today";
    }
    else if(([todayComponents day] - [dayComponents day]) == 1 &&
            [todayComponents month] == [dayComponents month] &&
            [todayComponents year] == [dayComponents year] &&
            [todayComponents era] == [dayComponents era]) {
        
        resultDateString = @"Yesterday";
    }
    else{
        
        BOOL isSameYear = NO;
        
        if([todayComponents year] == [dayComponents year] &&
           [todayComponents era] == [dayComponents era]){
            isSameYear = YES;
        }
        
        
        NSDateFormatter *formatterLocale = [[NSDateFormatter alloc] init];
        [formatterLocale setLocale:[NSLocale currentLocale]];
        
        if(isSameYear){
            if([[[NSLocale currentLocale] localeIdentifier] hasPrefix:@"en"])
                [formatterLocale setDateFormat:@"MMMM d"];
            else
                [formatterLocale setDateFormat:@"d MMMM"];
        }
        else{
            [formatterLocale setDateStyle:NSDateFormatterLongStyle];
        }
        
        resultDateString = [formatterLocale stringFromDate:day];
        
    }
    
    return resultDateString;
}

/**
 Return given date string in human view.
 
 @param dateString String with date in format @"yyyy-MM-dd HH:mm:ss Z", for example: 2017-07-07 20:53:23 +0300.
 
 @return String with date in human view. For example: Today, 15:06; June 17, 11:11; January 17, 2017, 11:15.
 */
+ (NSString *)humanViewShortWithTodayOfDateString:(NSString *)dateString {
        
    NSString *resultDateString = nil;
    
    // 2017-07-07 20:53:23 +0300 -> 2017-07-07 20:53:23 +0000
    dateString = [dateString stringByReplacingCharactersInRange:NSMakeRange(20,5) withString:@"+0000"];

    // get nsdate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateTimeFormat];
    NSDate *date = [formatter dateFromString:dateString];
    
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    NSDateComponents *day = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay  | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];

    
    if([today day] == [day day] &&
       [today month] == [day month] &&
       [today year] == [day year] &&
       [today era] == [day era]) {
        
        resultDateString = @"Today";
    }
    else if(([today day] - [day day]) == 1 &&
            [today month] == [day month] &&
            [today year] == [day year] &&
            [today era] == [day era]) {
        
        resultDateString = @"Yesterday";
    }
    else{
        
        BOOL isSameYear = NO;
        
        if([today year] == [day year] &&
           [today era] == [day era]){
            isSameYear = YES;
        }
        
        NSDate *dateLong = [formatter dateFromString:dateString];
        
        NSDateFormatter *formatterLocale = [[NSDateFormatter alloc] init];
        [formatterLocale setLocale:[NSLocale currentLocale]];
        
        if(isSameYear){
            if([[[NSLocale currentLocale] localeIdentifier] hasPrefix:@"en"])
                [formatterLocale setDateFormat:@"MMMM d"];
            else
                [formatterLocale setDateFormat:@"d MMMM"];
        }
        else{
            [formatterLocale setDateStyle:NSDateFormatterLongStyle];
        }
        
        resultDateString = [formatterLocale stringFromDate:dateLong];
        
    }
    
    NSDateFormatter *formatterTime = [[NSDateFormatter alloc] init];
    [formatterTime setDateFormat:kDateTimeFormatOnlyTime];
    NSString *timeString = [formatterTime stringFromDate:date];

    return [NSString stringWithFormat:@"%@, %@", resultDateString, timeString];
}

+ (NSString *)stringFromDate:(NSDate *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:kDateTimeFormat];
    
    return [formatter stringFromDate:date];
}

+ (NSString *)stringWithCurrentTimeZoneFromDate:(NSDate *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    [formatter setDateFormat:kDateTimeFormat];
    
    return [formatter stringFromDate:date];
    
}

+ (NSDate *)dateFromString:(NSString *)string{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:kDateTimeFormat];
    
    return [formatter dateFromString:string];
}

+ (NSDate *)dateMinimum {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateTimeFormat];
    return [formatter dateFromString:kDateMinimum];
}


#pragma mark - Value/classes to sql string

+ (NSString *)sqlStringForDateOrNull:(NSDate *)dateValue {
    if(dateValue){
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        [formatter setDateFormat:kDateTimeFormat];
        
        return [NSString stringWithFormat:@"'%@'", [formatter stringFromDate:dateValue]];
    }
    else
        return @"NULL";
}

+ (NSString *)sqlStringForBool:(BOOL)boolValue {
    if(boolValue)
        return [NSString stringWithFormat:@"%d", 1];
    else
        return [NSString stringWithFormat:@"%d", 0];
}

+ (NSString *)sqlStringForIntOrNull:(NSInteger)intValue {
    if(intValue != -1)
        return [NSString stringWithFormat:@"%ld", intValue];
    else
        return @"NULL";
}

+ (NSString *)sqlStringForStringOrNull:(NSString *)stringValue {
    if(stringValue)
        return [NSString stringWithFormat:@"'%@'", stringValue];
    else
        return @"NULL";
}

+ (NSString *)sqlStringForDecimal:(double)doubleValue {
    return [NSString stringWithFormat:@"%.2f", doubleValue];
}

+ (NSString *)sqlStringForIntOrDefault:(NSInteger)intValue {
    if(intValue > 0 && intValue < 1000)
        return [NSString stringWithFormat:@"%ld", intValue];
    else
        return @"100";
}

#pragma mark - Config object of app

+ (YGConfig *)config {
    
    NSString *documentsDirectory = [YGTools documentsDirectoryPath];
    
    YGConfig *config = [[YGConfig alloc] initWithPath:documentsDirectory name:kAppConfigName];
    
    return [config copy];
}

#pragma mark - Device specific methods

+ (NSString *)documentsDirectoryPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory copy];
}

#pragma mark - Size

/**
 Transform size in bytes in more human view. 15560749240 -> | 15 GB.
 
 - size: directory contens size in bytes,
 
 - return: size in nice, usefull string - ~ 15 GB.
 */
+ (NSString *)humanViewStringForByteSize:(NSUInteger)size{
    
    NSString *resultString = @"";
    NSUInteger leadNum = 0, trailNum = 0, abbIndex = 0;
    
    // B, KB, MB, GB...
    NSArray *abbSize = kFileSizeAcronyms;
    
    NSMutableString *stringNum = [[NSMutableString alloc] init];
    
    do{
        if(size < 1024 && size != 0){
            [stringNum insertString:[NSString stringWithFormat:@"%lu %@", size, abbSize[abbIndex]] atIndex:0];
            break;
        }
        else{
            leadNum = size / 1024;
            trailNum = size % 1024;
            
            size = leadNum;
            
            abbIndex++;
        }
        
    }while(size > 0);
    
    if([stringNum compare:@""] != NSOrderedSame)
        resultString = [NSString stringWithFormat:@"~ %@", stringNum];
    else
        resultString = @"0 B";
    
    return resultString;
}

#pragma mark - Specific device tuning

/**
 Default font size depends from width of screen this device. If func can not get info about screen width of concrete device fot set to 18.
 
 @return Font size.
 */
+ (NSInteger)defaultFontSize {
    
    NSInteger defaultSize = 18;
    
    NSInteger deviceScreenHeight = [YGTools deviceScreenWidth];
    
    if(deviceScreenHeight == 320){
        defaultSize = 18;
    }
    else if(deviceScreenHeight == 375){
        defaultSize = 20;
    }
    else if(deviceScreenHeight == 414){
        defaultSize = 22;
    }
    
    return defaultSize;
}

+ (NSInteger)deviceScreenWidth {
    
    NSInteger screenWidth = 750;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(![defaults valueForKey:@"DeviceScreenWidth"])
        return screenWidth;
    
    screenWidth = [[defaults valueForKey:@"DeviceScreenWidth"] integerValue];
    
    switch(screenWidth){
        case 320:
            return 320;
        case 640:
            return 320; //screenWidth / 2;
        case 750:
            return 375; //screenWidth / 2;
        case 1080:
        case 1242:
            return 414; //screenWidth / 3;
    }
    
    return screenWidth;
}

/*
+ (void)sizeClassOfCurrentIPhone {
    UIDevice *device = [UIDevice currentDevice];
    
    UIScreen *screen = [UIScreen mainScreen];
    
    //NSLog(@"%@", NSStringFromCGRect([screen nativeBounds]));
}
 */

#pragma mark - Default colors for actions

+ (UIColor *)colorForActionDisable{
    return [UIColor lightGrayColor];
}


+ (UIColor *)colorForActionDeactivate {
    return [UIColor colorWithRed:0/255.f green:122/255.f blue:255/255.f alpha:1.f];
}


+ (UIColor *)colorForActionActivate {
    return [UIColor colorWithRed:113/255.f green:211/255.f blue:49/255.f alpha:1.f];
}

+ (UIColor *)colorForActionSaveAndAddNew {
    return [UIColor colorWithRed:0/255.f green:122/255.f blue:255/255.f alpha:1.f];
}

+ (UIColor *)colorForActionBackup {
    return [UIColor colorWithRed:0/255.f green:122/255.f blue:255/255.f alpha:1.f];
}

+ (UIColor *)colorForActionRestore {
    return [UIColor colorWithRed:113/255.f green:211/255.f blue:49/255.f alpha:1.f];
}


+ (UIColor *)colorForActionDelete{
    return [UIColor colorWithRed:255/255.f green:95/255.f blue:119/255.f alpha:1.f];
}

+ (NSString *)languageCodeSystem{
    
    NSString *languageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    return languageCode;
}

+ (NSString *)languageCodeApplication{
    
    NSString *languageCode = [self languageCodeSystem];
    
    if([languageCode isEqualToString:@"ru"])
        return @"ru";
    else
        return @"en";
}


@end
