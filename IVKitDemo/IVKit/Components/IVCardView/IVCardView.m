//
//  IVCardView.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/9.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "IVCardView.h"

static NSInteger kMaxNumOfCells = 3;

@interface IVCardView()

@property (nonatomic,strong,readwrite) NSMutableArray<__kindof IVCardViewCell *> *visibleCells;
@property (nonatomic,strong) NSMutableArray *reusableCells;
@property (nonatomic,assign) CGPoint originalCenterOfMovingCell;///<记录原始位置的center
@property (nonatomic,assign) IVCardViewDirection movingDirection;
@property (nonatomic,assign) float movingProgress;

@property (nonatomic,assign) NSInteger currentIndex;///<当前加载的最后的一个index
@property (nonatomic,assign) CGRect frameOfLastCell;///<最底部一个cell的frame
@property (nonatomic,strong) IVCardViewCell *willLoadCell;

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
    self.currentIndex = 0;
}

#pragma mark - Public Methods

- (IVCardViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier{
    IVCardViewCell *cell = [self.reusableCells firstObject];
    if (cell) {
        [self.reusableCells removeObject:cell];
    }
    return cell;
}

- (void)realodData{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSAssert(self.dataSource, @"dataSource must not be nil");
    NSAssert([self.dataSource respondsToSelector:@selector(cardView:cellAtIndex:)], @"cardView:cellAtIndex: must be implement");
//    NSInteger number = [self.dataSource numberOfCellsInCardView:self];
    for (NSInteger i = self.currentIndex; i < self.currentIndex + kMaxNumOfCells; i++) {
        IVCardViewCell *cell = [self buildCellAtIndex:i];
        [self.visibleCells addObject:cell];
        cell.frame = CGRectInset(self.bounds, 10, 10);
        [self insertSubview:cell atIndex:0];
        
        self.frameOfLastCell = cell.frame;
    }
    
}

- (IVCardViewCell *)buildCellAtIndex:(NSInteger)index{
    IVCardViewCell *cell = [self.dataSource cardView:self cellAtIndex:index];
    cell.index = index;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
    [cell addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    [cell addGestureRecognizer:pan];
    return cell;
}

#pragma mark - Private Methods

- (void)tapGestureAction:(id)gesture{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gesture;
    IVCardViewCell *cell = (IVCardViewCell *)tap.view;
//    [cell removeFromSuperview];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardView:didSelectCardViewCell:)]) {
        [self.delegate cardView:self didSelectCardViewCell:cell];
    }
}

- (void)panGestureAction:(id)gesture{
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gesture;
    IVCardViewCell *cell = (IVCardViewCell *)pan.view;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.originalCenterOfMovingCell = cell.center;
            [self cellWillMove:cell];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            //获取移动的距离
            CGPoint moveBy = [pan translationInView:self];
            NSLog(@"移动距离为 %@",NSStringFromCGPoint(moveBy));
            cell.center = CGPointMake(cell.center.x + moveBy.x, cell.center.y + moveBy.y);
            [pan setTranslation:CGPointZero inView:self];
            
            [self cellMoving:cell];
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self cellDidMove:cell gesture:pan];
        }
            break;
        default:
        {
            NSLog(@"因为其他原因  移除失败");
            cell.center = self.originalCenterOfMovingCell;
            cell.transform = CGAffineTransformIdentity;
        }
            break;
    }
}

- (void)cellWillMove:(IVCardViewCell *)movingCell{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardView:willDragCardViewCell:)]) {
        [self.delegate cardView:self willDragCardViewCell:movingCell];
    }
    
    if (self.willLoadCell) {
        NSLog(@"之前以前生成过了，不要重复");
        return;
    }
    
    NSInteger number = [self.dataSource numberOfCellsInCardView:self];
    NSInteger indexWillLoad = movingCell.index + kMaxNumOfCells;
    if (number <= indexWillLoad) {
        NSLog(@"没有足够的数据进行加载了");
        return;
    }
    IVCardViewCell *cell = [self buildCellAtIndex:indexWillLoad];
    cell.frame = self.frameOfLastCell;
    [self insertSubview:cell atIndex:0];
    [self.visibleCells addObject:cell];
    self.willLoadCell = cell;
}

- (void)cellMoving:(IVCardViewCell*)movingCell{
    
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

- (void)cellDidMove:(IVCardViewCell *)movingCell gesture:(UIPanGestureRecognizer *)pan{
    BOOL finished = [self judgeMovedSuccess:pan];
    if (finished) {
        NSLog(@"移除成功");
        [self.reusableCells addObject:movingCell];
        self.currentIndex = movingCell.index + 1;
        self.willLoadCell = nil;
        movingCell.transform = CGAffineTransformIdentity;
        [movingCell removeFromSuperview];
    }else{
        NSLog(@"移除失败");
        movingCell.center = self.originalCenterOfMovingCell;
        movingCell.transform = CGAffineTransformIdentity;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardView:didDragCardViewCell:finished:)]) {
        [self.delegate cardView:self didDragCardViewCell:movingCell finished:finished];
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
