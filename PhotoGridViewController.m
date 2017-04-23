//
//  PhotoGridViewController.m
//  tf_ios_makefile_example
//
//  Created by Javed Khan on 21/04/17.
//  Copyright © 2017 Google. All rights reserved.
//

#import "PhotoGridViewController.h"
#import "FullImageViewController.h"
#import "PhotoGridCollectionViewCell.h"

@import PhotosUI;


@interface PhotoGridViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@end

@implementation PhotoGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UICollectionViewFlowLayout* collectionViewLayout = UICollectionViewFlowLayout.new;
    collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    collectionViewLayout.minimumInteritemSpacing = 1;
    NSLog(@"%f",self.view.frame.size.width);
//    collectionViewLayout.itemSize = CGSizeMake(self.view.frame.size.width/4, self.view.frame.size.width/4);
//    collectionViewLayout.estimatedItemSize = CGSizeMake(self.view.frame.size.width/4, self.view.frame.size.width/4);
    UICollectionView* newsCollectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:collectionViewLayout];
    [self.view addSubview:newsCollectionView];
    newsCollectionView.backgroundColor = [UIColor whiteColor];
    newsCollectionView.delegate = self;
    newsCollectionView.dataSource = self;
    newsCollectionView.collectionViewLayout = collectionViewLayout;
    [newsCollectionView registerClass:[PhotoGridCollectionViewCell class] forCellWithReuseIdentifier:@"collIden"];
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

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.indexArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoGridCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collIden" forIndexPath:indexPath];
    NSInteger indexOfActualImageAndAssetArray = [[self.indexArray objectAtIndex:indexPath.row] integerValue];
    NSLog(@"Index %ld", indexOfActualImageAndAssetArray);
    NSLog(@"Count %ld", self.imageArray.count);
    if (self.assetArray[indexOfActualImageAndAssetArray]) {
        NSLog(@"asset object present");
    }
    if (self.imageArray[indexOfActualImageAndAssetArray]) {
        NSLog(@"image object present");
    }
    cell.profileImage.image = self.imageArray[indexOfActualImageAndAssetArray];//[UIImage imageWithData:self.imageDataArray[indexOfActualImageAndAssetArray]];
//    cell.imageAsset = self.assetArray[indexOfActualImageAndAssetArray];
//    cell.imageObject = self.imageArray[indexOfActualImageAndAssetArray];
    NSLog(@"Set image done");
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FullImageViewController* vc = [[FullImageViewController alloc] init];
    NSInteger indexOfActualImageAndAssetArray = [[self.indexArray objectAtIndex:indexPath.row] integerValue];
    PHAsset *im = self.assetArray[indexOfActualImageAndAssetArray];
    vc.asset = im;
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"SETTING SIZE FOR ITEM AT INDEX %ld", indexPath.row);
    CGSize mElementSize = CGSizeMake(122, 122);
    return mElementSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}

@end
