//
//  STTScanView.m
//  二维码扫描跳转
//
//  Created by user on 16/11/4.
//  Copyright © 2016年 user. All rights reserved.
//

#import "STTScanView.h"
#import <AVFoundation/AVFoundation.h>

 NSString *const STTSuccessScanQRCodeNotification = @"STTSuccessScanQRCodeNotification";

 NSString *const STTScanQRCodeMessageKey = @"STTScanQRCodeMessageKey";

#define SCANSPCEOFFSET 0.15f
#define REMINDTEXT @"将二维码条码放入框即可自动扫描"
#define SCREENBOUNDS [UIScreen mainScreen].bounds
#define SCREENWIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define SCREENHEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)

@interface STTScanView()<AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic,strong) AVCaptureSession *session;
@property(nonatomic,strong) AVCaptureDeviceInput *input;
@property(nonatomic,strong) AVCaptureMetadataOutput *output;
@property(nonatomic,strong) AVCaptureVideoPreviewLayer *scanViewLayer;

@property(nonatomic,strong) CAShapeLayer *maskLayer;
@property(nonatomic,strong) CAShapeLayer *shadowLayer;
@property(nonatomic,strong) CAShapeLayer *scanRectLayer;

@property(nonatomic,assign) CGRect scanRect;
@property(nonatomic,strong) UILabel *remind;



//上下移动绿色的线条
@property(nonatomic,strong)UIView *QRCodeLine;
@property(nonatomic,strong)NSTimer *timer;

@end
@implementation STTScanView
#pragma mark initial
+(instancetype)scanViewShowInController:(UIViewController *)controller{
    if (!controller) {
        return nil;
    }
    STTScanView *scanView = [[STTScanView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    if ([controller conformsToProtocol:@protocol(STTScanViewDelegate) ]) {
        scanView.delegate = (UIViewController<STTScanViewDelegate>*)controller;
    }
    return scanView;
}
-(instancetype)initWithFrame:(CGRect)frame{
    frame = SCREENBOUNDS;
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2f];
        
        [self.layer addSublayer:self.scanViewLayer];
        [self setupScanRect];
        [self addSubview:self.remind];
        [self addSubview:self.QRCodeLine];

        self.layer.masksToBounds = YES;
        

    }
    return self;
}
















#pragma mark life
//释放前停止会话
-(void)dealloc{
    [self stop];
}
#pragma mark 操作开始 结束
//开始视频会话
-(void)start{
    [self.session startRunning];
}
//停止视频会话
-(void)stop{
    [self.session stopRunning];
}
#pragma mark 懒加载
//会话对象
-(AVCaptureSession *)session{
    if (!_session) {
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];//高质量采集
        [self setupIODevice];
    }
    return  _session;
}

//视频输入设备
-(AVCaptureDeviceInput *)input{
    if (!_input) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    }
    return _input;
}

