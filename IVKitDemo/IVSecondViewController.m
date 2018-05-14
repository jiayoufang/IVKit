//
//  IVSecondViewController.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/13.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "IVSecondViewController.h"

@interface IVSecondViewController ()

@property (nonatomic,strong) NSTimer *timer;

@end

@implementation IVSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor greenColor];

}

- (void)test{

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

- (void)dealloc{
    NSLog(@"SecondVieController Dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
