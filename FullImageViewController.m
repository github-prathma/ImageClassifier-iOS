//
//  FullImageViewController.m
//  tf_ios_makefile_example
//
//  Created by Javed Khan on 21/04/17.
//  Copyright © 2017 Google. All rights reserved.
//

#import "FullImageViewController.h"

@interface FullImageViewController ()

@property (strong, nonatomic) UIImage* assetIm;
@end

@implementation FullImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(shareTapped)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView* imageV = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:imageV];
    imageV.contentMode = UIViewContentModeScaleAspectFit;
    
    PHImageRequestOptions* opt = [[PHImageRequestOptions alloc] init];
    opt.synchronous = YES;
    opt.resizeMode   = PHImageRequestOptionsResizeModeFast;
    
    PHImageManager* imgManager = [PHImageManager defaultManager];
    
    [imgManager requestImageForAsset:self.asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:opt resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        imageV.image = result;
        self.assetIm = result;
    }];

}


- (void)shareTapped {
    NSMutableArray* sharedObj = [NSMutableArray new];
    [sharedObj addObject:self.assetIm];
    
    UIActivityViewController* acvc = [[UIActivityViewController alloc] initWithActivityItems:sharedObj applicationActivities:nil];
    [self presentViewController:acvc animated:YES completion:nil];
}

@end
