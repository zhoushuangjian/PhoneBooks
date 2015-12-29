//
//  ZSJTELCALL.h
//  TELCAll
//
//  Created by mac on 14-11-4.
//  Copyright (c) 2014年 ZSJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSJTELCALL : NSObject
typedef  void (^ZSJTELCALLBlock)(NSTimeInterval Duration);
typedef  void (^ZSJTELCANCELBlock)(void);
+(BOOL)CallPhoneNumber:(NSString*)phoneNumber Call:(ZSJTELCALLBlock)CallBlock Cancel:(ZSJTELCANCELBlock)CancelBlock;
@end
