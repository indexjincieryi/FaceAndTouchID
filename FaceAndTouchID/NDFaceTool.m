//
//  NDFaceTool.m
//  FaceAndTouchID
//
//  Created by NDMAC on 16/3/2.
//  Copyright © 2016年 NDEducation. All rights reserved.
//

#import "NDFaceTool.h"

#import <CoreImage/CoreImage.h>
#import <LocalAuthentication/LocalAuthentication.h>

#import "NDFaceModel.h"

@interface NDFaceTool ()

//人脸识别block
@property(nonatomic,copy)void(^faceBlock)(BOOL,NSArray*);
//人脸识别的imageView
@property(nonatomic,assign)UIImageView*imageView;

//指纹block
@property(nonatomic,copy)void(^touchIDBlock)(TouchIDResult);

@end

@implementation NDFaceTool

-(instancetype)initTouchIDWithBlock:(void(^)(TouchIDResult))block
{
    self = [super init];
    if (self) {
        self.touchIDBlock = block;
        
        [self configTouchID];
    }
    
    return self;
}

- (void)configTouchID
{
    if ([[UIDevice currentDevice].systemVersion floatValue]<8.0) {
        if (self.touchIDBlock) {
            self.touchIDBlock(TouchIDDeviceError);
        }
        return;
    }
    
    //创建touchID功能
    LAContext*context=[[LAContext alloc]init];
    NSError*error=nil;
    
    //判断是否能启动指纹功能
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        //启动指纹验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请验证指纹" reply:^(BOOL success, NSError *error) {
            //由于本身验证touchID是一个弹框，所以在这里我们是无法在启动一个弹框的
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.touchIDBlock) {
                        self.touchIDBlock(TouchIDCheckSucceed);
                    }
                });
            }else{
                switch (error.code) {
                    case -2:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.touchIDBlock) {
                                self.touchIDBlock(TouchIDCheCkCancel);
                            }
                        });
                    }
                        break;

                    case -3:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.touchIDBlock) {
                                self.touchIDBlock(TouchIDInputPassWord);
                            }
                        });
                    }
                        break;

                    default:
                        break;
                }
            }
        }];
    }else{
        if (self.touchIDBlock) {
            self.touchIDBlock(TouchIDDeviceError);
        }
    }
}

-(instancetype)initFaceWithImageView:(UIImageView*)imageView Block:(void(^)(BOOL,NSArray*))block
{
    self = [super init];
    if (self) {
        self.faceBlock = block;
        self.imageView = imageView;
        
        [self configFace];
    }
    
    return self;
}

-(void)configFace
{
    if (!self.imageView) {
        self.faceBlock = nil;
        return;
    }
    
    //先缩减image到预定尺寸
    //计算尺寸横向还是纵向缩放
    UIGraphicsBeginImageContext(CGSizeMake(self.imageView.bounds.size.width , self.imageView.bounds.size.height));
    [self.imageView.image drawInRect:CGRectMake(0, 0, self.imageView.bounds.size.width, self.imageView.bounds.size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.imageView.image = scaledImage;
    
    //识别
    //因为识别需要时间，所以需要进行异步操作
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CIImage *image = [CIImage imageWithCGImage:self.imageView.image.CGImage];
        //此处是CIDetectorAccuracyHigh，若用于real-time的人脸检测，则用CIDetectorAccuracyLow，更快，误差更大
        NSDictionary *options = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh
                                                          forKey:CIDetectorAccuracy];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                  context:nil
                                                  options:options];
        
        //识别，直接返回结果，但是整个识别过程是同步，所以我们让他整个在异步中进行
        NSArray* features = [detector featuresInImage:image];
        
        if (0 == [features count]) {
            //回归主线程刷新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.faceBlock) {
                    self.faceBlock(NO,features);
                }
            });
        }else{
            //遍历位置
            NSMutableArray*detectArray=[NSMutableArray arrayWithCapacity:10];
            for (CIFaceFeature *feature in features)
            {
                NDFaceModel *model = [[NDFaceModel alloc]init];
                //检测表情
                model.isSmile = feature.hasSmile;
                model.isLeftEyeClosed = feature.leftEyeClosed;
                model.isRightEyeClosed = feature.rightEyeClosed;
                
                //旋转180，仅y
                CGRect faceRect = feature.bounds;
                faceRect.origin.y = self.imageView.bounds.size.height - faceRect.size.height - faceRect.origin.y;
                model.faceFrameString=NSStringFromCGRect(faceRect);
                
                //识别左眼
                if (feature.hasLeftEyePosition){
                    //旋转180，仅y
                    CGPoint newCenter = feature.leftEyePosition;
                    newCenter.y = self.imageView.bounds.size.height-newCenter.y;
                    model.leftEyePointString = NSStringFromCGPoint(newCenter);
                }
                //识别右眼
                if (feature.hasRightEyePosition)
                {
                    //旋转180，仅y
                    CGPoint newCenter = feature.rightEyePosition;
                    newCenter.y = self.imageView.bounds.size.height-newCenter.y;
                    model.rightEyePointString = NSStringFromCGPoint(newCenter);
                }
                //识别嘴
                if (feature.hasMouthPosition)
                {
                    //旋转180，仅y
                    CGPoint newCenter =  feature.mouthPosition;
                    newCenter.y = self.imageView.bounds.size.height-newCenter.y;
                    model.mouthPointString = NSStringFromCGPoint(newCenter);
                }
                //把坐标模型追加到数组中，通过block回调
                [detectArray addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.faceBlock) {
                    self.faceBlock(YES,detectArray);
                }
            });
        }
    });
}

@end
