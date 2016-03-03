//
//  NDTouchIDViewController.m
//  FaceAndTouchID
//
//  Created by NDMAC on 16/3/2.
//  Copyright © 2016年 NDEducation. All rights reserved.
//

#import "NDTouchIDViewController.h"

#import "NDFaceTool.h"

@interface NDTouchIDViewController ()

@end

@implementation NDTouchIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NDFaceTool *tool = [[NDFaceTool alloc] initTouchIDWithBlock:^(TouchIDResult result) {
        switch (result) {
            case TouchIDCheCkCancel:
            {
                self.title = @"取消";
                NSLog(@"取消");
            }
                break;
            case TouchIDInputPassWord:
            {
                self.title = @"手动输入密码";
                NSLog(@"手动输入密码");
            }
                break;
            case TouchIDCheckSucceed:
            {
                self.title = @"验证成功";
                NSLog(@"验证成功");
            }
                break;
            case TouchIDDeviceError:
            {
                self.title = @"无法启动TouID";
                NSLog(@"无法启动touid");
            }
                break;
        }
    }];

    tool = nil;
}

@end
