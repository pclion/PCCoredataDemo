//
//  PCCoredata.m
//  CoredataAsync
//
//  Created by 张培创 on 14-10-13.
//  Copyright (c) 2014年 com.zhangpc. All rights reserved.
//

#import "PCCoredata.h"

@interface PCCoredata ()

@property (nonatomic, strong) NSString *modelName;
@property (nonatomic, strong) NSString *storeName;
@property (readonly, strong, nonatomic) NSManagedObjectContext *backgroundManagedObjectContext;

@end

@implementation PCCoredata

@synthesize mainManagedObjectContext = _mainManagedObjectContext;
@synthesize backgroundManagedObjectContext = _backgroundManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)shareInstance
{
    static PCCoredata *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[PCCoredata alloc] init];
    });
    return instance;
}

- (void)setUpCoreDataWithModelName:(NSString *)modelName DBFile:(NSString *)fileName
{
    self.modelName = modelName;
    self.storeName = fileName;
    [self coreDataInitialize];
}

- (void)coreDataInitialize
{
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator) {
        _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundManagedObjectContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
        _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainManagedObjectContext.parentContext = _backgroundManagedObjectContext;
    }
}

- (NSManagedObjectContext *)createPrivateManagedObjectContext
{
    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateContext.parentContext = _mainManagedObjectContext;
    return privateContext;
}

- (NSError *)save:(OperationResult)handler
{
    NSError *error;
    if ([_mainManagedObjectContext hasChanges]) {
        [_mainManagedObjectContext save:&error];
        [_backgroundManagedObjectContext performBlock:^{
            __block NSError *inner_error = nil;
            [_backgroundManagedObjectContext save:&inner_error];
            if (handler){
                [_mainManagedObjectContext performBlock:^{
                    handler(inner_error);
                }];
            }
        }];
    }
    return error;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:self.storeName];
    NSError *error = nil;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

@end
