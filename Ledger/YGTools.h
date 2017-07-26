//
//  YGTools.h
//  Ledger
//
//  Created by Ян on 31/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class YGConfig;

@interface YGTools : NSObject

+ (BOOL) isDayOfDate:(NSDate *)sourceDate equalsDayOfDate:(NSDate *)targetDate;
+ (NSDate *)dayOfDate:(NSDate *)date;
+ (NSString *)humanViewOfDate:(NSDate *)date;
+ (NSString *)humanViewWithTodayOfDate:(NSDate *)date;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringWithCurrentTimeZoneFromDate:(NSDate *)date;
+ (NSDate *)dateFromString:(NSString *)string;

+ (NSString *)humanViewShortWithTodayOfDateString:(NSString *)dateString;
+ (NSString *)humanViewShortWithTodayOfDay:(NSDate *)day;

+ (NSDate *)dateMinimum;

+ (NSString *)sqlStringForDateOrNull:(NSDate *)dateValue;
+ (NSString *)sqlStringForBool:(BOOL)boolValue;
+ (NSString *)sqlStringForIntOrNull:(NSInteger)intValue;
+ (NSString *)sqlStringForStringOrNull:(NSString *)stringValue;
+ (NSString *)sqlStringForDecimal:(double)doubleValue;
+ (NSString *)sqlStringForIntOrDefault:(NSInteger)intValue;

+ (YGConfig *)config;

+ (NSString *)documentsDirectoryPath;

+ (NSString *)humanViewStringForByteSize:(NSUInteger)size;

//+ (NSInteger *)sizeClassOfCurrentIPhone;

+ (NSInteger)defaultFontSize;

+ (NSInteger)deviceScreenWidth;

+ (UIColor *)colorForActionDisable;
+ (UIColor *)colorForActionDeactivate;
+ (UIColor *)colorForActionActivate;
+ (UIColor *)colorForActionSaveAndAddNew;
+ (UIColor *)colorForActionBackup;
+ (UIColor *)colorForActionRestore;
+ (UIColor *)colorForActionDelete;

/// current laguage code
+ (NSString *)languageCodeSystem;
+ (NSString *)languageCodeApplication;

+ (BOOL)isValidSumInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range;
+ (BOOL)isValidSumWithZeroInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range;
+ (BOOL)isValidSortInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range;
+ (BOOL)isValidNoteInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range;
+ (BOOL)isValidNameInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range;
+ (BOOL)isValidShortNameInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range;
+ (BOOL)isValidSymbolInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range;

+ (NSAttributedString *)attributedStringWithText:(NSString *)text color:(UIColor *)color;



@end
