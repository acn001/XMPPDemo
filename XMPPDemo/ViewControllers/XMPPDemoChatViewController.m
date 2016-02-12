//
//  XMPPDemoChatViewController.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "XMPPDemoChatViewController.h"
#import "XMPPHelper.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import "NSString+XMPPDemo.h"

@interface XMPPDemoChatViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation XMPPDemoChatViewController

- (instancetype)initWithUsername:(NSString *)username {
    if (self = [super init]) {
        self->_username = [username copy];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self uiConfig];
    [self prepareData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XMPPHelper sharedInstance].chatingUser = self.username;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [XMPPHelper sharedInstance].chatingUser = nil;
}

- (void)uiConfig {
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 30.0)];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.tintColor = [UIColor blueColor];
    self.textField.delegate = self;
    self.navigationItem.titleView = self.textField;
    
    self.navigationItem.title = self.username;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesAction:)]];
}

- (void)tapGesAction:(UITapGestureRecognizer *)tapGes {
    [self.textField resignFirstResponder];
}

- (void)prepareData {
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kMessagesListShouldUpdate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf.tableView reloadData];
        if ([XMPPHelper sharedInstance].messages.count > 0) {
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[XMPPHelper sharedInstance].messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
        }
    }];
    [[XMPPHelper sharedInstance] fetchMessagesForUsername:self.username];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
    [[XMPPHelper sharedInstance] stopFetchMessages];
}

#pragma mark - UITableViewDataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [XMPPHelper sharedInstance].messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"messageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    XMPPMessageArchiving_Message_CoreDataObject *message = [XMPPHelper sharedInstance].messages[indexPath.row];
    if (message.isOutgoing) {
        cell.textLabel.text = [NSString stringWithFormat:@"Me %@", message.timestamp.description];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", message.message.from.user, message.timestamp.description];
    }
    cell.detailTextLabel.text = message.message.body;
    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text isEmpty]) {
        return NO;
    }
    [[XMPPHelper sharedInstance] sendTextMessage:[textField.text trim] toUser:self.username];
    self.textField.text = nil;
    return YES;
}

@end
