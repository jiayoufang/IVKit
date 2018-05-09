//
//  ViewController.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/3.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "ViewController.h"
#import "IVCardView.h"

@interface ViewController ()<IVCardViewDelegate,IVCardViewDataSource>

@property (nonatomic,strong) IVCardView *cardView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor greenColor];

    IVCardView *cardView = [[IVCardView alloc]initWithFrame:CGRectMake(20, 20, 300, 400) directions:IVCardViewDirectionAll];
    cardView.dataSource = self;
    cardView.delegate = self;
    [self.view addSubview:cardView];
    self.cardView = cardView;
    [self.cardView realodData];
        
}

- (NSInteger)numberOfCellsInCardView:(IVCardView *)cardView{
    return 20;
}

- (IVCardViewCell *)cardView:(IVCardView *)cardView cellAtIndex:(NSInteger)index{
    static NSString *identifier = @"MyCell";
    IVCardViewCell *cell = [cardView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[IVCardViewCell alloc]initWithStyle:IVCardViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.titleLabel.text = [NSString stringWithFormat:@"Index %ld",(long)index];
    
    return cell;
}

- (void)cardView:(IVCardView *)cardView didSelectedCardViewCell:(IVCardViewCell *)cell{
    NSLog(@"执行了单击操作");
}

- (void)cardView:(IVCardView *)cardView draggableDirection:(IVCardViewDirection)direction progress:(float)progress{
    NSLog(@"滑动的方向为 %@ 进度为 %.2f",[self directionStr:direction],progress);
}

- (void)cardView:(IVCardView *)cardView didDraggedCardViewCell:(IVCardViewCell *)cell finished:(BOOL)finished{
    NSLog(@"执行滑动操作结束 %@",finished ? @"成功了" : @"失败了");
}

- (NSString *)directionStr:(IVCardViewDirection)direction{
    switch (direction) {
        case IVCardViewDirectionUp:
        {return @"Up";}
            break;

        case IVCardViewDirectionDown:
        {return @"Down";}
            break;

        case IVCardViewDirectionRight:
        {return @"Right";}
            break;

        case IVCardViewDirectionLeft:
        {return @"Left";}
            break;

        default:
            return @"未知";
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
