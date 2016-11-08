//
//  uexImageAlbumPickerController.m
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "uexImageAlbumPickerController.h"
#import "uexImageAlbumCell.h"
#import "MWPhotoBrowser.h"
#import "uexImagePhotoPicker.h"

@interface uexImageAlbumPickerController ()

@property (nonatomic,strong)UITableView *tableView;

@end

@implementation uexImageAlbumPickerController

-(instancetype)initWithModel:(uexImageAlbumPickerModel *)model{
    self=[super init];
    if(self){
        self.model=model;
        self.photoPicker=[[uexImagePhotoPicker alloc]initWithController:self];
        
        @weakify(self);
        [[RACObserve(self.model, needReloadData)
           distinctUntilChanged]
         subscribeNext:^(id x) {
            @strongify(self);
            if(self.tableView && self.model.needReloadData){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    self.model.needReloadData=NO;
                });
            }
        }];
        
        [self setupNavigationItems];
        [self setupToolbarItems];
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationBar *navBar=self.navigationController.navigationBar;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    navBar.tintColor = [UIColor whiteColor];
    navBar.barTintColor =nil;
    navBar.shadowImage = nil;
    navBar.translucent = YES;
    navBar.barStyle = UIBarStyleDefault;
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController setToolbarHidden:NO animated:YES];
    

    CGRect navFrame=navBar.frame;
    //CGFloat startHeight=navFrame.origin.y+navFrame.size.height;
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, navFrame.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];

    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.tableView registerClass:[uexImageAlbumCell class] forCellReuseIdentifier:@"uexImageAlbumCell"];
    self.tableView.backgroundColor=[UIColor whiteColor];
    self.view.frame=self.tableView.frame;
    [self.view addSubview:self.tableView];


    //self.navigationItem
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    @weakify(self);
    [[RACObserve(self.model, needToShowCannotFinishToast)
       filter:^BOOL(id value) {
        return ([value boolValue]);
    }]
     subscribeNext:^(id x) {
        @strongify(self);
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.view makeToast:self.model.selectInfoString duration:0.5 position:CSToastPositionCenter];
             [self.model setNeedToShowCannotFinishToast:NO];
         });
    }];
}

#pragma mark - NavigationBar

-(void)setupNavigationItems{

    
    
    UIBarButtonItem *cancelItem =[[UIBarButtonItem alloc]init];
    [cancelItem setTitle:UEXIMAGE_LOCALIZEDSTRING(@"cancel")];
    [cancelItem setTintColor:[UIColor blueColor]];
    
    cancelItem.rac_command=self.model.cancelCommand;
    self.navigationItem.leftBarButtonItem=cancelItem;
    
    
    UIBarButtonItem *confirmItem =[[UIBarButtonItem alloc]init];
    [confirmItem setTitle:UEXIMAGE_LOCALIZEDSTRING(@"finish")];
    // Set appearance
    [confirmItem setTintColor:[UIColor blueColor]];
    confirmItem.rac_command=self.model.confirmCommand;
    @weakify(self);
    RAC(confirmItem,tintColor)=[RACObserve(self.model, currentSelectedNumber) map:^id(id value) {
        @strongify(self);
        if([self.model checkIfSelectedNumbersValid:[value integerValue]]){
            return [UIColor blueColor];
        }else{
            return [UIColor grayColor];
        }
    }];
    self.navigationItem.rightBarButtonItem=confirmItem;


}

#pragma mark - Toolbar


