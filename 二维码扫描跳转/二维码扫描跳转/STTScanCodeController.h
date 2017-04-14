//
//  STTScanCodeController.h
//  二维码扫描跳转
//
//  Created by user on 16/11/4.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STTScanCodeController;
@protocol STTScanCodeControllerDelegate <NSObject>

-(void)scanCodeController:(STTScanCodeController *)scanCodeController codeInfo:(NSString*)codeInfo;

@end


//二维码、条形码扫描控制器
@interface STTScanCodeController : UIViewController


//扫描回调代理人
@property(nonatomic,weak) id<STTScanCodeControllerDelegate> scanDelegate;

//扫描构造器
+(instancetype)scanCodeController;


@end
