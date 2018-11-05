//
//  Common.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/5/31.
//  Copyright © 2017年 Lucifer. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "FMDatabase.h"

@interface Common : NSObject

+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSString *)stringFromDate:(NSDate *)date
                 formatType:(NSString *)formatType;
+ (NSString *)stringFromDateString:(NSString *)date
                       formatType:(NSString *)formatType;
+ (BOOL)checkPassword:(NSString *)password;
+ (BOOL)checkCpPassword:(NSString *)password;
+ (BOOL)checkEmail:(NSString *)email;
+ (BOOL)checkMobile:(NSString *)mobile;
+ (BOOL)isPureInt:(NSString*)string;
+ (BOOL)isPureChinese:(NSString *)string;
+ (NSString *)MD5:(NSString *)signString;
+ (void)share:(NSString *)title
      content:(NSString *)content
          url:(NSString *)url
     imageUrl:(NSString *)imageUrl;
+ (NSArray *)getArrayFromXml:(GDataXMLDocument *)xmlContent
                   tableName:(NSString *)tableName;
+ (NSString *)getValueFromXml:(GDataXMLDocument *)xmlContent;
+ (NSString *)stringFromRefreshDate:(NSString *)date;
+ (NSArray *)getTextLines:(NSString *)text font:(UIFont *)font rect:(CGRect)rect;
+ (float)getLastLineWidth:(UILabel *)label;
+ (void)changeFontSize:(UIView *)parentView;
+ (NSArray *)querySql:(NSString *)sql dataBase:(FMDatabase *)dataBase;
+ (NSString *)getPaPhotoUrl:(NSString *)fileName paMainId:(NSString *)paMainId;

+ (NSArray *)arrayWelfare;
+ (NSArray *)arrayWelfareId;
+ (NSString *)getWelfare:(NSArray *)arrayWelfareIdSelected;
+ (NSArray *)arrayPush;
+ (NSString *)getPushIdWithBin:(NSString *)pushId;
+ (NSString *)getPush:(NSString *)pushId;

+ (NSString *)toBinarySystemWithDecimalSystem:(NSString *)decimal;
+ (NSString *)toDecimalSystemWithBinarySystem:(NSString *)binary;
+ (NSString *)getSalary:(NSString *)salaryId salaryMin:(NSString *)salaryMin salaryMax:(NSString *)salaryMax negotiable:(NSString *)negotiable;
+ (NSString *)enMobile:(NSString *)mobile;
+ (NSString *)verifyCodeLoginResult:(NSInteger)result;
@end
