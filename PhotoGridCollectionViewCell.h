//
//  PhotoGridCollectionViewCell.h
//  tf_ios_makefile_example
//
//  Created by Javed Khan on 21/04/17.
//  Copyright © 2017 Google. All rights reserved.
//

#import <UIKit/UIKit.h>

@import PhotosUI;

@interface PhotoGridCollectionViewCell : UICollectionViewCell

@property (strong,nonatomic) PHAsset *imageAsset;

@property (strong,nonatomic) UIImage *imageObject;

@property (strong,nonatomic) UIImageView *profileImage;

@end
