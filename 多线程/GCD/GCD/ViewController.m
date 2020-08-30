//
//  ViewController.m
//  GCD
//
//  Created by yunna on 2018/11/5.
//  Copyright © 2018年 yunna. All rights reserved.
//

#import "ViewController.h"
#import "GCDViewController.h"

@interface ViewController ()
@property (strong, nonatomic) dispatch_semaphore_t semaphore;

@property (nonatomic, strong) dispatch_queue_t queue; // 用于barrier测试

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self interview05]; // 执行当前页面的方法
}

/// 跳转到GCD测试页面
- (IBAction)enterGCDVC:(UIButton *)sender {
    GCDViewController *gcdVC = [[GCDViewController alloc] init];
    [self.navigationController pushViewController:gcdVC animated:YES];
}

/// 同步串行队列
- (void) example0 {
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queue, ^{
        // 追加任务1
        for (int i=0; i < 2; i++) {
            NSLog(@"1---%@", [NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
       // 追加任务2
        for (int i=0; i<2; i++) {
            NSLog(@"2---%@", [NSThread currentThread]);
        }
    });
}

/// 同步并行队列
- (void) example1 {
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue, ^{
        // 追加任务1
        for (int i=0; i<2; i++) {
            NSLog(@"1---%@", [NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        // 追加任务2
        for (int i=0; i<2; i++) {
            NSLog(@"2---%@", [NSThread currentThread]);
        }
    });
}

/// 异步串行队列
- (void) example2 {
    NSLog(@"主线程：%@", [NSThread currentThread]);
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        for (int i = 0; i<2; i++) {
            NSLog(@"1=====%@", [NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i<2; i++) {
            NSLog(@"2====%@", [NSThread currentThread]);
        }
    });
}

/// 异步并行队列
- (void) example3 {
    NSLog(@"主线程：%@", [NSThread currentThread]);
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        for (int i = 0; i<2; i++) {
            NSLog(@"1=====%@", [NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i<2; i++) {
            NSLog(@"2====%@", [NSThread currentThread]);
        }
    });
}

- (void)interview01
{
    // 问题：以下代码是在主线程执行的，会不会产生死锁？会！
    NSLog(@"执行任务1");
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        NSLog(@"执行任务2");
    });
    
    NSLog(@"执行任务3");
   
}

- (void)interview02
{
    // 问题：以下代码是在主线程执行的，会不会产生死锁？不会！
    NSLog(@"执行任务1");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        NSLog(@"执行任务2");
    });
    
    NSLog(@"执行任务3");
    
    // dispatch_async不要求立马在当前线程同步执行任务
}

- (void)interview03
{
    // 问题：以下代码是在主线程执行的，会不会产生死锁？会！
    NSLog(@"执行任务1");
    
    dispatch_queue_t queue = dispatch_queue_create("myqueu", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{ // 0
        NSLog(@"执行任务2");
        
        dispatch_sync(queue, ^{ // 1
            NSLog(@"执行任务3");
        });
        
        NSLog(@"执行任务4");
    });
    
    NSLog(@"执行任务5");
}

- (void)interview04
{
    // 问题：以下代码是在主线程执行的，会不会产生死锁？不会！
    NSLog(@"执行任务1");
    
    dispatch_queue_t queue = dispatch_queue_create("myqueu", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{ // 0
        NSLog(@"执行任务2");
        
        dispatch_sync(queue, ^{ // 1
            NSLog(@"执行任务3");
        });
        
        NSLog(@"执行任务4");
    });
    
    NSLog(@"执行任务5");
}


- (void)communication {
  // 获取全局并发队列
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  // 获取主队列
  dispatch_queue_t mainQueue = dispatch_get_main_queue();
  dispatch_async(queue, ^{
    // 异步追加任务
    for (int i = 0; i < 2; ++i) {
      [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
      NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    }
    // 回到主线程
    dispatch_async(mainQueue, ^{
      // 追加在主线程中执行的任务
      [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
      NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    });
  });
}

- (void)barrierTest {
    self.queue = dispatch_queue_create("rw_queue", DISPATCH_QUEUE_CONCURRENT);
    for (int i=0; i<5; i++) {
        [self readWithIndex:i];
        [self readWithIndex:i];
        [self writeWithIndex:i];
        [self readWithIndex:i];
    }
}

- (void)readWithIndex:(NSInteger)index {
    dispatch_async(self.queue, ^{
        sleep(1);
        NSLog(@"第%ld次循环:read", (long)index);
    });
}

- (void)writeWithIndex:(NSInteger)index {
    dispatch_barrier_async(self.queue, ^{
        sleep(1);
        NSLog(@"第%ld次循环:write", (long)index);
    });
}

/**
* 延时执行方法 dispatch_after
*/
- (void)after {
  NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线
  NSLog(@"asyncMain---begin");
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
    // 2.0秒后异步追加任务代码到主队列，并开始执行
    NSLog(@"after---%@",[NSThread currentThread]);  // 打印当前线程
  });
}

/**
* 队列组 dispatch_group_notify
*/
- (void)groupNotify {
  NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
  NSLog(@"group---begin");
  dispatch_group_t group =  dispatch_group_create();
  dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
    // 追加任务1
    for (int i = 0; i < 2; ++i) {
      [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
      NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    }
  });
  dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
    // 追加任务2
    for (int i = 0; i < 2; ++i) {
      [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
      NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
    }
  });
  
  dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    // 等前面的异步任务1、任务2都执行完毕后，回到主线程执行下边任务
    for (int i = 0; i < 2; ++i) {
      [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
      NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
    }
    NSLog(@"group---end");
  });
}


- (void)interview05{
    // 创建队列组
    dispatch_group_t group = dispatch_group_create();
    // 创建信号量，并且设置值为3
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i = 0; i < 10; i++){
       /*
        由于是异步执行的，所以每次循环Block里面的dispatch_semaphore_signal根本还没有执行就会执行dispatch_semaphore_wait，从而semaphore-1.当循环10此后，semaphore等于0，则会阻塞线程，直到执行了Block的dispatch_semaphore_signal 才会继续执行
        */
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_group_async(group, queue, ^{
            NSLog(@"%i",i);
            sleep(2);
            // 每次发送信号则semaphore会+1，
            dispatch_semaphore_signal(semaphore);
        });
    }
}

- (void)test
{
    // 如果信号量的值 > 0，就让信号量的值减1，然后继续往下执行代码
    // 如果信号量的值 <= 0，就会休眠等待，直到信号量的值变成>0，就让信号量的值减1，然后继续往下执行代码
    long X = dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"当前信号量1:%ld",X);
    sleep(2);
//    NSLog(@"test - %@", [NSThread currentThread]);
    
    // 让信号量的值+1
    dispatch_semaphore_signal(self.semaphore);
    X = dispatch_semaphore_signal(self.semaphore);
    NSLog(@"当前信号量2:%ld",X);
}




@end
