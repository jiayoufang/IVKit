//
//  IVCardView.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/9.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "IVCardView.h"
#import "IVReusableCellManager.h"

static NSInteger kMaxNumOfCells = 3;

@interface IVCardView()

@property (nonatomic,strong,readwrite) NSMutableArray<__kindof IVCardViewCell *> *visibleCells;
//@property (nonatomic,strong) NSMutableArray *reusableCells;
@property (nonatomic,strong) IVReusableCellManager *reusableCellManager;
@property (nonatomic,assign) CGPoint originalCenterOfMovingCell;///<记录原始位置的center
@property (nonatomic,assign) IVCardViewDirection movingDirection;
@property (nonatomic,assign) float movingProgress;

@property (nonatomic,assign) NSInteger currentIndex;///<当前加载的最后的一个index
@property (nonatomic,assign) CGRect frameOfLastCell;///<最底部一个cell的frame
//@property (nonatomic,assign) CGRect originalFrameOfFirstCell;
//@property (nonatomic,assign) CGRect originalFrameOfSecondCell;
//@property (nonatomic,assign) CGRect originalFrameOfThirdCell;
@property (nonatomic,strong) IVCardViewCell *willLoadCell;

@end

@implementation IVCardView

- (instancetype)initWithFrame:(CGRect)frame directions:(IVCardViewDirection)directions{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultSetup];
        self.removedDirections = directions;
    }
    return self;
}

- (void)defaultSetup{
    self.backgroundColor = [UIColor whiteColor];
    self.currentIndex = 0;
}

#pragma mark - Public Methods

- (IVCardViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier{
//    IVCardViewCell *cell = [self.reusableCells firstObject];
//    if (cell) {
//        [self.reusableCells removeObject:cell];
//    }
//    return cell;
    IVCardViewCell *cell = [self.reusableCellManager pop:identifier];
    return cell;
}

- (void)realodData{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSAssert(self.dataSource, @"dataSource must not be nil");
    NSAssert([self.dataSource respondsToSelector:@selector(cardView:cellAtIndex:)], @"cardView:cellAtIndex: must be implement");
//    NSInteger number = [self.dataSource numberOfCellsInCardView:self];
//    CGAffineTransform transform = CGAffineTransformIdentity;
    for (NSInteger i = self.currentIndex; i < self.currentIndex + kMaxNumOfCells; i++) {
        IVCardViewCell *cell = [self buildCellAtIndex:i];
        [self.visibleCells addObject:cell];
        cell.frame = CGRectInset(self.bounds, 10, 10);
        [self insertSubview:cell atIndex:0];
        
//        NSInteger index = i - self.currentIndex;
//        CGAffineTransform translation = CGAffineTransformTranslate(transform, 0, 15 * index);
//        CGAffineTransform scale = CGAffineTransformScale(transform, 1.0 - index * 0.1, 1.0);
//        cell.transform = CGAffineTransformConcat(translation, scale);
        
//        if (index == 0) {
//            self.originalFrameOfFirstCell = cell.frame;
//        }else if (index == 1){
//            self.originalFrameOfSecondCell = cell.frame;
//        }else if (index == 2){
//            self.originalFrameOfThirdCell = cell.frame;
//        }
        
        self.frameOfLastCell = cell.frame;
    }
    
}

- (__kindof IVCardViewCell *)cellAtIndex:(NSInteger)index{
    NSInteger number = [self.dataSource numberOfCellsInCardView:self];
    if (index >= number) {
        return nil;
    }
    __block IVCardViewCell *cell = nil;
    [self.visibleCells enumerateObjectsUsingBlock:^(__kindof IVCardViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.index == index) {
            cell = obj;
            *stop = YES;
        }
    }];
    return cell;
}

#pragma mark - Private Methods

- (IVCardViewCell *)buildCellAtIndex:(NSInteger)index{
    IVCardViewCell *cell = [self.dataSource cardView:self cellAtIndex:index];
    cell.index = index;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
    [cell addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
    [cell addGestureRecognizer:pan];
    return cell;
}

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
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(noMoreDataOfCardView:)]) {
            [self.dataSource noMoreDataOfCardView:self];
        }
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
    
//    [self resetCellWhileMovingCellWithProgressX:progressX];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardView:draggingCardViewCell:direction:progress:)]) {
        [self.delegate cardView:self draggingCardViewCell:movingCell direction:self.movingDirection progress:self.movingProgress];
    }
}

