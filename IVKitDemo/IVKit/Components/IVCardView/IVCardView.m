//
//  IVCardView.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/9.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "IVCardView.h"

//static NSInteger kMaxNumOfCells = 3;

@interface IVCardView()

@property (nonatomic,strong,readwrite) NSMutableArray<__kindof IVCardViewCell *> *visibleCells;
@property (nonatomic,strong) NSMutableArray *reusableCells;
@property (nonatomic,assign) CGPoint originalCenterOfMovingCell;///<记录原始位置的center
@property (nonatomic,assign) IVCardViewDirection movingDirection;
@property (nonatomic,assign) float movingProgress;

@end

@implementation IVCardView

- (instancetype)initWithFrame:(CGRect)frame directions:(IVCardViewDirection)directions{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultSetup];
        self.directions = directions;
    }
    return self;
}

- (void)defaultSetup{
    self.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Public Methods

- (IVCardViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier{
    
    return nil;
}

- (void)realodData{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSAssert(self.dataSource, @"dataSource must not be nil");
    NSAssert([self.dataSource respondsToSelector:@selector(cardView:cellAtIndex:)], @"cardView:cellAtIndex: must be implement");
    NSInteger number = [self.dataSource numberOfCellsInCardView:self];
    for (NSInteger i = 0; i < number; i++) {
        IVCardViewCell *cell = [self.dataSource cardView:self cellAtIndex:i];
        [self.visibleCells addObject:cell];
        cell.frame = CGRectInset(self.bounds, 10, 10);
        [self insertSubview:cell atIndex:0];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
        [cell addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
        [cell addGestureRecognizer:pan];
    }
    
}

#pragma mark - Private Methods

- (void)tapGestureAction:(id)gesture{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gesture;
    IVCardViewCell *cell = (IVCardViewCell *)tap.view;
    [cell removeFromSuperview];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardView:didSelectedCardViewCell:)]) {
        [self.delegate cardView:self didSelectedCardViewCell:cell];
    }
}

- (void)panGestureAction:(id)gesture{
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gesture;
    IVCardViewCell *cell = (IVCardViewCell *)pan.view;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.originalCenterOfMovingCell = cell.center;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            //获取移动的距离
            CGPoint moveBy = [pan translationInView:self];
            NSLog(@"移动距离为 %@",NSStringFromCGPoint(moveBy));
            cell.center = CGPointMake(cell.center.x + moveBy.x, cell.center.y + moveBy.y);
            [pan setTranslation:CGPointZero inView:self];
            
            [self currentMovingDirection:cell];
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            BOOL finished = [self judgeMovedSuccess:pan];
            if (finished) {
                NSLog(@"移除成功");
                [cell removeFromSuperview];
            }else{
                NSLog(@"移除失败");
                cell.center = self.originalCenterOfMovingCell;
                cell.transform = CGAffineTransformIdentity;
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(cardView:didDraggedCardViewCell:finished:)]) {
                [self.delegate cardView:self didDraggedCardViewCell:cell finished:finished];
            }
        }
            break;
        default:
        {
            
        }
            break;
    }
}

- (void)currentMovingDirection:(IVCardViewCell*)movingCell{
    
    CGFloat moveX = movingCell.center.x - self.originalCenterOfMovingCell.x;
    CGFloat moveY = movingCell.center.y - self.originalCenterOfMovingCell.y;
//    NSLog(@"当前的位置为%@",NSStringFromCGPoint(self.center))
    if (moveX == 0 && moveY == 0) {
        self.movingDirection = IVCardViewDirectionNone;
    }
    //先判定是上下还是左右  根据方位的移动幅度来判定
    if (fabs(moveX) > fabs(moveY)) {
        //左右
        if (moveX > 0) {
            self.movingDirection = IVCardViewDirectionRight;
        } else {
            self.movingDirection = IVCardViewDirectionLeft;
        }
    } else {
        if (moveY > 0) {
            self.movingDirection = IVCardViewDirectionDown;
        } else {
            self.movingDirection = IVCardViewDirectionUp;
        }
    }
    
    float progressX = moveX/self.originalCenterOfMovingCell.x;
    float progressY = moveY/self.originalCenterOfMovingCell.y;
    self.movingProgress = MIN(MAX(fabs(progressX), fabs(progressY)),1.0);
    
    if (self.movingDirection == IVCardViewDirectionRight) {
        movingCell.transform = CGAffineTransformRotate(CGAffineTransformIdentity, MIN(progressX, 1.0) * M_PI_4 * 0.4);
    }else if (self.movingDirection == IVCardViewDirectionLeft){
        movingCell.transform = CGAffineTransformRotate(CGAffineTransformIdentity, MAX(progressX, -1.0) * M_PI_4 * 0.4);
    }else{
        movingCell.transform = CGAffineTransformIdentity;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardView:draggingDirection:progress:)]) {
        [self.delegate cardView:self draggingDirection:self.movingDirection progress:self.movingProgress];
    }
}

- (BOOL)judgeMovedSuccess:(UIPanGestureRecognizer *)pan{
    if (self.movingProgress >= 1.0) {
        return YES;
    }
    CGPoint velocity = [pan velocityInView:self];
//    NSLog(@"当前的速度是 %@",NSStringFromCGPoint(velocity));
    if (fabs(velocity.x) >= 800 || fabs(velocity.y) >= 800) {
        return YES;
    }
    return NO;
}

#pragma mark - Setter & Getter

- (NSMutableArray *)visibleCells{
    if (!_visibleCells) {
        _visibleCells = [[NSMutableArray alloc]init];
    }
    return _visibleCells;
}

- (NSMutableArray *)reusableCells{
    if (!_reusableCells) {
        _reusableCells = [[NSMutableArray alloc]init];
    }
    return _reusableCells;
}

@end
