//
//  AutoLayoutTagView.m
//  AutoLayoutTagView
//
//  Created by Frank on 15/12/4.
//  Copyright © 2015年 jiangw. All rights reserved.
//

#import "AutoLayoutTagView.h"
#import <Masonry.h>

typedef void(^buttonStyleBlock)(UIButton *button, NSUInteger index);

@interface AutoLayoutTagView()

@property(nonatomic, assign) CGFloat maxLayoutWidth;
@property(nonatomic, strong) NSMutableArray *tagButtons;
@property(nonatomic, strong) NSMutableArray *tagConstraints;
@property(nonatomic, strong) buttonStyleBlock callback;

@end

@implementation AutoLayoutTagView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _maxLayoutWidth = frame.size.width;
        _tagButtons = [NSMutableArray array];
        _tagConstraints = [NSMutableArray array];
        _padding = UIEdgeInsetsMake(8, 8, 8, 8);
        _selectedIndex = -1;
        _lineSpace = 8;
        _tagSpace = 8;
    }
    return self;
}


#pragma mark - public method

- (void)setTagButtonStyleWithBlock:(void(^)(UIButton *button, NSUInteger index))callback {
    self.callback = callback;
    if (self.tagButtons.count > 0) {
        [self.tagButtons enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
            callback(btn, idx);
        }];
    }
}

- (void)addTagWithTitle:(NSString *)title {
    [self insertTagWithTitle:title atIndex:self.tagButtons.count];
}

- (void)insertTagWithTitle:(NSString *)title atIndex:(NSUInteger)index {
    if (index <= self.tagButtons.count) {
        UIButton *tag = [UIButton buttonWithType:UIButtonTypeCustom];
        [tag setTitle:title forState:UIControlStateNormal];
        [tag addTarget:self action:@selector(tapButtonEventHandle:) forControlEvents:UIControlEventTouchUpInside];
        
        [self setDefalutStyleWithButton:tag];
        if (self.callback) {
            self.callback(tag, index);
        }
        
        [self.tagButtons insertObject:tag atIndex:index];
        [self insertSubview:tag atIndex:index];
        
        if ((NSInteger)index <= self.selectedIndex) {
            self.selectedIndex += 1;
        }
        
        [self invalidateIntrinsicContentSize];
    }
}

- (void)removeTagAtIndex:(NSUInteger)index {
    if (index < self.tagButtons.count) {
        UIButton *tag = [self.tagButtons objectAtIndex:index];
        [self.tagButtons removeObject:tag];
        [tag removeFromSuperview];
        
        if ((NSInteger)index <= self.selectedIndex) {
            self.selectedIndex -= 1;
        }
        
        [self invalidateIntrinsicContentSize];
    }
}

- (void)removeAllTags {
    for (UIButton *tag in self.tagButtons) {
        [tag removeFromSuperview];
    }
    [self.tagButtons removeAllObjects];
    self.selectedIndex = -1;
    
    [self invalidateIntrinsicContentSize];
}


#pragma mark - event

- (void)tapButtonEventHandle:(UIButton *)button {
    NSUInteger index = [self.tagButtons indexOfObject:button];
    self.selectedIndex = index;
}


#pragma mark - property

- (void)setSelectedIndex:(NSInteger)index {
    if (index >= -1 && index < self.tagButtons.count && _selectedIndex != index) {
        if (_selectedIndex != -1) {
            UIButton *disSelectTag = self.tagButtons[_selectedIndex];
            disSelectTag.selected = NO;
            
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(autoLayoutTagView:dismissSelectTagButton:andIndex:)]) {
                    [self.delegate autoLayoutTagView:self dismissSelectTagButton:disSelectTag andIndex:_selectedIndex];
                }
            }
        }
        
        _selectedIndex = index;
        if (index != -1) {
            UIButton *selectTag = self.tagButtons[index];
            selectTag.selected = YES;
            
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(autoLayoutTagView:didSelectTagButton:andIndex:)]) {
                    [self.delegate autoLayoutTagView:self didSelectTagButton:selectTag andIndex:index];
                }
            }
        }
    }
}

