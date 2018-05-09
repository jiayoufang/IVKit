//
//  IVCardViewCell.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/9.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "IVCardViewCell.h"

@interface IVCardViewCell()

@property (nonatomic,assign) IVCardViewCellStyle style;
@property (nonatomic, readwrite, copy, nullable) NSString *reuseIdentifier;

@property (nonatomic,strong,readwrite) UILabel *titleLabel;

@end

@implementation IVCardViewCell

//- (instancetype)initWithCoder:(NSCoder *)aDecoder{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//
//    }
//    return self;
//}

- (instancetype)initWithStyle:(IVCardViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.style = style;
        self.reuseIdentifier = reuseIdentifier;
        [self defaultSetup];
    }
    return self;
}

- (void)defaultSetup{

    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 30)];
    self.titleLabel.text = @"DefaultTitle";
    [self addSubview:self.titleLabel];
    
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:10.0f];
    [self.layer setShouldRasterize:YES];
    [self.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
    
    CGFloat scaleBackgroud = 245.0f / 255.0f;
    self.backgroundColor = [UIColor colorWithRed:scaleBackgroud green:scaleBackgroud blue:scaleBackgroud alpha:1];
    
    CGFloat scaleBorder = 176.0f / 255.0f;
    [self.layer setBorderWidth:.45];
    [self.layer setBorderColor:[UIColor colorWithRed:scaleBorder green:scaleBorder blue:scaleBorder alpha:1].CGColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
