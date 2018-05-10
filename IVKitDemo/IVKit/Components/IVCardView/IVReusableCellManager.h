//
//  IVReusableCellManager.h
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/10.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVCardViewCell.h"

@interface IVReusableCellManager : NSObject

- (void)push:(IVCardViewCell *)cell;

- (IVCardViewCell *)pop:(NSString *)identifier;

@end
