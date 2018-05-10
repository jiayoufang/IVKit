//
//  IVCardView.h
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/9.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVCardViewCell.h"

typedef NS_OPTIONS(NSInteger, IVCardViewDirection) {
    IVCardViewDirectionNone  = 1 << 0, ///<没有移动
    IVCardViewDirectionRight = 1 << 1,
    IVCardViewDirectionLeft  = 1 << 2,
    IVCardViewDirectionUp    = 1 << 3,
    IVCardViewDirectionDown  = 1 << 4,
    IVCardViewDirectionAll = IVCardViewDirectionUp|IVCardViewDirectionDown|IVCardViewDirectionLeft|IVCardViewDirectionRight,
};

@class IVCardView;

@protocol IVCardViewDelegate<NSObject>

@optional

- (void)cardView:(IVCardView *)cardView didSelectCardViewCell:(IVCardViewCell *)cell;

- (void)cardView:(IVCardView *)cardView willDragCardViewCell:(IVCardViewCell *)cell;

- (void)cardView:(IVCardView *)cardView draggingDirection:(IVCardViewDirection)direction progress:(float)progress;

- (void)cardView:(IVCardView *)cardView didDragCardViewCell:(IVCardViewCell *)cell finished:(BOOL)finished;

@end

@protocol IVCardViewDataSource<NSObject>

@required

- (IVCardViewCell *)cardView:(IVCardView *)cardView cellAtIndex:(NSInteger)index;
- (NSInteger)numberOfCellsInCardView:(IVCardView *)cardView;

@optional

@end

@interface IVCardView : UIView

@property (nonatomic,weak) id<IVCardViewDelegate> delegate;
@property (nonatomic,weak) id<IVCardViewDataSource> dataSource;

@property (nonatomic,assign) IVCardViewDirection directions;

//@property (nonatomic,strong,readonly) NSArray<__kindof IVCardViewCell *> *visibleCells;

- (instancetype)initWithFrame:(CGRect)frame directions:(IVCardViewDirection)directions;

- (IVCardViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;// Used by the delegate to acquire an already allocated cell, in lieu of allocating a new one.

- (nullable __kindof IVCardViewCell *)cellAtIndex:(NSInteger )index;   // returns nil if cell is not visible or index path is out of range

- (void)realodData;

@end
