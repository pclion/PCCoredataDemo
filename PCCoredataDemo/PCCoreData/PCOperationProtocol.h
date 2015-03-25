//
//  PCOperationProtocol.h
//  rtquiz
//
//  Created by 张培创 on 14-10-13.
//  Copyright (c) 2014年 com.duowan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCCoredata.h"

typedef void(^ListResult)(NSArray* result, NSError *error);
typedef void(^ObjectResult)(id result, NSError *error);

@protocol PCOperationProtocol <NSObject>

/*
 *  主线程下创建对象
 */
+ (instancetype)createNewObject;

/*
 *  在其他context下创建对象
 */
+ (instancetype)createNewObjectInContext:(NSManagedObjectContext *)context;

/*
 *  主线程下保存方法
 */
+ (NSError*)save:(OperationResult)handler;

/*
 *  主线程下查询方法 会阻塞
 */
+ (NSArray*)filterWithPredicate:(NSString *)predicate orderby:(NSArray *)orders offset:(int)offset limit:(int)limit;

/*
 *  主线程下查询方法 不会阻塞，结果以block形式返回
 */
+ (void)filter:(NSString *)predicate orderby:(NSArray *)orders offset:(int)offset limit:(int)limit on:(ListResult)handler;

/*
 *  主线程下查询单个对象方法 会阻塞
 */
+ (id)oneObject:(NSString*)predicate;

/*
 *  主线程下查询单个方法 不会阻塞，结果以block形式返回
 */
+ (void)oneObject:(NSString*)predicate on:(ObjectResult)handler;

/*
 *  主线程下删除自身对象方法
 */
- (void)removeFromContext;

@end
