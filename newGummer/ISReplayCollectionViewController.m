//
//  ISReplayCollectionViewController.m
//  Gummer
//
//  Created by techcamp on 2013/09/10.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import "ISReplayCollectionViewController.h"
#import "ISFullPlayViewController.h"
#import "SVProgressHUD.h"

@interface ISReplayCollectionViewController ()

@end

@implementation ISReplayCollectionViewController

@synthesize photos = _photos;


- (IBAction)cancelButtonTouched:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    
    
}

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.collectionView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_white.png"]]];
}

- (void)viewWillAppear:(BOOL)animated{
    [SVProgressHUD showWithStatus:@"ロード中..."];
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_top.png"] forBarMetrics:UIBarMetricsDefault];
    }
    // collect the photos
    NSMutableArray *collector = [[NSMutableArray alloc] initWithCapacity:0];
    ALAssetsLibrary *al = [ISReplayCollectionViewController defaultAssetsLibrary];
    
    [al enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                      usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                          [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                              if (asset) {
                                  // 動画のみ追加
                                  NSString* type = [asset valueForProperty:ALAssetPropertyType];
                                  if( [type isEqualToString:ALAssetTypeVideo] ){
                                      [collector addObject:asset];
                                  }
                              }
                          }];
                          
                          self.photos = collector;
                          [self.collectionView reloadData];
                          NSLog(@"photo count = %d",self.photos.count);
                          NSLog(@"photo = %@",self.photos);
                      }
                    failureBlock:^(NSError *error) { NSLog(@"ERROR!!!");}
     ];
    [super viewWillAppear:animated];
    
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [SVProgressHUD dismiss];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 
    
    // Dispose of any resources that can be recreated.
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //self.collectionView.allowsMultipleSelection = YES;
    NSString* identifier = @"ReplayCell";
    ISReplayCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

    if (!cell) {
        NSLog(@"Not exist");
    }
    
    ALAsset *asset = [self.photos objectAtIndex:indexPath.row];
    if (asset) {
        NSLog(@"at index = %d", indexPath.row);
        
        ALAssetRepresentation *representation = [asset defaultRepresentation];
  NSURL *url = [representation url];
        cell.url = url;
        NSLog(@"url: %@", [url absoluteString]);
        
        [cell.replayImageView setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    } else {
        NSLog(@"not found");
        [cell.replayImageView setImage:nil];
    }    
    cell.label.text = @"　";

    return cell;
}




#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"didSelectItemAtIndexPath");
    cellindex = indexPath;
    
    ISReplayCollectionViewCell *cell = (ISReplayCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:cellindex];
    
           
    NSLog(@"else");
    cell.selected = YES;
    cell.cellBackgroundView.backgroundColor = [UIColor blueColor];
    [selectedMovies addObject:@"1"];
    
    NSString *selectmsg = @"この動画を重ねますか？";
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"処理を選択" message:selectmsg delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"重ねる", nil];
    [alert addButtonWithTitle:@"再生"];
    [alert show];
    
}


-(void)alertView:(UIAlertView*)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
    ISReplayCollectionViewCell *cell = (ISReplayCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:cellindex];

    GapDictionary *dic = [GapDictionary sharedGapDictionary];
    
    switch (buttonIndex) {
        case 0:
            //1番目のボタン（cancelButtonTitle）が押されたときのアクション
            NSLog(@"1番目");
          
            cell.selected = NO;
            cell.cellBackgroundView.backgroundColor = [UIColor whiteColor];
            
            break;
            
        case 1:
            //2番目のボタンが押されたときのアクション
            NSLog(@"重ねる");
            
            //GapDictionary *dic = [GapDictionary sharedGapDictionary];
            [dic.dictionary removeAllObjects];
            [dic.dictionary setObject:cell.replayImageView.image forKey:@"thumbnail"];
            /*
             この部分の処理はこれからかく。
             選択された動画のURLを渡してあちらの再生画面に飛べるようにしておけば良い。
             */
            
            cell.selected = NO;
            cell.cellBackgroundView.backgroundColor = [UIColor whiteColor];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            
            break;
            
        case 2:
            //3番目のボタンが押されたときのアクション
            NSLog(@"3番目");
            NSLog(@"decell: %@",cell.url);
            
            //[self performSegueWithIdentifier:@"pushToFullPlayView" sender:cell.url];
            
            ISFullPlayViewController *ifpvc = [self.storyboard instantiateViewControllerWithIdentifier:@"FullPlayView"];
            ifpvc.url = cell.url;
            [self.navigationController pushViewController:ifpvc animated:YES];
            self.view.backgroundColor = [UIColor blueColor];
            
            cell.selected = NO;
            cell.cellBackgroundView.backgroundColor = [UIColor whiteColor];

            
            break;
            }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}


- (void)viewDidUnload {
    [self setCollectionView:nil];
    [self setCancelbutton:nil];
    [super viewDidUnload];
}
@end
