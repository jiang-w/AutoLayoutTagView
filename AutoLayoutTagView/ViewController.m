//
//  ViewController.m
//  AutoLayoutTagView
//
//  Created by Frank on 15/12/5.
//  Copyright © 2015年 jiangw. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>

@interface ViewController ()

@property(nonatomic, strong) AutoLayoutTagView *tagView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tagView];
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-40);
    }];

    NSArray *tagTitles = @[@"标签1", @"标签2", @"标签3", @"标签4", @"标签5", @"标签6"];
    [tagTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        [self.tagView addTagWithTitle:title];
    }];
}

- (AutoLayoutTagView *)tagView {
    if (!_tagView) {
        _tagView = [[AutoLayoutTagView alloc] init];
        _tagView.backgroundColor = [UIColor yellowColor];
        _tagView.delegate = self;
        
        [_tagView setTagButtonStyleWithBlock:^(UIButton *button, NSUInteger index) {
            //        button.frame = CGRectMake(0, 0, 96, 30);
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.backgroundColor = [UIColor whiteColor];
            button.contentEdgeInsets = UIEdgeInsetsMake(6, 8, 6, 8);
            button.layer.borderColor = [UIColor blackColor].CGColor;
            button.layer.borderWidth = 1;
            button.layer.cornerRadius = 6;
        }];
    }
    return _tagView;
}

- (void)autoLayoutTagView:(AutoLayoutTagView *)view didSelectTagButton:(UIButton *)button andIndex:(NSUInteger)index {
    button.layer.borderColor = [UIColor orangeColor].CGColor;
}

- (void)autoLayoutTagView:(AutoLayoutTagView *)view disSelectTagButton:(UIButton *)button andIndex:(NSUInteger)index {
    button.layer.borderColor = [UIColor blackColor].CGColor;
}

@end
