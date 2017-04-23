//
//  PhotoGridCollectionViewCell.m
//  tf_ios_makefile_example
//
//  Created by Javed Khan on 21/04/17.
//  Copyright © 2017 Google. All rights reserved.
//

#import "PhotoGridCollectionViewCell.h"

@implementation PhotoGridCollectionViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageAsset = nil;
    self.imageObject = nil;
    self.profileImage.image = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (YES) {
            NSLog(@"in init");
        }
        
        self.translatesAutoresizingMaskIntoConstraints = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.clipsToBounds = NO;
        self.layer.borderWidth = 1.0f;
        
        //Soure Profile view
        UIImageView* profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 122, 122)];
        [self addSubview:profileImage];
        self.profileImage = profileImage;
    }
    
    return self;
}

-(void)setImageObject:(UIImage *)imageObject {
    NSLog(@"--------------in setter");
    
    NSLog(@"in setter");
    PHImageRequestOptions* reqOp = [[PHImageRequestOptions alloc] init];
    reqOp.resizeMode = PHImageRequestOptionsResizeModeFast;
    reqOp.synchronous = YES;
    
    PHImageManager* imgMan = [PHImageManager defaultManager];
    [imgMan requestImageForAsset:self.imageAsset targetSize:CGSizeMake(122, 122) contentMode:PHImageContentModeDefault options:reqOp resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.profileImage.image = imageObject;

    }];
    NSLog(@"in setter --------------------------");
}

@end
