/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * Created by james <https://github.com/mystcolor> on 9/28/11.
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDecoder.h"

@implementation UIImage (ForceDecode)

+ (UIImage *)decodedImageWithImage:(UIImage *)image {
    // do not decode animated images
    if (image.images) { return image; }
    
    CGImageRef imageRef = image.CGImage;
    
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(imageRef);
    BOOL anyAlpha = (alpha == kCGImageAlphaFirst ||
                     alpha == kCGImageAlphaLast ||
                     alpha == kCGImageAlphaPremultipliedFirst ||
                     alpha == kCGImageAlphaPremultipliedLast);
    
    if (anyAlpha) { return image; }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // current
    CGColorSpaceModel imageColorSpaceModel = CGColorSpaceGetModel(CGImageGetColorSpace(imageRef));
    CGColorSpaceRef colorspaceRef = CGImageGetColorSpace(imageRef);
    
    bool unsupportedColorSpace = (imageColorSpaceModel == 0 || imageColorSpaceModel == -1 || imageColorSpaceModel == kCGColorSpaceModelIndexed);
    if (unsupportedColorSpace)
        colorspaceRef = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, width,
                                                 height,
                                                 CGImageGetBitsPerComponent(imageRef),
                                                 0,
                                                 colorspaceRef,
                                                 kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(context);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
    
    if (unsupportedColorSpace)
        CGColorSpaceRelease(colorspaceRef);
    
    CGContextRelease(context);
    CGImageRelease(imageRefWithAlpha);
    
    if (imageWithAlpha == nil)
        return image;
    
    return imageWithAlpha;
}

@end
