//
//  ViewController.m
//  AutoLayoutTagView
//
//  Created by Frank on 15/12/5.
//  Copyright © 2015年 jiangw. All rights reserved.
//

#import "ViewController.h"
#import "AutoLayoutTagView.h"
#import <Masonry.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSArray *tagTitles = @[@"标签1", @"标签2", @"标签3", @"标签4", @"标签5", @"标签6"];
    AutoLayoutTagView *tagView = [[AutoLayoutTagView alloc] init];
    tagView.backgroundColor = [UIColor yellowColor];
    
    [tagView setTagButtonStyleWithBlock:^(UIButton *button, NSUInteger index) {
//        button.frame = CGRectMake(0, 0, 96, 30);
        button.backgroundColor = [UIColor whiteColor];
    }];
    
    [tagTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        [tagView addTagWithTitle:title];
    }];
    
    [self.view addSubview:tagView];
    [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-40);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
