//
//  NDFaceModel.h
//  FaceAndTouchID
//
//  Created by NDMAC on 16/3/2.
//  Copyright © 2016年 NDEducation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NDFaceModel : NSObject

//人脸位置
@property(nonatomic, copy) NSString*faceFrameString;
//左眼位置
@property(nonatomic, copy) NSString*leftEyePointString;
//右眼位置
@property(nonatomic, copy) NSString*rightEyePointString;
//嘴巴位置
@property(nonatomic, copy) NSString*mouthPointString;
@property(nonatomic, assign) BOOL isSmile;
@property(nonatomic, assign) BOOL isLeftEyeClosed;
@property(nonatomic, assign) BOOL isRightEyeClosed;

@end
