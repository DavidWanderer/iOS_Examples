//
//  main.m
//  NSObject对象内存
//
//  Created by huyp on 2020/6/21.
//  Copyright © 2020年 huyp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

@interface Animal : NSObject

@property (nonatomic, assign) int age;
@property (nonatomic, assign) int weight;

@end

@implementation Animal

@end

@interface Cat : Animal
@property (nonatomic, assign) int feetCount;
@end

@implementation Cat

@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
//         NSObject *obj = [[NSObject alloc] init];
//        // 获得NSObject实例对象的成员变量所占用的大小 >> 8字节
//        NSLog(@"NSObject class_getInstance: %zd", class_getInstanceSize([NSObject class]));
//
//        // 获得obj指针所指向内存的大小 >> 16字节
//        NSLog(@"NSObject malloc_size: %zd", malloc_size((__bridge const void *)obj));
        
        
//        Animal *animal = [[Animal alloc] init];
//        animal.age = 10;
//        animal.weight = 20;
//        NSLog(@"Animal class_getInstance: %zd", class_getInstanceSize([Animal class]));
//        NSLog(@"Animal malloc_size: %zd", malloc_size((__bridge const void *)animal));

        Cat *cat = [[Cat alloc] init];
        cat.age = 5;
        cat.weight = 10;
        cat.feetCount = 4;
        NSLog(@"Cat class_getInstance: %zd", class_getInstanceSize([Cat class]));
        NSLog(@"Cat malloc_size: %zd", malloc_size((__bridge const void *)cat));
    }
    return 0;
}
