#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


@interface AssetGridViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *savedImagesCollectionView;

@end
