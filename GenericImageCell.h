//
//  GenericImageCell.h
//  SamplePhotosApp
//
//  Created by Javed Khan on 09/03/16.
//
//

#import <UIKit/UIKit.h>

@import Photos;

@interface GenericImageCell : UICollectionViewCell

@property (strong,nonatomic) PHAsset *asset;

-(void)setImageWithSize:(CGSize)size UsingImageManager:(PHCachingImageManager *) imageManager;

@end