- (void)setMaxLayoutWidth:(CGFloat)width {
    if (width != _maxLayoutWidth) {
        _maxLayoutWidth = width;
        
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize {
    if (!self.tagButtons.count) {
        return CGSizeZero;
    }
    
    CGFloat intrinsicWidth = 0;
    CGFloat intrinsicHeight = 0;
    
    if (self.maxLayoutWidth > 0) {
        CGFloat lineWidth = 0;
        CGFloat lineHeight = 0;
        for (UIButton *btn in self.tagButtons) {
            CGSize tagSize = [self getSizeOfTagButton:btn];
            
            if ([self isHeadTagButton:btn]) {
                intrinsicWidth = MAX(intrinsicWidth, lineWidth);
                if (intrinsicHeight == 0) {
                    intrinsicHeight = lineHeight;
                }
                else {
                    intrinsicHeight += self.lineSpace + lineHeight;
                }
                
                lineWidth = tagSize.width;
                lineHeight = tagSize.height;
            }
            else {
                lineWidth += self.tagSpace + tagSize.width;
                lineHeight = MAX(lineHeight, tagSize.height);
            }
        }
        
        intrinsicWidth = MAX(intrinsicWidth, lineWidth);
        intrinsicWidth += self.padding.left + self.padding.right;
        
        if (intrinsicHeight == 0) {
            intrinsicHeight = lineHeight;
        }
        else {
            intrinsicHeight += self.lineSpace + lineHeight;
        }
        intrinsicHeight += self.padding.top + self.padding.bottom;
    }
    
    NSLog(@"AutoLayoutTagView ContentSize: (width: %.2f, height: %.2f)", intrinsicWidth, intrinsicHeight);
    return CGSizeMake(intrinsicWidth, intrinsicHeight);
}


#pragma mark - tag layout

- (void)layoutSubviews {
    if (self.maxLayoutWidth != self.frame.size.width) {
        self.maxLayoutWidth = self.frame.size.width;
    }
    
    [super layoutSubviews];
}

- (void)updateConstraints {
    if (self.tagButtons.count > 0) {
        [self removeAllConstraints];
        for (UIButton *btn in self.tagButtons) {
            [self setConstraintOfTagButton:btn];
        }
    }
    
    [super updateConstraints];
}

- (void)setConstraintOfTagButton:(UIButton *)tagButton {
    CGSize tagSize = [self getSizeOfTagButton:tagButton];
    NSUInteger index = [self.tagButtons indexOfObject:tagButton];
    
    UIView *superView = self;
    CGFloat leftOffset = self.padding.left;
    CGFloat topOffset = self.padding.top;
    CGFloat tagSpace = self.tagSpace;
    CGFloat lineSpace = self.lineSpace;
    
    if (self.maxLayoutWidth > 0) {
        [tagButton mas_makeConstraints:^(MASConstraintMaker *make) {
            [self.tagConstraints addObject:make.width.mas_equalTo(tagSize.width)];
            [self.tagConstraints addObject:make.height.mas_equalTo(tagSize.height)];
//            [self.tagConstraints addObject:make.bottom.lessThanOrEqualTo(superView).offset(-bottomOffset)];
//            [self.tagConstraints addObject:make.right.lessThanOrEqualTo(superView).offset(-rightOffset)];
        }];
        
        if (index == 0) {
            // first tag
            [tagButton mas_makeConstraints:^(MASConstraintMaker *make) {
                [self.tagConstraints addObject:make.left.equalTo(superView).offset(leftOffset)];
                [self.tagConstraints addObject:make.top.equalTo(superView).offset(topOffset)];
            }];
        }
        else {
            UIButton *prevTagBtn = self.tagButtons[index - 1];
            if ([self isHeadTagButton:tagButton]) {
                // new line
                [tagButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    [self.tagConstraints addObject:make.left.equalTo(superView).offset(leftOffset)];
                    [self.tagConstraints addObject:make.top.equalTo(prevTagBtn.mas_bottom).offset(lineSpace)];
                }];
            }
            else {
                [tagButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    [self.tagConstraints addObject:make.centerY.equalTo(prevTagBtn)];
                    [self.tagConstraints addObject:make.left.equalTo(prevTagBtn.mas_right).offset(tagSpace)];
                }];
            }
        }
    }
}


#pragma mark - private method

- (CGSize)getSizeOfTagButton:(UIButton *)button {
    CGSize size = button.frame.size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return button.intrinsicContentSize;
    }
    else {
        return size;
    }
}

- (BOOL)isHeadTagButton:(UIButton *)button {
    NSUInteger index = [self.tagButtons indexOfObject:button];
    if (index == 0) {
        return YES;
    }
    
    BOOL isHead = NO;
    CGFloat xOffset = self.padding.left;
    for (int i = 0; i <= index; i++) {
        CGSize tagSize = [self getSizeOfTagButton:self.tagButtons[i]];
        
        if (xOffset == self.padding.left) {
            xOffset += tagSize.width;
        }
        else {
            xOffset += self.tagSpace + tagSize.width;
        }
        
        if (xOffset + self.padding.right > self.maxLayoutWidth) {
            xOffset = self.padding.left + tagSize.width;
            isHead = YES;
        }
        else {
            isHead = NO;
        }
    }
    return isHead;
}

- (void)removeAllConstraints {
    for (id obj in self.tagConstraints) {
        if ([obj isKindOfClass:MASConstraint.class]) {
            [(MASConstraint *)obj uninstall];
        }
        else if([obj isKindOfClass:NSArray.class]) {
            for (MASConstraint * constraint in (NSArray *)obj) {
                [constraint uninstall];
            }
        }
        else {
            NSAssert(NO, @"Error:unknown class type: %@", obj);
        }
    }
    [self.tagConstraints removeAllObjects];
}

- (void)setDefalutStyleWithButton:(UIButton *)button {
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.contentEdgeInsets = UIEdgeInsetsMake(6, 8, 6, 8);
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 5;
}

@end
