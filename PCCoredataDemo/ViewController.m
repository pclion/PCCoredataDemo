//
//  ViewController.m
//  PCCoredataDemo
//
//  Created by 张培创 on 15/3/25.
//  Copyright (c) 2015年 com.duowan. All rights reserved.
//

#import "ViewController.h"
#import "PCCoredata.h"
#import "PCPeople.h"

@interface ViewController ()
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UILabel *showLabel;

- (IBAction)showAction:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"PCPeople"];
    PCPeople *people = [[self.managedObjectContext executeFetchRequest:request error:nil] firstObject];
    if (people) {
        self.showLabel.text = people.name;
    }
    if (!people) {
        people = [NSEntityDescription insertNewObjectForEntityForName:@"PCPeople" inManagedObjectContext:self.managedObjectContext];
    }
    people.name = @"李四";
//    [self.managedObjectContext refreshObject:people mergeChanges:NO];
//    [people removeFromContext];
    [PCPeople save:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showAction:(id)sender {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"PCPeople"];
    PCPeople *people = [[self.managedObjectContext executeFetchRequest:request error:nil] firstObject];
    if (people) {
        self.showLabel.text = people.name;
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [[PCCoredata shareInstance] mainManagedObjectContext];
}

@end
