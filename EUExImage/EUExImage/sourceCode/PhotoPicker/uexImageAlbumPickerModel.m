//
//  uexImageAlbumPickerModel.m
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "uexImageAlbumPickerModel.h"
#import "uexImagePhotoAssetGroup.h"

@interface uexImageAlbumPickerModel()
@property (nonatomic,strong)NSArray *groupTypes;
@property (nonatomic,strong)RACSignal *comfirmValidSignal;
@end

@implementation uexImageAlbumPickerModel


-(instancetype)init{
    self=[super init];
    if(self){
        [self doInitializing];

    }
    return self;
}


-(void)doInitializing{
    self.groupTypes=@[
                      @(ALAssetsGroupSavedPhotos),
                      @(ALAssetsGroupPhotoStream),
                      @(ALAssetsGroupAlbum)
                      ];
    self.minimumSelectedNumber=1;
    self.maximumSelectedNumber=-1;
    self.assetsLibrary=[ALAssetsLibrary new];
    self.selectedURLs=[NSMutableOrderedSet orderedSet];
    self.needReloadData=NO;
    
    [self setupCommands];
    [self updateAssetsGroupsWithCompletion:^{
        self.needReloadData=YES;
    }];
    //@weakify(self);
    RAC(self,selectInfoString)=[RACSignal combineLatest:@[RACObserve(self, minimumSelectedNumber),RACObserve(self,maximumSelectedNumber)] reduce:^id(NSNumber *min,NSNumber *max){
        //@strongify(self);
        NSInteger minNum=[min integerValue];
        NSInteger maxNum=[max integerValue];
        if(minNum > 1 && maxNum>1){
            return [NSString stringWithFormat:@"应至少选择%@张照片，至多选择%@张照片",min,max];
        }else if(minNum <= 1 && maxNum>1){
            return [NSString stringWithFormat:@"至多应选择%@张照片",max];
        }else if(minNum > 1 && maxNum<=1){
            return [NSString stringWithFormat:@"至少应选择%@张照片",min];
        }else{
            return @"";
        }
    }];
}

-(void)setupCommands{
    @weakify(self);
    self.cancelCommand=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        NSLog(@"cancel pick");
        [self cancelPick];
        return [RACSignal empty];
    }];
    self.confirmCommand=[[RACCommand alloc]initWithEnabled:[self comfirmValidSignal] signalBlock:^RACSignal *(id input) {
        @strongify(self);
        NSLog(@"finish pick");
        [self finishPick];
        return [RACSignal empty];
    }];
}

-(void)cancelPick{
    if([self.delegate respondsToSelector:@selector(uexImageAlbumPickerModelDidCancelPickingAction:)]){

        [self.delegate uexImageAlbumPickerModelDidCancelPickingAction:self];

    }
}

-(void)finishPick{
    if([self.delegate respondsToSelector:@selector(uexImageAlbumPickerModel:didFinishPickingAction:)]){
        [self fetchAssetsFromSelectedAssetURLsWithCompletion:^(NSArray *assets) {
            [self.delegate uexImageAlbumPickerModel:self didFinishPickingAction:assets];
        }];
    }
}

-(RACSignal *)comfirmValidSignal{

    if(!_comfirmValidSignal){
        @weakify(self);
        self.comfirmValidSignal=[RACObserve(self, currentSelectedNumber) map:^id(NSNumber *value) {
            @strongify(self);
            return @([self checkIfSelectedNumbersValid:[value integerValue]]);

        }];

    }
    return _comfirmValidSignal;
}

