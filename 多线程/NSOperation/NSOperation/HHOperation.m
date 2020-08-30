//
//  HHOperation.m
//  NSOperation
//
//  Created by Hu, Yuping on 2020/7/4.
//  Copyright © 2020 yunna. All rights reserved.
//

#import "HHOperation.h"

@implementation HHOperation

- (void)main {
    if (!self.isCancelled) {
      for (int i = 0; i < 2; i++) {
        NSLog(@"当前线程：%@", [NSThread currentThread]);
      }
    }
}

@end
