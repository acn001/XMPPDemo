//
//  XMPPDemoFriendSubscriptionCell.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "XMPPDemoFriendSubscriptionCell.h"

@interface XMPPDemoFriendSubscriptionCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *rejectButton;

@end

@implementation XMPPDemoFriendSubscriptionCell

- (void)setUsername:(NSString *)username {
    self->_username = username;
    self.titleLabel.text = [NSString stringWithFormat:@"“%@” wants to be your friend.", self.username];
}

- (IBAction)acceptButtonAction:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate friendSubscriptionCellAcceptButtonDidTapped:self.username];
    }
}

- (IBAction)rejectButtonAction:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate friendSubscriptionCellRejectButtonDidTapped:self.username];
    }
}

@end
