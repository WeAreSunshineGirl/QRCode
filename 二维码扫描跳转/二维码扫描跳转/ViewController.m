//
//  ViewController.m
//  二维码扫描跳转
//
//  Created by user on 16/11/4.
//  Copyright © 2016年 user. All rights reserved.
//

#import "ViewController.h"
#import "STTScanView.h"
#import "STTScanCodeController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<STTScanViewDelegate,STTScanCodeControllerDelegate>
@property (nonatomic, strong) STTScanView * scanView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.scanView stop];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [self.scanView stop];
    
}

- (IBAction)zhijiesaomiao:(id)sender {
    [self.view addSubview:self.scanView];
    [self.scanView start];
}
- (IBAction)tiaozhuansaomiao:(id)sender {
    [self.scanView removeFromSuperview];
    STTScanCodeController *scanCodeController = [STTScanCodeController scanCodeController];
    scanCodeController.scanDelegate = self;
    [self.navigationController pushViewController:scanCodeController animated:YES];
}

#pragma mark getter
//懒加载扫描view
-(STTScanView *)scanView{
    if (!_scanView) {
        _scanView = [STTScanView scanViewShowInController:self];
        
    }
    return _scanView;
}
#pragma mark 实现代理方法
//返回扫描结果
-(void)scanView:(STTScanView *)scanView codeInfo:(NSString *)codeInfo{
    NSURL *url = [NSURL URLWithString:codeInfo];
    if ([[UIApplication sharedApplication]canOpenURL:url]) {
        [[UIApplication  sharedApplication]openURL:url];
    }else{

        //        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle: @"警告" message: [NSString stringWithFormat: @"%@:%@", @"无法解析的二维码", codeInfo] delegate: nil cancelButtonTitle: @"确定" otherButtonTitles: nil];
        //        [alertView show];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat: @"%@:%@", @"无法解析的二维码", codeInfo] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancle];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)scanCodeController:(STTScanCodeController *)scanCodeController codeInfo:(NSString *)codeInfo
{
    NSURL *url = [NSURL URLWithString:codeInfo];
    if ([[UIApplication sharedApplication]canOpenURL:url]) {
        [[UIApplication  sharedApplication]openURL:url];
    }else{
//        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle: @"警告" message: [NSString stringWithFormat: @"%@:%@", @"无法解析的二维码", codeInfo] delegate: nil cancelButtonTitle: @"确定" otherButtonTitles: nil];
//        [alertView show];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat: @"%@:%@", @"无法解析的二维码", codeInfo] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancle];
        [self presentViewController:alert animated:YES completion:nil];
    }

}
@end
