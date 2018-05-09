//
//  IVCardViewCell.h
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/9.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,IVCardViewCellStyle) {
    IVCardViewCellStyleDefault,
};

@interface IVCardViewCell : UIView

@property (nonatomic, readonly, copy, nullable) NSString *reuseIdentifier;

//If the cell can be reused, you must pass in a reuse identifier.  You should use the same reuse identifier for all cells of the same form.
- (instancetype)initWithStyle:(IVCardViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier;

@property (nonatomic,strong,readonly) UILabel *titleLabel;

@end

NS_ASSUME_NONNULL_END
