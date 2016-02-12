//
//  XMPPDemoFriendSubscriptionCell.h
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMPPDemoFriendSubscriptionCellDelegate <NSObject>

@required

- (void)friendSubscriptionCellAcceptButtonDidTapped:(NSString *)username;
- (void)friendSubscriptionCellRejectButtonDidTapped:(NSString *)username;

@end

@interface XMPPDemoFriendSubscriptionCell : UITableViewCell

@property (nonatomic, copy) NSString *username;
@property (nonatomic, weak) id <XMPPDemoFriendSubscriptionCellDelegate> delegate;

@end