- (void)setupToolbarItems
{
    // Space
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    // Info label
    NSDictionary *attributes = @{ NSForegroundColorAttributeName: [UIColor blackColor] };
    UIBarButtonItem *infoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    infoButtonItem.enabled = NO;
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    infoButtonItem.tintColor=[UIColor redColor];
    @weakify(self);
    RAC(infoButtonItem,title)=[RACObserve(self.model, currentSelectedNumber) map:^(NSNumber *value) {
       @strongify(self);
        NSInteger number=[value integerValue];
        if(number == 0){
            [self.navigationController setToolbarHidden:YES];
            return @"";
        }else{
            [self.navigationController setToolbarHidden:NO];
          
            return [NSString stringWithFormat:UEXIMAGE_LOCALIZEDSTRING(@"selectedNumbers"),(long)self.model.currentSelectedNumber];
        }
        
    }];
    
    self.toolbarItems = @[leftSpace, infoButtonItem, rightSpace];
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.model.assetsGroups count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    uexImageAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"uexImageAlbumCell" forIndexPath:indexPath];
    [cell setupFrame];
    cell.tag = indexPath.row;

    
    // Thumbnail
    uexImagePhotoAssetGroup *assetsGroup = self.model.assetsGroups[indexPath.row];
    cell.thumbImage2.hidden = YES;
    cell.thumbImage3.hidden = YES;
    NSUInteger numberOfAssets = MIN(3, assetsGroup.assets.count);
    
    if (numberOfAssets > 0) {
        cell.thumbImage1.hidden = NO;
        cell.thumbImage1.image=((uexImagePhotoAsset *)assetsGroup.assets[0]).thumbImage;
        if(numberOfAssets >1){
            cell.thumbImage2.hidden = NO;
            cell.thumbImage2.image=((uexImagePhotoAsset *)assetsGroup.assets[1]).thumbImage;
        }
        if(numberOfAssets >2){
            cell.thumbImage3.hidden = NO;
            cell.thumbImage3.image=((uexImagePhotoAsset *)assetsGroup.assets[2]).thumbImage;
        }

        
        
    } else {
        cell.thumbImage3.hidden = NO;
        cell.thumbImage2.hidden = NO;
        
        // Set placeholder image
        UIImage *placeholderImage = [self placeholderImageWithSize:cell.thumbImage1.frame.size];
        cell.thumbImage1.image = placeholderImage;
        cell.thumbImage2.image = placeholderImage;
        cell.thumbImage3.image = placeholderImage;
    }
    
    // Album title
    cell.nameLabel.text = [assetsGroup name];
    
    // Number of photos
    cell.countLabel.text = [NSString stringWithFormat:@"%ld", (long)assetsGroup.assets.count];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"%ld",(long)indexPath.row);
    if(![self.photoPicker openWithIndex:indexPath.row]){
        [self.view makeToast:UEXIMAGE_LOCALIZEDSTRING(@"noValidPhotosInAlbumToast") duration:0.5 position:CSToastPositionCenter];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}





- (UIImage *)placeholderImageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *backgroundColor = [UIColor colorWithRed:(239.0 / 255.0) green:(239.0 / 255.0) blue:(244.0 / 255.0) alpha:1.0];
    UIColor *iconColor = [UIColor colorWithRed:(179.0 / 255.0) green:(179.0 / 255.0) blue:(182.0 / 255.0) alpha:1.0];
    
    // Background
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    // Icon (back)
    CGRect backIconRect = CGRectMake(size.width * (16.0 / 68.0),
                                     size.height * (20.0 / 68.0),
                                     size.width * (32.0 / 68.0),
                                     size.height * (24.0 / 68.0));
    
    CGContextSetFillColorWithColor(context, [iconColor CGColor]);
    CGContextFillRect(context, backIconRect);
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(backIconRect, 1.0, 1.0));
    
    // Icon (front)
    CGRect frontIconRect = CGRectMake(size.width * (20.0 / 68.0),
                                      size.height * (24.0 / 68.0),
                                      size.width * (32.0 / 68.0),
                                      size.height * (24.0 / 68.0));
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(frontIconRect, -1.0, -1.0));
    
    CGContextSetFillColorWithColor(context, [iconColor CGColor]);
    CGContextFillRect(context, frontIconRect);
    
    CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
    CGContextFillRect(context, CGRectInset(frontIconRect, 1.0, 1.0));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
