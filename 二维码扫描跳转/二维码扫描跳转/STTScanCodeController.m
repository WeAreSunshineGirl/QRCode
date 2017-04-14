//
//  STTScanCodeController.m
//  二维码扫描跳转
//
//  Created by user on 16/11/4.
//  Copyright © 2016年 user. All rights reserved.
//

#import "STTScanCodeController.h"
#import "STTScanView.h"
@interface STTScanCodeController ()<STTScanViewDelegate>
@property(nonatomic,strong) STTScanView * scanView;
@end

@implementation STTScanCodeController

+(instancetype)scanCodeController{
    return [[self alloc]init];
}
-(instancetype)init{
    if (self = [super init]) {
        self.scanView = [STTScanView scanViewShowInController:self];
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.scanView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.scanView start];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    [self.scanView stop];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [self.scanView stop];
}

#pragma mark 扫描成功时回调
-(void)scanView:(STTScanView *)scanView codeInfo:(NSString *)codeInfo{
    if ([_scanDelegate respondsToSelector:@selector(scanCodeController:codeInfo:)]) {
        [_scanDelegate scanCodeController:self codeInfo:codeInfo];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
         [[NSNotificationCenter defaultCenter]postNotificationName:STTSuccessScanQRCodeNotification object:self userInfo:@{STTScanQRCodeMessageKey:codeInfo}];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