//- (void)resetCellWhileMovingCellWithProgressX:(float)progressX{
//    NSInteger count = self.visibleCells.count;
//    if (count <= 0) {
//        return;
//    }
//
//    IVCardViewCell *firstCell = [self.visibleCells objectAtIndex:0];
////    CGRect firstFrame = firstCell.frame;
//
//    if (self.movingDirection == IVCardViewDirectionRight) {
//        firstCell.transform = CGAffineTransformRotate(CGAffineTransformIdentity, MIN(progressX, 1.0) * M_PI_4 * 0.4);
//    }else if (self.movingDirection == IVCardViewDirectionLeft){
//        firstCell.transform = CGAffineTransformRotate(CGAffineTransformIdentity, MAX(progressX, -1.0) * M_PI_4 * 0.4);
//    }else{
//        firstCell.transform = CGAffineTransformIdentity;
//    }
//
//    if (count <= 1) {
//        return;
//    }
//
//    IVCardViewCell *secondCell = [self.visibleCells objectAtIndex:1];
//
//    CGFloat moveByX = self.originalFrameOfFirstCell.origin.x - self.originalFrameOfSecondCell.origin.x;
//    CGFloat moveByY = self.originalFrameOfFirstCell.origin.y - self.originalFrameOfSecondCell.origin.y;
//    CGFloat moveByW = self.originalFrameOfFirstCell.size.width - self.originalFrameOfSecondCell.size.width;
//    CGFloat moveByH = self.originalFrameOfFirstCell.size.height - self.originalFrameOfSecondCell.size.height;
//    CGRect secondNewFrame = CGRectMake(self.originalFrameOfSecondCell.origin.x + moveByX*self.movingProgress, self.originalFrameOfSecondCell.origin.y + moveByY*self.movingProgress, self.originalFrameOfSecondCell.size.width + moveByW*self.movingProgress, self.originalFrameOfSecondCell.size.height + moveByH*self.movingProgress);
//    secondCell.frame = secondNewFrame;
//
//    if (count <= 2) {
//        return;
//    }
//    IVCardViewCell *thirdCell = [self.visibleCells objectAtIndex:2];
//
//    CGFloat moveByX1 = self.originalFrameOfSecondCell.origin.x - self.originalFrameOfThirdCell.origin.x;
//    CGFloat moveByY1 = self.originalFrameOfSecondCell.origin.y - self.originalFrameOfThirdCell.origin.y;
//    CGFloat moveByW1 = self.originalFrameOfSecondCell.size.width - self.originalFrameOfThirdCell.size.width;
//    CGFloat moveByH1 = self.originalFrameOfSecondCell.size.height - self.originalFrameOfThirdCell.size.height;
//    CGRect thirdNewFrame = CGRectMake(self.originalFrameOfThirdCell.origin.x + moveByX1*self.movingProgress, self.originalFrameOfThirdCell.origin.y + moveByY1*self.movingProgress, self.originalFrameOfThirdCell.size.width + moveByW1*self.movingProgress, self.originalFrameOfThirdCell.size.height + moveByH1*self.movingProgress);
//    thirdCell.frame = thirdNewFrame;
//}

- (void)cellDidMove:(IVCardViewCell *)movingCell gesture:(UIPanGestureRecognizer *)pan{
    BOOL finished = [self judgeMovedSuccess:pan];
    if (finished) {
        NSLog(@"移除成功");
        if (self.removedDirections & self.movingDirection) {
            //[self.reusableCells addObject:movingCell];
            [self.reusableCellManager push:movingCell];
            self.currentIndex = movingCell.index + 1;
            self.willLoadCell = nil;
            movingCell.transform = CGAffineTransformIdentity;
            [movingCell removeFromSuperview];
        }else{
            movingCell.center = self.originalCenterOfMovingCell;
            movingCell.transform = CGAffineTransformIdentity;
        }
    }else{
        NSLog(@"移除失败");
        movingCell.center = self.originalCenterOfMovingCell;
        movingCell.transform = CGAffineTransformIdentity;
    }
    
//    [self resetVisibleCells:finished];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardView:didDragCardViewCell:finished:)]) {
        [self.delegate cardView:self didDragCardViewCell:movingCell finished:finished];
    }
    
    [self.visibleCells removeObject:movingCell];
}

//- (void)resetVisibleCells:(BOOL)success{
//    NSInteger count = self.visibleCells.count;
//
//    if (success) {
//        if (count <= 0) {
//            return;
//        }
//        IVCardViewCell *firstCell = [self.visibleCells objectAtIndex:0];
//        firstCell.frame = self.originalFrameOfFirstCell;
//        if (count <= 1) {
//            return;
//        }
//        IVCardViewCell *secondCell = [self.visibleCells objectAtIndex:1];
//        secondCell.frame = self.originalFrameOfFirstCell;
//        if (count <= 2) {
//            return;
//        }
//        IVCardViewCell *thirdCell = [self.visibleCells objectAtIndex:2];
//        thirdCell.frame = self.originalFrameOfSecondCell;
//    }else{
//        if (count <= 0) {
//            return;
//        }
//        IVCardViewCell *firstCell = [self.visibleCells objectAtIndex:0];
//        firstCell.frame = self.originalFrameOfFirstCell;
//        if (count <= 1) {
//            return;
//        }
//        IVCardViewCell *secondCell = [self.visibleCells objectAtIndex:1];
//        secondCell.frame = self.originalFrameOfSecondCell;
//        if (count <= 2) {
//            return;
//        }
//        IVCardViewCell *thirdCell = [self.visibleCells objectAtIndex:2];
//        thirdCell.frame = self.originalFrameOfThirdCell;
//    }
//}

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

//- (NSMutableArray *)reusableCells{
//    if (!_reusableCells) {
//        _reusableCells = [[NSMutableArray alloc]init];
//    }
//    return _reusableCells;
//}

- (IVReusableCellManager *)reusableCellManager{
    if (!_reusableCellManager) {
        _reusableCellManager = [[IVReusableCellManager alloc]init];
    }
    return _reusableCellManager;
}

@end
