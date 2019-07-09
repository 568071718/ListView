//
//  XHHeaderView.m
//  listView
//
//  Created by 路 on 2019/7/9.
//  Copyright © 2019年 路. All rights reserved.
//

#import "XHHeaderView.h"

@implementation XHHeaderView

- (void)awakeFromNib; {
    [super awakeFromNib];
    
    _button1.layer.borderColor = [UIColor brownColor].CGColor;
    _button1.layer.borderWidth = 1.f;
    _button1.layer.cornerRadius = 5.f;
    _button1.layer.masksToBounds = YES;
    
    _button2.layer.borderColor = [UIColor brownColor].CGColor;
    _button2.layer.borderWidth = 1.f;
    _button2.layer.cornerRadius = 5.f;
    _button2.layer.masksToBounds = YES;
}
@end
