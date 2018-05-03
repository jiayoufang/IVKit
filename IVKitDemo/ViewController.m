//
//  ViewController.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/3.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "ViewController.h"
#import "IVProgressView.h"
#import "UIImage+IVAdd.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
//    IVProgressView *progressView = [[IVProgressView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
//    progressView.backgroundColor = [UIColor redColor];
//    progressView.progress = 0.7;
//    [self.view addSubview:progressView];
    
    UIImage *image = [UIImage imageNamed:@"12.jpg"];
    NSString *str = [image iv_convertImageToBase64];
    NSLog(@"str : %@",str);
    
    UIImage *decodedImage = [UIImage iv_imageWithBase64Str:str];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image = decodedImage;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
