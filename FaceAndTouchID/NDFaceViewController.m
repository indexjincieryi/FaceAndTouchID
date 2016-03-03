//
//  NDFaceViewController.m
//  FaceAndTouchID
//
//  Created by NDMAC on 16/3/2.
//  Copyright © 2016年 NDEducation. All rights reserved.
//

#import "NDFaceViewController.h"

#import "NDFaceTool.h"
#import "NDFaceModel.h"

@interface NDFaceViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation NDFaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)identifyFace:(id)sender {
    
    [self.imageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NDFaceTool *tool = [[NDFaceTool alloc] initFaceWithImageView:self.imageView Block:^(BOOL success, NSArray *faceArray) {
        
        for (NDFaceModel *model in faceArray)
        {
            //识别出的人脸
            UIView *face = [[UIView alloc]initWithFrame:CGRectFromString(model.faceFrameString)];
            face.backgroundColor = [UIColor redColor];
            face.alpha = 0.6;
            [self.imageView addSubview:face];
            
            //识别出的左眼
            UIView *leftEye = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
            leftEye.center = CGPointFromString(model.leftEyePointString);
            leftEye.backgroundColor = [UIColor blueColor];
            leftEye.alpha = 0.6;
            [self.imageView addSubview:leftEye];
            
            //识别出的右眼
            UIView *rightEye = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
            rightEye.center = CGPointFromString(model.rightEyePointString);
            rightEye.backgroundColor = [UIColor yellowColor];
            rightEye.alpha = 0.6;
            [self.imageView addSubview:rightEye];
            
            //识别出的嘴
            UIView *mouth = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
            mouth.center = CGPointFromString(model.mouthPointString);
            mouth.backgroundColor = [UIColor greenColor];
            mouth.alpha = 0.6;
            [self.imageView addSubview:mouth];
            
            NSLog(@"是否微笑%d__左眼是否闭上%d__右眼是否闭上%d",model.isSmile,model.isLeftEyeClosed,model.isRightEyeClosed);
        }
    }];
    
    tool = nil;
}

@end
