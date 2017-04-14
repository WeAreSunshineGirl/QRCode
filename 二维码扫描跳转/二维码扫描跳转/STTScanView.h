//
//  STTScanView.h
//  二维码扫描跳转
//
//  Created by user on 16/11/4.
//  Copyright © 2016年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

//扫描成功 发送通知（在代理实现的情况下发送）
extern NSString *const STTSuccessScanQRCodeNotification;

//通知传递数据只能够存储二维码信息的关键字
extern NSString *const STTScanQRCodeMessageKey;

@class STTScanView;
@protocol STTScanViewDelegate <NSObject>

-(void)scanView:(STTScanView *)scanView codeInfo:(NSString *)codeInfo;

@end



//二维码、条形码扫描视图
@interface STTScanView : UIView
//扫描回调代理
@property(nonatomic,weak)id<STTScanViewDelegate>delegate;
//创建扫描视图 建议使用STTScanCodeController
+(instancetype)scanViewShowInController:(UIViewController*)controller;

//开始扫描
-(void)start;
//结束扫描
-(void)stop;
@end