-(BOOL)checkIfSelectedNumbersValid:(NSInteger)selectedNumbers{
    if(selectedNumbers <self.minimumSelectedNumber){
        return NO;
    }
    if(self.maximumSelectedNumber>0&&selectedNumbers>self.maximumSelectedNumber){
        return NO;
    }
    return YES;
}
- (void)updateAssetsGroupsWithCompletion:(void (^)(void))completion
{
    [self fetchAssetsGroupsWithTypes:self.groupTypes completion:^(NSArray *assetsGroups) {
        // Map assets group to dictionary
        NSMutableDictionary *mappedAssetsGroups = [NSMutableDictionary dictionaryWithCapacity:assetsGroups.count];
        for (ALAssetsGroup *assetsGroup in assetsGroups) {
            NSMutableArray *array = mappedAssetsGroups[[assetsGroup valueForProperty:ALAssetsGroupPropertyType]];
            if (!array) {
                array = [NSMutableArray array];
            }
            
            [array addObject:[[uexImagePhotoAssetGroup alloc] initWithAssetsGroup:assetsGroup inModel:self]];
            
            mappedAssetsGroups[[assetsGroup valueForProperty:ALAssetsGroupPropertyType]] = array;
        }
        
        // Pick the groups to be shown
        NSMutableArray *sortedAssetsGroups = [NSMutableArray arrayWithCapacity:self.groupTypes.count];
        
        for (NSValue *groupType in self.groupTypes) {
            NSArray *array = mappedAssetsGroups[groupType];
            
            if (array) {
                [sortedAssetsGroups addObjectsFromArray:array];
            }
        }
        
        self.assetsGroups = sortedAssetsGroups;
        
        if (completion) {
            completion();
        }
    }];
}

- (void)fetchAssetsGroupsWithTypes:(NSArray *)types completion:(void (^)(NSArray *assetsGroups))completion{
    __block NSMutableArray *assetsGroups = [NSMutableArray array];
    __block NSUInteger numberOfFinishedTypes = 0;
    
    ALAssetsLibrary *assetsLibrary = self.assetsLibrary;
    ALAssetsFilter *assetsFilter=[ALAssetsFilter allPhotos];

    for (NSNumber *type in types) {
        [assetsLibrary enumerateGroupsWithTypes:[type unsignedIntegerValue]
                                     usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
                                         if (assetsGroup) {
                                             // Apply assets filter
                                             [assetsGroup setAssetsFilter:assetsFilter];
                                             
                                             // Add assets group
                                             [assetsGroups addObject:assetsGroup];
                                         } else {
                                             numberOfFinishedTypes++;
                                         }
                                         
                                         // Check if the loading finished
                                         if (numberOfFinishedTypes == types.count) {
                                             if (completion) {
                                                 completion(assetsGroups);
                                             }
                                         }
                                     } failureBlock:^(NSError *error) {
                                         NSLog(@"Error: %@", [error localizedDescription]);
                                     }];
    }
}
- (void)fetchAssetsFromSelectedAssetURLsWithCompletion:(void (^)(NSArray *assets))completion
{
    // Load assets from URLs
    // The asset will be ignored if it is not found
    ALAssetsLibrary *assetsLibrary = self.assetsLibrary;
    NSMutableOrderedSet *selectedAssetURLs = self.selectedURLs;
    
    __block NSMutableArray *assets = [NSMutableArray array];
    
    void (^checkNumberOfAssets)(void) = ^{
        if (assets.count == selectedAssetURLs.count) {
            if (completion) {
                completion([assets copy]);
            }
        }
    };
    
    for (NSURL *assetURL in selectedAssetURLs) {
        [assetsLibrary assetForURL:assetURL
                       resultBlock:^(ALAsset *asset) {
                           if (asset) {
                               // Add asset
                               [assets addObject:asset];
                               
                               // Check if the loading finished
                               checkNumberOfAssets();
                           } else {
                               [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                   [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                       if ([result.defaultRepresentation.url isEqual:assetURL]) {
                                           // Add asset
                                           [assets addObject:result];
                                           
                                           // Check if the loading finished
                                           checkNumberOfAssets();
                                           
                                           *stop = YES;
                                       }
                                   }];
                               } failureBlock:^(NSError *error) {
                                   NSLog(@"Error: %@", [error localizedDescription]);
                               }];
                           }
                       } failureBlock:^(NSError *error) {
                           NSLog(@"Error: %@", [error localizedDescription]);
                       }];
    }
}

@end
