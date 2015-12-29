//
//  ZSJTELCALL.m
//  TELCAll
//
//  Created by mac on 14-11-4.
//  Copyright (c) 2014年 ZSJ. All rights reserved.
//

#import "ZSJTELCALL.h"
#import <UIKit/UIKit.h>
#define KCallSteupTime 3.0
@interface ZSJTELCALL ()

@property(nonatomic,strong)NSDate*CallStarTime;
@property(nonatomic,copy)ZSJTELCALLBlock  CallBlock;
@property(nonatomic,copy)ZSJTELCANCELBlock  CancelBlock;

@end
@implementation ZSJTELCALL
+(instancetype)SharedInstance
{
    static ZSJTELCALL*_Instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _Instance=[[self alloc]init];
    });
    return _Instance;
}
+(BOOL)CallPhoneNumber:(NSString *)phoneNumber Call:(ZSJTELCALLBlock)CallBlock Cancel:(ZSJTELCANCELBlock)CancelBlock
{
    if ([self validPhone:phoneNumber]) {
        ZSJTELCALL*TELPrompt=[ZSJTELCALL  SharedInstance];
        [TELPrompt setNotifications];
        TELPrompt.CallBlock=CallBlock;
        TELPrompt.CancelBlock=CancelBlock;
        NSString*SimplePhoneNumber=[[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        NSString*StringUrl=[@"telprompt://" stringByAppendingString:SimplePhoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:StringUrl]];

        return YES;
        
    }
    return NO;
}
+(BOOL)validPhone:(NSString*)phoneString
{
    NSTextCheckingType type =[[NSTextCheckingResult phoneNumberCheckingResultWithRange:NSMakeRange(0, phoneString.length) phoneNumber:phoneString]resultType];
    return type==NSTextCheckingTypePhoneNumber;
}
-(void)setNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
-(void)applicationDidEnterBackground:(NSNotification*)notification
{
    self.CallStarTime=[NSDate date];
}
-(void)applicationDidBecomeActive:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.CallStarTime!=nil) {
        if (self.CallBlock !=nil) {
            self.CallBlock(-([self.CallStarTime timeIntervalSinceNow])-KCallSteupTime);
        }
        self.CallStarTime=nil;
    }else if (self.CancelBlock !=nil){
        self.CancelBlock();
    }
}
@end
