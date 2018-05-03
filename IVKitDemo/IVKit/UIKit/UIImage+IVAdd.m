//
//  UIImage+IVAdd.m
//  IVKitDemo
//
//  Created by fangjiayou on 2018/5/3.
//  Copyright © 2018年 Ivan. All rights reserved.
//

#import "UIImage+IVAdd.h"

@implementation UIImage (IVAdd)

- (UIImage *)iv_imageWithCornerRadius:(CGFloat)radius{
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(self.size, NO, UIScreen.mainScreen.scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGPathRef pathRef = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius].CGPath;
    CGContextAddPath(contextRef, pathRef);
    CGContextClip(contextRef);
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (NSString *)iv_convertImageToBase64{
    NSData *data = UIImageJPEGRepresentation(self, 1.0f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}

+ (UIImage *)iv_imageWithBase64Str:(NSString *)base64Str{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *decodeImage = [UIImage imageWithData:data];
    return decodeImage;
}

@end
