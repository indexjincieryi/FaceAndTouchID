//
//  NDFaceTool.h
//  FaceAndTouchID
//
//  Created by NDMAC on 16/3/2.
//  Copyright © 2016年 NDEducation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TouchIDResult) {
    TouchIDDeviceError=0,
    TouchIDCheckSucceed,
    TouchIDCheCkCancel,
    TouchIDInputPassWord
};

@interface NDFaceTool : NSObject

-(instancetype)initFaceWithImageView:(UIImageView*)imageView Block:(void(^)(BOOL,NSArray*))block;

-(instancetype)initTouchIDWithBlock:(void(^)(TouchIDResult))block;

@end
