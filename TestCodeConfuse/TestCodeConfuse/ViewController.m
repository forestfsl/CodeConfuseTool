//
//  ViewController.m
//  TestCodeConfuse
//
//  Created by songlin on 2019/12/27.
//  Copyright © 2019 toucu. All rights reserved.
//

#import "ViewController.h"
#import "MJEncryptString.h"
#import "SLPerson.h"
#import "MJEncryptStringData.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SLPerson *person = [[SLPerson alloc]init];
    [person sl_testCodeConfuse];
    [person sl_setupName:@"测试" sl_no:1 sl_age:2];
    NSString *str1 = mj_OCString(_313099685);
    const char *str2 = mj_CString(_313099685);
    NSLog(@"%@ %s", str1, str2);
}


@end
