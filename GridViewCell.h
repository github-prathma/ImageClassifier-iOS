/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A collection view cell that displays a thumbnail image.
 */

#import "GenericImageCell.h"

@import UIKit;
@import Photos;


@interface GridViewCell : GenericImageCell

@property (weak, nonatomic) IBOutlet UIImageView *selectedImageTick;
-(void)setSelection:(BOOL)selected ;
@end
