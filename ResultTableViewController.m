//
//  ResultTableViewController.m
//  tf_ios_makefile_example
//
//  Created by Javed Khan on 21/04/17.
//  Copyright © 2017 Google. All rights reserved.
//

#import "ResultTableViewController.h"
#import "PhotoGridViewController.h"

@interface ResultTableViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ResultTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [self.view addSubview:table];
    table.dataSource = self;
    table.delegate = self;
    
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.inference_result.allKeys.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"iden"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"iden"];
        NSString *keyName = self.inference_result.allKeys[indexPath.row];
        [cell.textLabel setText:[NSString stringWithFormat:@"%@ (%lu)",keyName,((NSMutableArray *)[self.inference_result objectForKey:keyName]).count]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoGridViewController *vc = [[PhotoGridViewController alloc] init];
    NSString *keyName = self.inference_result.allKeys[indexPath.row];
    vc.indexArray = [self.inference_result objectForKey:keyName];
    vc.imageArray = self.imageArray;
    vc.assetArray = self.assetArray;
    vc.imageDataArray = self.imageDataArray;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
