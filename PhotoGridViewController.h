//
//  PhotoGridViewController.h
//  tf_ios_makefile_example
//
//  Created by Javed Khan on 21/04/17.
//  Copyright © 2017 Google. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoGridViewController : UIViewController

@property (strong, nonatomic) NSArray* imageArray;
@property (strong, nonatomic) NSArray* assetArray;
@property (strong, nonatomic) NSArray* indexArray;
@property (strong,nonatomic) NSMutableArray *imageDataArray;


@end
