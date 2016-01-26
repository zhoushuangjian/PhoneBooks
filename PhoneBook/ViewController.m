//
//  ViewController.m
//  PhoneBook
//
//  Created by 周双建 on 15/12/28.
//  Copyright © 2015年 周双建. All rights reserved.
//

#import "ViewController.h"
#import "PhoneBookManager.h"
// 导入支持打电话的头文件
#import "ZSJTELCALL.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView * PhoneBook;
    // 全局数据变量
    CGPoint  AllPoint ;
}
// 从数据里获取的数据
@property(nonatomic,strong) NSMutableArray * PhoneBooksArray;
// 设置，全局控件
@property(nonatomic,strong) UIView * AllObject_View;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self Nav];
    [self createTableview];
    [self loaddata];

}
-(void)Nav{
    UILabel * NameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    NameLabel.text = @"成功QQ吧提供--通讯录";
    NameLabel.font = [UIFont systemFontOfSize:20];
    NameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:NameLabel];
    UIView * Line = [[UIView alloc]initWithFrame:CGRectMake(0, 65, self.view.frame.size.width, 0.5)];
    Line.backgroundColor = [UIColor magentaColor];
    [self.view addSubview:Line];
    
}
#pragma mark  获取检测数据更新
-(void)loaddata{
    // 创建一个单利对象
    PhoneBookManager * Manager = [[PhoneBookManager alloc]init];
    // 检测是否授权状态
    if ([Manager ExamineGetPhoneBookOfJurisdiction]) {
        // 请求授权
        [Manager GetJurisdiction];
    }else{
        // 请求授权
        [Manager GetJurisdiction];
    }
    // 记得要初始化
    _PhoneBooksArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * PhoneObjects = [Manager GetPersonPhoneBook];
    if (PhoneObjects.count == 0) {
        // 不写入数据
        _PhoneBooksArray= [self getphonearray];
    }else{
        // 开始写入数据
        [self writeConfigFile:PhoneObjects];
        _PhoneBooksArray = PhoneObjects;
    }
    [PhoneBook reloadData];
}
-(void)createTableview{
    // 初始化
    PhoneBook = [[UITableView alloc]initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, self.view.frame.size.height - 66) style:UITableViewStylePlain];
    // 设置代理
    PhoneBook.dataSource = self;
    PhoneBook.delegate = self;
    // 去掉多余的分割线
    UIView * FootView = [[UIView alloc]init];
    PhoneBook.tableFooterView = FootView;
    [self.view addSubview:PhoneBook];
}
#pragma mark 实现其代理，必须实现三个
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"VBBB:%ld",_PhoneBooksArray.count);
    return _PhoneBooksArray.count;
}
// 返回tableView 的个数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString * DS = [NSString stringWithFormat:@"Array"];
    NSLog(@"123:%@",_PhoneBooksArray);
    return [_PhoneBooksArray[section][DS] count];
}
// 设置返回每个cell 的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
// 设置cell的样式
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * CellID = [NSString stringWithFormat:@"IDF%d-%d",(int)indexPath.section,(int)indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        // cell 的创建与初始化
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        // 添加手势
        UILongPressGestureRecognizer * LongP = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(LongPClick:)];
        [cell addGestureRecognizer:LongP];
        // 巧用UILabel传递数据
        UILabel * M = [[UILabel alloc]init];
        M.text = [NSString stringWithFormat:@"%d*%d",(int)indexPath.section,(int)indexPath.row];
        M.tag = 1000;
        [cell addSubview:M];
        UIImageView * ImageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
        // 获取随机数据
        int count = arc4random()%6;
        //添加数据
        ImageV.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",count]];
        // 对图片处理
        ImageV.contentMode = UIViewContentModeScaleAspectFill;
        // 进行圆角裁剪
        ImageV.layer.masksToBounds = YES;
        ImageV.layer.cornerRadius = 15;
        [cell addSubview:ImageV];
        
        // 姓名
        UILabel * NameLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(ImageV.frame)+20, 10, 200, 30)];
        NameLable.tag = 100;
        [cell addSubview:NameLable];
        
        // 电话话好吗
        UILabel * PhoneLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(ImageV.frame)+20, 40, 200, 30)];
        PhoneLable.tag = 200;
        [cell addSubview:PhoneLable];
        
        // 打电话按钮的添加
        UIButton * TelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        TelBtn.frame = CGRectMake(self.view.frame.size.width-70, 20, 70, 70);
        TelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [TelBtn setImage:[UIImage imageNamed:@"phone.png"] forState:UIControlStateNormal];
        TelBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [TelBtn addTarget:self action:@selector(TelClick:) forControlEvents:UIControlEventTouchUpInside];
        TelBtn.titleLabel.text = [NSString stringWithFormat:@"%ld-%ld",indexPath.section,indexPath.row];
        [cell addSubview:TelBtn];
    }
    // 给名字，添加数据
    UILabel * CellNameLabel = (UILabel*)[cell viewWithTag:100];
    CellNameLabel.text = _PhoneBooksArray[indexPath.section][[NSString stringWithFormat:@"Array"]][indexPath.row][@"name"];
    // 给电话号码，添加数据
    UILabel * CellPhoneLabel = (UILabel*)[cell viewWithTag:200];
    CellPhoneLabel.text = _PhoneBooksArray[indexPath.section][[NSString stringWithFormat:@"Array"]][indexPath.row][@"phones"][0];

    return cell;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString * DS = [NSString stringWithFormat:@"Array"];
    // 进行多余的删除（空的数组）
    if ([_PhoneBooksArray[section][DS]  count] == 0) {
        return @"";
    }else{
    return [NSString stringWithFormat:@"%@",_PhoneBooksArray[section][@"ZSJ"]];
    }
}
// 返回，检索的字母
-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray *  Array = [NSMutableArray arrayWithCapacity:0];
    for (int i =0 ;i<26 ; i++) {
        // 以字符的方式输出
        [Array addObject:[NSString stringWithFormat:@"%c",65+i]];
    }
    // 进行数据的插入
    [Array insertObject:@"❤" atIndex:0];
    return Array;
}
// 进行检索
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}
// 让cell 选中不变色
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
// cell 右侧划出按钮，被点击的时候，进行调用的方法
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    // 进行删除数据
    [self deleteobjectdata:indexPath];
}
// 改变右滑出后，显示字体的色值
-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
// cell 被选中哪一个
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"都比");
    // 这个方法，现在是不可以用的，因为上面，一个方法设置为NO了。
}
/******************************************************************************************/
    // 在这里我们要实现scrollview 的一个代理，让它完成消除全局控件
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self deallocAllView];
}
/********************************************************************************************/
-(void)writeConfigFile:(NSMutableArray *)array
{
    //第一：读取documents路径的方法：
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) ; //得到documents的路径，为当前应用程序独享
    NSString *documentD = [paths objectAtIndex:0];
    NSString *configFile = [documentD stringByAppendingPathComponent:@"phonebook.plist"]; //得到documents目录下dujw.plist配置文件的路径
    NSMutableDictionary *configList =[[NSMutableDictionary alloc] initWithContentsOfFile:configFile];  //初始化字典，读取配置文件的信息
    //NSMutableDictionary *configList =[[NSMutableDictionary alloc] dictionaryWithContentsOfFile:configFile];
        //第二：写入文件file
    if (!configList) {
        //第一次，文件没有创建，因此要创建文件，并写入相应的初始值。
        configList = [[NSMutableDictionary alloc] init];
    }
    // 设置字典的标记
    [configList setObject:array forKey:@"Root3"];
    // json 转化为二进制流
    NSData * data = [NSJSONSerialization dataWithJSONObject:configList options:NSJSONWritingPrettyPrinted error:nil];
    // 将二进制流写入plist文件里
    [data writeToFile:configFile atomically:YES];

}
-(NSMutableArray*)getphonearray{
    //获取数据
    NSMutableDictionary * TempDict = [self getDict];
    // 此处非常重要，必不可少
    /*
     * 这段代码是将从文件里获取的数据，转化为可变的数据，一边后续Cell的其他操作。
     */
    NSMutableArray * TempArray = [NSMutableArray arrayWithArray:TempDict[@"Root3"]];
    NSMutableArray *AllArray = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i<TempArray.count; i++) {
        NSMutableDictionary * AllDict = [NSMutableDictionary dictionaryWithCapacity:0];
        NSString * DS = [NSString stringWithFormat:@"Array"];
        NSMutableArray * MuArray = [NSMutableArray arrayWithCapacity:0];
        for (int j =0 ; j<[TempArray[i][DS] count]; j++) {
            NSMutableDictionary * Dict3 = [NSMutableDictionary dictionaryWithDictionary:TempArray[i][DS][j]];
            [MuArray addObject:Dict3];
        }
        [AllDict setObject:MuArray forKey:DS];
        [AllDict setObject:[NSString stringWithFormat:@"%c",i+65] forKey:[NSString stringWithFormat:@"ZSJ"]];
        [AllArray addObject:AllDict];
    }
   
    // 读取数据
    return  AllArray;
}
-(NSMutableDictionary*)getDict{
    //第一：读取documents路径的方法：
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) ; //得到documents的路径，为当前应用程序独享
    NSString *documentD = [paths objectAtIndex:0];
    NSString *configFile = [documentD stringByAppendingPathComponent:@"phonebook.plist"];
    //得到documents目录下plist配置文件的路径
    NSData * data = [NSData dataWithContentsOfFile:configFile];
    // 通过json转化为字典
    NSMutableDictionary *configList =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    //初始化字典，读取配置文件的信息
    return  configList;
}
// 进行打电话
-(void)TelClick:(UIButton*)Tel{
    // 哪一个段
    NSInteger Sectin = [[[Tel.titleLabel.text componentsSeparatedByString:@"-"] firstObject]integerValue];
    // 哪一行
    NSInteger Row = [[[Tel.titleLabel.text componentsSeparatedByString:@"-"] lastObject] integerValue];
    
    // 获取改用户的电话号码
    NSString * DS = [NSString stringWithFormat:@"Array"];
    NSString * TelNumber = _PhoneBooksArray[Sectin][DS][Row][@"phones"][0];
    // 一行代码调通电话接口
    [ZSJTELCALL CallPhoneNumber:TelNumber Call:^(NSTimeInterval Duration) {
        // 通话时间提醒
    } Cancel:^{
        // 通话结束
    }];
}
// 添加长按手势
-(void)LongPClick:(UILongPressGestureRecognizer*)LPg{
    // 消除全局控件
    [self deallocAllView];
   // 获取手势点击的View，进行转化
    UIView * LongGV = LPg.view;
    // 定义接受类型
    NSString * WantObjectStr = [NSString string];
    // 遍历点击父视图的全部子类，拿到自己想要的
    for (id temp  in [LongGV subviews]) {
        // 判断类别，那到对应的类型对象，传来的数据
        if ([temp isKindOfClass:[UILabel class]]) {
             // 有可能，父视图的子类，有好多和你需要的对象的类型相同，我再次进行判决
            if ([temp tag] == 1000) {
                // 要注意类型的形式
              WantObjectStr  = [(UILabel*)temp  text];
            }
        }
    }
    // 我长按的哪一段
    NSInteger LGPSection = [[[WantObjectStr componentsSeparatedByString:@"*"] firstObject] integerValue];
    // 我长按的是哪一行
    NSInteger LGPRow = [[[WantObjectStr componentsSeparatedByString:@"*"] lastObject] integerValue];
    // 整合对象，标记
    CGPoint ObjectPoint = CGPointMake(LGPSection, LGPRow);
    // 获取我长按的那个点的位置坐标
    // 在这里我们进行特别的处理工作，为的就是让全局控件，出现的位置美观
    CGPoint JBLPoint = [LPg locationInView:LongGV];
    CGPoint LGPPoint = [LPg locationInView:self.view];
    // 组合最重点
    CGPoint EndPoint = CGPointMake(self.view.center.x-60, LGPPoint.y -JBLPoint.y-20);
    [self create:EndPoint whichobject:ObjectPoint];
    
    
    
}
// 创建全局控件
-(void)create:(CGPoint)LocationPoint whichobject:(CGPoint)object{
    // 初始化，全局控件
    _AllObject_View = [[UIView alloc]initWithFrame:CGRectMake(LocationPoint.x, LocationPoint.y, 120, 50)];
    _AllObject_View.backgroundColor = [UIColor clearColor];
    // 添加控件图片，已达到美化的效果
    UIImageView * ImageVZSJ = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 120, 50)];
    ImageVZSJ.image = [UIImage imageNamed:@"allview.png"];
    // 切记，打开图片的交互
    ImageVZSJ.userInteractionEnabled = YES;
    // 进行数据的隐私传递
    AllPoint = object;
    // 添加对应的功能按钮‘
    NSArray * TitleArray = @[@"置顶",@"删除"];
    for (int i = 0 ; i< TitleArray.count; i++) {
        UIButton * Button = [UIButton buttonWithType:UIButtonTypeCustom];
        Button.frame = CGRectMake(6+i*56, 5, 50, 40);
        [Button setTitle:TitleArray[i] forState:UIControlStateNormal];
        [Button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [Button addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
        // 这里是避免标记相同
        Button.tag = i+2000;
        Button.titleLabel.font = [UIFont systemFontOfSize:16];
        [ImageVZSJ addSubview:Button];
        if (i==1) {
            UIView * Line = [[UIView alloc]initWithFrame:CGRectMake(ImageVZSJ.center.x-0.5, 15, 1, 20)];
            Line.backgroundColor = [UIColor whiteColor];
            [ImageVZSJ addSubview:Line];
        }
    }
    [_AllObject_View addSubview:ImageVZSJ];
    [self.view addSubview:_AllObject_View];
}
// 全局控件上的按钮功能实现
-(void)BtnClick:(UIButton*)BtnClick{
    switch (BtnClick.tag - 2000) {
        case 0:{
            // 清除全局控件
            [self deallocAllView];
            // 创建要删除的对象的位置
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:AllPoint.y inSection:AllPoint.x];
            NSLog(@"%ld-----%ld",indexPath.section,indexPath.row);
            // 我们要做置顶数据是否存在的检测
            if ([self ZiDingPaiChong]) {
                 // 存在
                [ _PhoneBooksArray[0][@"Array"] addObject:_PhoneBooksArray[indexPath.section][@"Array"][indexPath.row]] ;
                
            }else{
                // 不存在置顶数据
            // 置顶功能

            // 创建大的可变数组
            NSMutableDictionary * MutableDict = [NSMutableDictionary dictionaryWithCapacity:0];
            NSMutableArray * tempArray = [NSMutableArray arrayWithCapacity:0];
            [tempArray addObject:_PhoneBooksArray[indexPath.section][@"Array"][indexPath.row]];
            // 注意包装的数据结构
            [MutableDict setObject:tempArray forKey:@"Array"];
            [MutableDict setObject:@"❤" forKey:@"ZSJ"];
            // 加入导主数据里
            [_PhoneBooksArray insertObject:MutableDict atIndex:0];
            }
            // 去刷新数据
            [PhoneBook reloadData];
            // 开启线程，进行写入数据
            dispatch_async(dispatch_get_main_queue(), ^{
                [self writeConfigFile:_PhoneBooksArray];
            });
            
        }
            break;
        case 1:{
            // 删除功能
            // 创建要删除的对象的位置
          NSIndexPath * indexPath = [NSIndexPath indexPathForRow:AllPoint.y inSection:AllPoint.x];
            // 执行删除
         [self deleteobjectdata:indexPath];
            // 消除全局控件
         [self deallocAllView];
        }
            break;

        default:
            break;
    }
    
}
// 删除数据
-(void)deleteobjectdata:(NSIndexPath *)indexPath{
    NSString * DS = [NSString stringWithFormat:@"Array"];
    [_PhoneBooksArray[indexPath.section][DS] removeObjectAtIndex:indexPath.row];
    [PhoneBook reloadData];
    // 可以开启异步线程从新写入文件，更改数据或者是发送服务器，请求更改数据
    dispatch_async(dispatch_get_main_queue(), ^{
        [self writeConfigFile:_PhoneBooksArray];
    });

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// 我们要进行置顶的排重
-(BOOL)ZiDingPaiChong{
    if ([_PhoneBooksArray[0][@"ZSJ"] isEqualToString:@"❤"]) {
        // 有数据的存在
        return YES;
    }else{
        // 没有置顶数据的存在
        return NO ;
    }
}
// 消除全局控件
-(void)deallocAllView{
    [_AllObject_View removeFromSuperview];
}
@end
