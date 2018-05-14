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
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor greenColor];

    IVCardView *cardView = [[IVCardView alloc]initWithFrame:CGRectMake(20, 20, 300, 400) directions:IVCardViewDirectionAll];
    cardView.dataSource = self;
    cardView.delegate = self;
    cardView.removedDirections = IVCardViewDirectionLeft|IVCardViewDirectionRight;
    [self.view addSubview:cardView];
    self.cardView = cardView;
    
    [self buildData];
    
    [self.cardView realodData];
    
    CGAffineTransform tranform = CGAffineTransformIdentity;
    for (int i = 0; i < 3; i++) {
        UIView *vv = [[UIView alloc]initWithFrame:CGRectMake(100, 450, 100, 100)];
        vv.backgroundColor = [UIColor redColor];
        [self.view addSubview:vv];
        CGAffineTransform translation = CGAffineTransformTranslate(tranform, 0, 20); //CGAffineTransformMakeTranslation(0, 20);
        CGAffineTransform scale = CGAffineTransformScale(tranform, 0.8, 1.0);
        tranform = CGAffineTransformConcat(translation, scale);
        vv.transform = tranform;
    }
}


- (void)buildData{
    NSInteger count = self.dataArray.count;
    for (NSInteger i = count; i < count + 5; i++) {
        [self.dataArray addObject:[NSString stringWithFormat:@"哈哈哈哈 %ld",(long)i]];
    }
}

- (void)noMoreDataOfCardView:(IVCardView *)cardView{
    [self buildData];
    [cardView realodData];
}

- (NSInteger)numberOfCellsInCardView:(IVCardView *)cardView{
    return self.dataArray.count;
}

- (IVCardViewCell *)cardView:(IVCardView *)cardView cellAtIndex:(NSInteger)index{
    static NSString *identifier = @"MyCell";
//    NSString *identifier = [NSString stringWithFormat:@"ROW%ld",index];
    IVCardViewCell *cell = [cardView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[IVCardViewCell alloc]initWithStyle:IVCardViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSLog(@"*****cell的地址为 %p",cell);
//    cell.titleLabel.text = [NSString stringWithFormat:@"Index %ld",(long)index];
    cell.titleLabel.text = self.dataArray[index];
    
    return cell;
}
//static BOOL isLoading = NO;
//- (void)noMoreDataOfCardView:(IVCardView *)cardView{
//    if (isLoading) {
//        return;
//    }
//    isLoading = YES;
//    [self buildData];
//    isLoading = NO;
//}

- (void)cardView:(IVCardView *)cardView didSelectCardViewCell:(IVCardViewCell *)cell{
    NSLog(@"执行了单击操作");
}

- (void)cardView:(IVCardView *)cardView willDragCardViewCell:(IVCardViewCell *)cell{
    NSLog(@"第 %ld 个cell将要移动",(long)cell.index);
}

- (void)cardView:(IVCardView *)cardView draggingCardViewCell:(IVCardViewCell *)cell direction:(IVCardViewDirection)direction progress:(float)progress{
    NSLog(@"第 %ld 个cell 滑动的方向为 %@ 进度为 %.2f",(long)cell.index,[self directionStr:direction],progress);
}

- (void)cardView:(IVCardView *)cardView didDragCardViewCell:(IVCardViewCell *)cell finished:(BOOL)finished{
    NSLog(@"第 %ld 个cell 执行滑动操作结束 %@",(long)cell.index,finished ? @"成功了" : @"失败了");
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
////    [self buildData];
////    [self.cardView realodData];
//}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
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
