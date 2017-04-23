//
//  GenericImageCell.m
//  SamplePhotosApp
//
//  Created by Javed Khan on 09/03/16.
//
//

#import "GenericImageCell.h"

@interface GenericImageCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end


@implementation GenericImageCell


- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
}

-(void)setAsset:(PHAsset *)asset {
    _asset = asset;
}

-(void)setImageWithSize:(CGSize)size UsingImageManager:(PHCachingImageManager *)imageManager {
    [imageManager requestImageForAsset:self.asset
                            targetSize:size
                           contentMode:PHImageContentModeAspectFill
                               options:nil
                         resultHandler:^(UIImage *result, NSDictionary *info) {
                             self.imageView.image = result;
                         }];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

@end