//视频输出对象
-(AVCaptureMetadataOutput *)output{
    if (!_output) {
        _output = [[AVCaptureMetadataOutput alloc]init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
    }
    return _output;
}
//扫描视图
-(AVCaptureVideoPreviewLayer *)scanViewLayer{
    if (!_scanViewLayer) {
        _scanViewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _scanViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _scanViewLayer.frame = self.bounds;
        
    }
    return _scanViewLayer;
}
#pragma mark  common
//扫描范围
-(CGRect)scanRect{
    if (CGRectEqualToRect(_scanRect, CGRectZero)) {
        CGRect rectOfInterest = self.output.rectOfInterest;
        CGFloat yOffset = rectOfInterest.size.width - rectOfInterest.origin.x;
        CGFloat xOffset = 1 - 2 * SCANSPCEOFFSET;
        _scanRect = CGRectMake(rectOfInterest.origin.y * SCREENWIDTH, rectOfInterest.origin.x * SCREENHEIGHT, xOffset *SCREENWIDTH, yOffset*SCREENHEIGHT);
    }
    return _scanRect;
}
//提示文本
-(UILabel *)remind{
    if (!_remind) {
        CGRect textRect = self.scanRect;
        textRect.origin.y += CGRectGetHeight(textRect) + 20;
        textRect.size.height = 25.f;
        _remind = [[UILabel alloc]initWithFrame:textRect];
        _remind.font = [UIFont systemFontOfSize:15.f * SCREENWIDTH / 375.f];
        _remind.textColor = [UIColor whiteColor];
        _remind.textAlignment = NSTextAlignmentCenter;
        _remind.text = REMINDTEXT;
        _remind.backgroundColor = [UIColor clearColor];
    }
    return _remind;
}
#pragma mark layer
//扫描框
-(CAShapeLayer *)scanRectLayer{
    if (!_scanRectLayer) {
        CGRect scanRect = self.scanRect;
        scanRect.origin.x -= 1;
        scanRect.origin.y -= 1;
        scanRect.size.width += 2;
        scanRect.size.height +=2;
        
        _scanRectLayer = [CAShapeLayer layer];
        _scanRectLayer.path = [UIBezierPath bezierPathWithRect:scanRect].CGPath;
        _scanRectLayer.fillColor = [UIColor clearColor].CGColor;
        _scanRectLayer.strokeColor = [UIColor orangeColor].CGColor;
        
        
    }
    return _scanRectLayer;
}

//扫描绿线
-(UIView *)QRCodeLine{
    _QRCodeLine = [[UIView alloc] initWithFrame:CGRectMake(self.scanRect.origin.x + 1, self.scanRect.origin.y, self.scanRect.size.width- 1, 2)];
    _QRCodeLine.backgroundColor = [UIColor greenColor];
    
    // 先让基准线运动一次，避免定时器的时差
    [UIView animateWithDuration:1.2 animations:^{
        
        _QRCodeLine.frame = CGRectMake(self.scanRect.origin.x + 1, CGRectGetMaxY(self.scanRect), self.scanRect.size.width- 1, 2);
        
    }];
    
    [self performSelector:@selector(createTimer) withObject:nil afterDelay:0.4];
   
    return _QRCodeLine;
}

- (void)createTimer
{
    _timer=[NSTimer scheduledTimerWithTimeInterval:1.1 target:self selector:@selector(moveUpAndDownLine) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    if ([_timer isValid] == YES) {
        [_timer invalidate];
        _timer = nil;
    }
    
}

// 滚来滚去 :D :D :D
- (void)moveUpAndDownLine
{
    CGFloat YY = _QRCodeLine.frame.origin.y;
    
    if (YY != CGRectGetMaxY(self.scanRect) ) {
        [UIView animateWithDuration:1.2 animations:^{
            _QRCodeLine.frame = CGRectMake(self.scanRect.origin.x + 1, CGRectGetMaxY(self.scanRect), self.scanRect.size.width- 1, 2);
        }];
    }else {
        [UIView animateWithDuration:1.2 animations:^{
          _QRCodeLine.frame = CGRectMake(self.scanRect.origin.x + 1, self.scanRect.origin.y
                                         , self.scanRect.size.width- 1, 2);
        }];
        
    }
}






//阴影层
-(CAShapeLayer *)shadowLayer{
    if (!_scanRectLayer) {
        _shadowLayer = [CAShapeLayer layer];
        _shadowLayer.path = [UIBezierPath bezierPathWithRect: self.bounds].CGPath;
        _shadowLayer.fillColor = [UIColor colorWithWhite: 0 alpha: 0.75].CGColor;
        _shadowLayer.mask = self.maskLayer;
    }
    return _shadowLayer;
}
//遮掩层
-(CAShapeLayer *)maskLayer{
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer = [self generateMaskLayerWithRect:SCREENBOUNDS exceptRect:self.scanRect];
    }
    return _maskLayer;
}
#pragma mark generate
//生成空缺部分的rect的layer
-(CAShapeLayer *)generateMaskLayerWithRect:(CGRect)rect exceptRect:(CGRect)exceptRect{
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    if (!CGRectContainsRect(rect, exceptRect)) {
        return nil;
    }else if (CGRectEqualToRect(rect, CGRectZero)){
        maskLayer.path = [UIBezierPath bezierPathWithRect:rect].CGPath;
        return maskLayer;
    }
    
    CGFloat boundsInitX = CGRectGetMinX(rect);
    CGFloat boundsInitY = CGRectGetMinY(rect);
    CGFloat boundsWidth = CGRectGetWidth(rect);
    CGFloat boundsHeight = CGRectGetHeight(rect);
    
    CGFloat minX = CGRectGetMinX(exceptRect);
    CGFloat maxX = CGRectGetMaxX(exceptRect);
    CGFloat minY = CGRectGetMinY(exceptRect);
    CGFloat maxY = CGRectGetMaxY(exceptRect);
    CGFloat width = CGRectGetWidth(exceptRect);
    //添加路径
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(boundsInitX, boundsInitY, minX, boundsHeight)];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(minX, boundsInitY, width, minY)]];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(maxX, boundsInitY, boundsWidth - maxX, boundsHeight)]];
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(minX, maxY, width, boundsHeight - maxY)]];
    maskLayer.path = path.CGPath;
    return maskLayer;
    
}
#pragma mark setup
//配置输入输出设置
-(void)setupIODevice{
    if ([self.session canAddInput:self.input]) {
        [_session addInput:_input];
    }
    if ([self.session canAddOutput:self.output]) {
        [_session addOutput:_output];
        _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code];
    }
}

//配置扫描范围
-(void)setupScanRect{
    CGFloat size = SCREENWIDTH *(1 - 2* SCANSPCEOFFSET);
    CGFloat minY = (SCREENHEIGHT - size) * 0.5 / SCREENHEIGHT;
    CGFloat maxY = (SCREENHEIGHT + size) * 0.5 / SCREENHEIGHT;
    self.output.rectOfInterest = CGRectMake(minY, SCANSPCEOFFSET, maxY, 1 - SCANSPCEOFFSET * 2);
    [self.layer addSublayer:self.shadowLayer];
    [self.layer addSublayer:self.scanRectLayer];
    
}

#pragma mark touch
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self stop];
    [self stopTimer];
    [self removeFromSuperview];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [self stop];
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        if ([self.delegate respondsToSelector:@selector(scanView:codeInfo:)]) {
            [self.delegate scanView:self codeInfo:metadataObject.stringValue];
            
            [self stopTimer];
            
            [self removeFromSuperview];
        }else{
            [[NSNotificationCenter defaultCenter]postNotificationName:STTSuccessScanQRCodeNotification object:self userInfo:@{STTScanQRCodeMessageKey:metadataObject.stringValue}];
        }
    }
    NSLog(@"%f",CGRectGetMaxY(self.scanRectLayer.frame));

}





@end
