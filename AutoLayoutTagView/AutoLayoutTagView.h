//
//  AutoLayoutTagView.h
//  AutoLayoutTagView
//
//  Created by Frank on 15/12/4.
//  Copyright © 2015年 jiangw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AutoLayoutTagView;
@protocol AutoLayoutTagViewDelegate <NSObject>

- (void)autoLayoutTagView:(AutoLayoutTagView *)view didSelectTagButton:(UIButton *)button andIndex:(NSUInteger)index;
- (void)autoLayoutTagView:(AutoLayoutTagView *)view disSelectTagButton:(UIButton *)button andIndex:(NSUInteger)index;

@end

@interface AutoLayoutTagView : UIView

@property(nonatomic, assign) CGFloat lineSpace;
@property(nonatomic, assign) CGFloat tagSpace;
@property(nonatomic, assign) UIEdgeInsets padding;
@property(nonatomic, assign) NSInteger selectedIndex;   // -1 is defalut value
@property(nonatomic, weak) id<AutoLayoutTagViewDelegate> delegate;

- (void)setTagButtonStyleWithBlock:(void(^)(UIButton *button, NSUInteger index))callback;

- (void)addTagWithTitle:(NSString *)title;

- (void)insertTagWithTitle:(NSString *)title atIndex:(NSUInteger)index;

- (void)removeTagAtIndex:(NSUInteger)index;

- (void)removeAllTags;

@end
