//
//  PhoneBookManager.h
//  PhoneBook
//
//  Created by 周双建 on 15/12/28.
//  Copyright © 2015年 周双建. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneBookManager : NSObject
// 初始化对象
-(PhoneBookManager*)PhoneBookShare;
// 判断是否有获取通讯录的权限
-(BOOL)ExamineGetPhoneBookOfJurisdiction ;
// 获得权限
-(void)GetJurisdiction ;
// 获取所有的联系人
-(NSMutableArray*)GetPersonPhoneBook ;
@end
