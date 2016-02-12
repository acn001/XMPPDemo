//
//  XMPPDemoFriendsViewController.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "XMPPDemoFriendsViewController.h"
#import "XMPPHelper.h"
#import "XMPPDemoAddNewFriendViewController.h"
#import "XMPPDemoChatViewController.h"
#import "XMPPDemoFriendSubscriptionCell.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "XMPPDemoToast.h"
#import "NSString+XMPPDemo.h"

@interface XMPPDemoFriendsViewController () <UITableViewDataSource, UITableViewDelegate, XMPPDemoFriendSubscriptionCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger numberOfSections;

@property (nonatomic, strong) UILabel *friendsRequestLabel;
@property (nonatomic, strong) UILabel *onlineFriendsLabel;
@property (nonatomic, strong) UILabel *allFriendsLabel;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDispCtrl;
@property (nonatomic, strong) NSArray<XMPPUserCoreDataStorageObject *> *searchResArray;

@end

@implementation XMPPDemoFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self uiConfig];
    [self prepareData];
    [self searchConfig];
}

- (void)uiConfig {
    self.navigationItem.title = @"Friends";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(goOfflineAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction)];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:_tableView];
    
    self.friendsRequestLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 20.0)];
    self.friendsRequestLabel.backgroundColor = [UIColor whiteColor];
    self.friendsRequestLabel.textAlignment = NSTextAlignmentLeft;
    self.friendsRequestLabel.font = [UIFont systemFontOfSize:12.0];
    self.friendsRequestLabel.text = @"Friends request";
    
    self.onlineFriendsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 20.0)];
    self.onlineFriendsLabel.backgroundColor = [UIColor whiteColor];
    self.onlineFriendsLabel.textAlignment = NSTextAlignmentLeft;
    self.onlineFriendsLabel.font = [UIFont systemFontOfSize:12.0];
    self.onlineFriendsLabel.text = @"Online friends";
    
    self.allFriendsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 20.0)];
    self.allFriendsLabel.backgroundColor = [UIColor whiteColor];
    self.allFriendsLabel.textAlignment = NSTextAlignmentLeft;
    self.allFriendsLabel.font = [UIFont systemFontOfSize:12.0];
    self.allFriendsLabel.text = @"All friends";
}

- (void)prepareData {
    [self.tableView reloadData];
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kFriendsListShouldUpdate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf.tableView reloadData];
    }];
}

- (void)searchConfig {
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    self.searchBar.placeholder = @"Search friends";
    self.tableView.tableHeaderView = self.searchBar;
    self.searchDispCtrl = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
    self.searchDispCtrl.searchResultsDataSource = self;
    self.searchDispCtrl.searchResultsDelegate = self;
    self.searchDispCtrl.searchResultsTableView.tableFooterView= [[UIView alloc]init];
}

- (void)goOfflineAction {
    [[XMPPHelper sharedInstance] goOfflineWithCallback:^(BOOL res) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [XMPPDemoToast showToastWithMessage:@"Logout success."];
    }];
}

- (void)addAction {
    [self.navigationController pushViewController:[[XMPPDemoAddNewFriendViewController alloc] init] animated:YES];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        self.numberOfSections = [XMPPHelper sharedInstance].friendsRequest.count > 0 ? 3 : 2;
        return self.numberOfSections;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (self.numberOfSections == 2) {
            if (section == 0) {
                return [XMPPHelper sharedInstance].onlineFriends.count;
            }
            if (section == 1) {
                return [XMPPHelper sharedInstance].allFriends.count;
            }
        } else {
            if (section == 0) {
                return [XMPPHelper sharedInstance].friendsRequest.count;
            }
            if (section == 1) {
                return [XMPPHelper sharedInstance].onlineFriends.count;
            }
            if (section == 2) {
                return [XMPPHelper sharedInstance].allFriends.count;
            }
        }
    } else {
        NSString *searchKey = [self.searchBar.text trim];
        self.searchResArray = [[XMPPHelper sharedInstance] queryFriendsWithKey:searchKey];
        return self.searchResArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return 20.0;
    } else {
        return 0.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (self.numberOfSections == 2) {
            if (section == 0) {
                return self.onlineFriendsLabel;
            }
            if (section == 1) {
                return self.allFriendsLabel;
            }
        } else {
            if (section == 0) {
                return (self.numberOfSections == 3)?self.friendsRequestLabel:nil;
            }
            if (section == 1) {
                return self.onlineFriendsLabel;
            }
            if (section == 2) {
                return self.allFriendsLabel;
            }
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        
        static NSString *cellId = @"cell";
        UITableViewCell *commonCell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!commonCell) {
            commonCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        
        if (self.numberOfSections == 2) {
            if (indexPath.section == 0) {
                commonCell.textLabel.text = [XMPPHelper sharedInstance].onlineFriends[indexPath.row].jid.user;
            }
            if (indexPath.section == 1) {
                commonCell.textLabel.text = [XMPPHelper sharedInstance].allFriends[indexPath.row].jid.user;
            }
        } else {
            if (indexPath.section == 0) {
                static NSString *friendSubscriptionCellId = @"friendSubscriptionCell";
                XMPPDemoFriendSubscriptionCell *friendSubscriptionCell = [tableView dequeueReusableCellWithIdentifier:friendSubscriptionCellId];
                if (friendSubscriptionCell == nil) {
                    friendSubscriptionCell = [[NSBundle mainBundle] loadNibNamed:@"XMPPDemoFriendSubscriptionCell" owner:nil options:nil][0];
                    friendSubscriptionCell.delegate = self;
                }
                friendSubscriptionCell.username = [XMPPHelper sharedInstance].friendsRequest[indexPath.row];
                return friendSubscriptionCell;
            }
            if (indexPath.section == 1) {
                commonCell.textLabel.text = [XMPPHelper sharedInstance].onlineFriends[indexPath.row].jid.user;
            }
            if (indexPath.section == 2) {
                commonCell.textLabel.text = [XMPPHelper sharedInstance].allFriends[indexPath.row].jid.user;
            }
        }
        return commonCell;
    } else {
        static NSString *cellId = @"searchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId
                    ];
        }
        cell.textLabel.text = self.searchResArray[indexPath.row].jid.user;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *username = nil;
    if (tableView == self.tableView) {
        if (self.numberOfSections == 2) {
            if (indexPath.section == 0) {
                username = [XMPPHelper sharedInstance].onlineFriends[indexPath.row].jid.user;
            }
            if (indexPath.section == 1) {
                username = [XMPPHelper sharedInstance].allFriends[indexPath.row].jid.user;
            }
        } else {
            if (indexPath.section == 0) {
                return;
            }
            if (indexPath.section == 1) {
                username = [XMPPHelper sharedInstance].onlineFriends[indexPath.row].jid.user;
            }
            if (indexPath.section == 2) {
                username = [XMPPHelper sharedInstance].allFriends[indexPath.row].jid.user;
            }
        }
    } else {
        username = self.searchResArray[indexPath.row].jid.user;
    }
    XMPPDemoChatViewController *vc = [[XMPPDemoChatViewController alloc] initWithUsername:username];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - FriendSubscriptionCellDelegate

- (void)friendSubscriptionCellAcceptButtonDidTapped:(NSString *)username {
    [[XMPPHelper sharedInstance] accepteNewFriend:username withCallback:nil];
}

- (void)friendSubscriptionCellRejectButtonDidTapped:(NSString *)username {
    [[XMPPHelper sharedInstance] rejectNewFriend:username withCallback:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

@end
