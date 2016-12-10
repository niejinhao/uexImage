//
//  uexImageAlbumPickerModel.m
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "uexImageAlbumPickerModel.h"
#import "uexImagePhotoAssetGroup.h"
#import <AppCanKit/AppCanKit.h>

@interface uexImageAlbumPickerModel()
@property (nonatomic,strong)NSArray *groupTypes;
@property (nonatomic,strong)RACCommand * cancelCommand;
@property (nonatomic,strong)RACCommand * confirmCommand;
@property (nonatomic,strong)RACSignal * cannotFinishPickSignal;
@end

@implementation uexImageAlbumPickerModel


- (instancetype)init{
    self = [super init];
    if(self){
        [self doInitializing];

    }
    return self;
}


- (void)doInitializing{
    self.groupTypes = @[
                      @(ALAssetsGroupSavedPhotos),
                      @(ALAssetsGroupPhotoStream),
                      @(ALAssetsGroupAlbum)
                      ];
    self.minimumSelectedNumber = 1;
    self.maximumSelectedNumber = -1;
    self.assetsLibrary = [ALAssetsLibrary new];
    self.selectedURLs = [NSMutableOrderedSet orderedSet];
    self.needReloadData = NO;
    @weakify(self);
    RAC(self,limitStatus) = [RACSignal combineLatest:@[RACObserve(self, minimumSelectedNumber),RACObserve(self, maximumSelectedNumber)] reduce:^id(NSNumber *min,NSNumber *max){
        @strongify(self);
        NSInteger minNum = [min integerValue];
        NSInteger maxNum = [max integerValue];
        if(minNum >= 1 && maxNum >= 1){
            self.selectInfoString = [NSString stringWithFormat:UEXIMAGE_LOCALIZEDSTRING(@"minAndMaxLimitInfo"),minNum ,maxNum];
            return @(uexImagePickWithBothMaxAndMinLimit);
        }else if(minNum < 1 && maxNum >= 1){
            self.selectInfoString = [NSString stringWithFormat:UEXIMAGE_LOCALIZEDSTRING(@"maxLimitInfo"),maxNum];
            return @(uexImagePickWithMaximumLimit);
        }else if(minNum >= 1 && maxNum < 1){
            self.selectInfoString = [NSString stringWithFormat:UEXIMAGE_LOCALIZEDSTRING(@"minLimitInfo"),minNum];
            return @(uexImagePickWithMinimumLimit);
        }else{
            self.selectInfoString = UEXIMAGE_LOCALIZEDSTRING(@"noLimitInfo");
            return @(uexImagePickWithNoLimit);
        }
    }];

    [self updateAssetsGroupsWithCompletion:^{
        self.needReloadData = YES;
    }];

}






- (RACCommand *)cancelCommand{
    if(!_cancelCommand){
        @weakify(self);
        _cancelCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
             @strongify(self);
            [self cancelPick];
            return [RACSignal empty];
        }];
    }
    return _cancelCommand;
}

- (RACCommand *)confirmCommand{
    if(!_confirmCommand){
        @weakify(self);
        _confirmCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            return [self materializedCheckIfSelectedAssetsValidSignal];

             

        }];
        [_confirmCommand.executionSignals subscribeNext:^(RACSignal *execution) {
            [[execution dematerialize] subscribeError:^(NSError *error) {
                self.needToShowCannotFinishToast = YES;
            } completed:^{
                [self finishPick];
            }];
        }];
    }
    return _confirmCommand;
    
}


- (RACSignal *)materializedCheckIfSelectedAssetsValidSignal{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        if([self checkIfSelectedNumbersValid:self.currentSelectedNumber]){
            [subscriber sendCompleted];
        }else{
            [subscriber sendError:NULL];
        }
        return nil;
    }]materialize];
}


- (void)cancelPick{
    if([self.delegate respondsToSelector:@selector(uexImageAlbumPickerModelDidCancelPickingAction:)]){

        [self.delegate uexImageAlbumPickerModelDidCancelPickingAction:self];

    }
}


- (void)finishPick{
    if([self.delegate respondsToSelector:@selector(uexImageAlbumPickerModel:didFinishPickingAction:)]){
        [self fetchAssetsFromSelectedAssetURLsWithCompletion:^(NSArray *assets) {
            [self.delegate uexImageAlbumPickerModel:self didFinishPickingAction:assets];
        }];
    }
}



- (BOOL)checkIfSelectedNumbersValid:(NSInteger)selectedNumbers{
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
    ALAssetsFilter *assetsFilter = [ALAssetsFilter allPhotos];

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
