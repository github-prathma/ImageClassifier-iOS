//
//  MainViewController.m
//  tf_ios_makefile_example
//
//  Created by Javed Khan on 20/04/17.
//  Copyright © 2017 Google. All rights reserved.
//

#import "MainViewController.h"
#import "RunModelViewController.h"

@import PhotosUI;

@interface MainViewController ()

@property (strong, nonatomic) PHImageRequestOptions* requestOptions;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    dispatch_group_t grp = dispatch_group_create();
    self.requestOptions = [[PHImageRequestOptions alloc] init];
    self.requestOptions.synchronous = YES;
    self.requestOptions.resizeMode   = PHImageRequestOptionsResizeModeFast;
//    self.requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;

    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult<PHAsset *> *photos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    NSLog(@"%lu",photos.count);
    NSMutableArray *image_array = [NSMutableArray array];
    NSMutableArray *asset_array = [NSMutableArray array];
    PHImageManager *manager = [PHImageManager defaultManager];

    [photos enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 100) {
            *stop = true;
            return;
        }
        dispatch_group_enter(grp);
//        NSLog(@"%lu",idx);
//        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
//            [obj requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
//                NSLog(@"Inblock");
//                if (contentEditingInput && contentEditingInput.fullSizeImageURL) {
//                    NSLog(@"%@",contentEditingInput.fullSizeImageURL);
//                    NSString *fileUrl = contentEditingInput.fullSizeImageURL.absoluteString;
//                    NSString *filePath = [fileUrl stringByReplacingOccurrencesOfString:@"file://" withString:@""];
//                    [photos_path addObject:filePath];
//                }
//                dispatch_group_leave(grp);
//            }];
//        }
        [manager requestImageForAsset:obj targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeDefault options:self.requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            NSLog(@"Inblock");
            if (result) {
                NSLog(@"valid result");
                [image_array addObject:result];
                [asset_array addObject:obj];
            }
            dispatch_group_leave(grp);
        }];
    }];
    
    dispatch_group_notify(grp, dispatch_get_main_queue(), ^{
        RunModelViewController *vc = [[RunModelViewController alloc] init];
        vc.view.frame = self.view.frame;
        vc.imageArray = image_array;
        vc.assetArray = asset_array;
        [self.view addSubview:vc.view];
        [self addChildViewController:vc];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
