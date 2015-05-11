//
//  SearchBarTableViewCell.m
//  AppCanPlugin
//
//  Created by hongbao.cui on 15-1-11.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "SearchBarTableViewCell.h"

@implementation SearchBarTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *subview in self.contentView.superview.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"SeparatorView"]) {
            subview.hidden = NO;
        }
    }
}
@end
