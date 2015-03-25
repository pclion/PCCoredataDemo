//
//  PCPeople.h
//  PCCoredataDemo
//
//  Created by 张培创 on 15/3/25.
//  Copyright (c) 2015年 com.duowan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PCManagedObject.h"

@interface PCPeople : PCManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSNumber * height;

@end
