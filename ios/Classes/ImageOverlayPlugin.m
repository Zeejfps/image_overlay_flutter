#import "ImageOverlayPlugin.h"

@implementation ImageOverlayPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"image_overlay"
                                     binaryMessenger:[registrar messenger]];
    ImageOverlayPlugin* instance = [[ImageOverlayPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"overlayImages" isEqualToString:call.method]) {
        NSString *srcPath = call.arguments[@"src"];
        NSString *dstPath = call.arguments[@"dst"];
        UIImage *srcImg = [UIImage imageWithContentsOfFile:srcPath];
        UIImage *dstImg = [UIImage imageWithContentsOfFile:dstPath];
        
        CGFloat aspect = srcImg.size.width / srcImg.size.height;
        
        CGFloat width = dstImg.size.width * dstImg.scale;
        CGFloat height = width / aspect;
        
        UIGraphicsBeginImageContextWithOptions(dstImg.size, NO, 1.0);
        
        [dstImg drawAtPoint:CGPointZero];
        [srcImg drawInRect:CGRectMake(0, dstImg.size.height - height, width, height)];
        
        UIImage *endImg = UIGraphicsGetImageFromCurrentImageContext();
        NSData *endImgData = UIImageJPEGRepresentation(endImg, 80);
        
        [endImgData writeToFile:dstPath atomically:YES];
        
        result(@"Success!");
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
