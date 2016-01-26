//
//  PhoneBookManager.m
//  PhoneBook
//
//  Created by 周双建 on 15/12/28.
//  Copyright © 2015年 周双建. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PhoneBookManager.h"
// 导入最新框架
#import <Contacts/Contacts.h>
@implementation PhoneBookManager{
    // 创建一个新的通讯录雷
    CNContactStore *  ContactStore;
}
// 初始化对象
-(PhoneBookManager*)PhoneBookShare{
    static PhoneBookManager * Manger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Manger = [[self class] alloc];
    });
    return Manger;
}
// 检测是否有权限设置
-(BOOL)ExamineGetPhoneBookOfJurisdiction{
    // 获取枚举类型，是否允许获取权限的状态
    CNAuthorizationStatus  AuthorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (AuthorizationStatus == CNAuthorizationStatusNotDetermined) {
        return NO;
    }else{
        return YES;
    }
}
-(void)GetJurisdiction{
    // 必须初始化，否者什么都没有
    if (!ContactStore) {
        ContactStore = [[CNContactStore alloc]init];
    }
    // 请求授权
    [ContactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            NSLog(@"授权成功");
        }else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self GetJurisdiction];
            });
            
        }
        
    }];
}
-(NSMutableArray*)GetPersonPhoneBook{
    NSUserDefaults * UserDefaults = [NSUserDefaults standardUserDefaults];
    // 创建获取数据的结构   //姓     名     电话    邮件  生日
    NSArray * TypeArray = @[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey,CNContactBirthdayKey,CNContactDepartmentNameKey];
    //发起请求
    CNContactFetchRequest * Request = [[ CNContactFetchRequest alloc]initWithKeysToFetch:TypeArray];
    // 创建存放数组
    NSMutableArray * MutableArray = [NSMutableArray arrayWithCapacity:0];
    // 存放对应字母的数组
    for (int i =0 ; i<26; i++) {
        NSMutableDictionary * TempDict = [[NSMutableDictionary alloc]init];
        [TempDict setObject:[NSString stringWithFormat:@"%c",i+65] forKey:[NSString stringWithFormat:@"ZSJ"]];
        NSMutableArray * Array = [NSMutableArray arrayWithCapacity:0];
        [TempDict setObject:Array forKey:[NSString stringWithFormat:@"Array"]];
        [MutableArray addObject:TempDict];
    }
    
    // 获取所有联系人
    [ContactStore enumerateContactsWithFetchRequest:Request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        /*
         *  CNLabeledValue 该类在json 转化二进制流的时候，不能被转化。切记一定要转化，否者也存不到文件里面
         */
        //  建一个存放数据的字典,并初始化
        NSMutableDictionary * MutableDictv = [NSMutableDictionary dictionaryWithCapacity:0];
        // 声明电话数组和邮箱数组，并初始化
        NSMutableArray * PhoneArray = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray * EmailArray = [NSMutableArray arrayWithCapacity:0];
        // 这是电话号码的转化
        for (CNLabeledValue * LabeledValue in contact.phoneNumbers) {
            [PhoneArray addObject:[self rangStr:LabeledValue.description dostr:@"digits"]];
        }
        // 这是邮箱地址的转化
        for (CNLabeledValue * EmailValue in contact.emailAddresses) {
            [EmailArray addObject:[self rangStr:EmailValue.description dostr:@"value"]];
        }
        // 获取整体个人数据
        [MutableDictv setObject:[self jcnul:contact.familyName] forKey:@"name"];
        [MutableDictv setObject:[self jcnul:PhoneArray ] forKey:@"phones"];
        [MutableDictv setObject:[self jcnul:@(contact.birthday.year)] forKey:@"birthday"];
        [MutableDictv setObject:[self jcnul:contact.givenName] forKey:@"givenName"];
        [MutableDictv setObject:[self jcnul:EmailArray] forKey:@"emails"];
        // 进行数组的分类
        for (int j = 0; j<26; j++) {
            // 切记不要忘记加 65 
            if ([[self firstZiMu:contact.familyName] isEqualToString:[NSString stringWithFormat:@"%c",j+65]]) {
                NSString * Str =[NSString stringWithFormat:@"Array"];
                [MutableArray[j][Str] addObject:MutableDictv];
            }
        }
      
        
        // 添加到可变数组，进行导出
     }];
    NSLog(@"小月：%@",MutableArray);

    // 下面的功能是检测，通讯录是否发生更新
    if ([[UserDefaults objectForKey:@"count"] intValue]  == MutableArray.count){
        [UserDefaults setValue:@(MutableArray.count) forKey:@"count"];
        [UserDefaults synchronize];
        return nil;
    }else{
        [UserDefaults setValue:@(MutableArray.count) forKey:@"count"];
        [UserDefaults synchronize];
        return MutableArray;
    }
}
// 检测空值
-(id)jcnul:(id)null{
    if ([null isKindOfClass:[NSString class]]) {
        if ([null length] == 0) {
            return @"";
        }else{
            return null;
        }
    }else{
        
        return null;
    }
}
#pragma mark 一个字符串，被包含，获取位置
-(NSString *)rangStr:(NSString*)str dostr:(NSString*)dostr{
    // 获取你要查找的字符串的位置
    NSRange Range = [str rangeOfString:dostr];
    NSInteger Inter = dostr.length;
    // 截取字符串的规定的长度
    return [str substringWithRange:NSMakeRange(Range.location+Inter+1,str.length - Range.location - Inter -4)];
}
-(NSString*)firstZiMu:(NSString*)ZiMuStr{
    NSString * Str = [ZiMuStr substringToIndex:1];
    NSLog(@"zimu :%@",Str);
    return Str;
}
@end
