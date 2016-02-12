//
//  XMPPHelper.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "XMPPHelper.h"
#import "XMPPFramework.h"
#import "XMPPDemoToast.h"

// kHostURL and kHostName should be the actual value with the server.
static NSString * const kHostURL = nil;
static NSString * const kHostName = nil;

@interface XMPPHelper () <XMPPStreamDelegate, XMPPRosterDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) XMPPStream *xmppStream;

@property (nonatomic, strong) XMPPRoster *roster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *rosterStorage;
@property (nonatomic, strong) NSFetchedResultsController *rosterFetchedResultsController;
@property (nonatomic, strong) NSMutableSet<NSString *> *onlineFriendUsernames;

@property (nonatomic, strong) XMPPMessageArchiving *messageArchiving;
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *messageStorage;
@property (nonatomic, strong) NSFetchedResultsController *messageFetchedResultsController;
@property (nonatomic, strong) XMPPReconnect *reconnect;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, assign) BOOL isLogin;

@end

@implementation XMPPHelper

static XMPPHelper *_sharedInstance = nil;

#pragma mark - NSObject

+ (instancetype)sharedInstance {
    NSAssert(kHostURL.length > 0, @"kHostURL cannot be null.");
    NSAssert(kHostName.length > 0, @"kHostName cannot be null.");
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[XMPPHelper alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configXmppStream];
        self->_allFriends = [[NSArray alloc] init];
        self->_friendsRequest = [[NSMutableArray alloc] init];
        self->_onlineFriends = [[NSMutableArray alloc] init];
        self.onlineFriendUsernames = [[NSMutableSet alloc] init];
        self->_messages = [[NSArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self teardown];
}

#pragma mark - private

- (NSString *)getJidStr:(NSString *)username {
    return [NSString stringWithFormat:@"%@@%@", username, kHostName];
}

- (void)configXmppStream {
    self.xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    [self.xmppStream setEnableBackgroundingOnSocket:YES];
#endif
    
    [self.xmppStream setHostName:kHostURL];
    [self.xmppStream setHostPort:5222];
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)configModules {
    self->_allFriends = [[NSArray alloc] init];
    self->_friendsRequest = [[NSMutableArray alloc] init];
    self->_onlineFriends = [[NSMutableArray alloc] init];
    self.onlineFriendUsernames = [[NSMutableSet alloc] init];
    self->_messages = [[NSArray alloc] init];
    
    NSString *rosterCoreDataFilename = [NSString stringWithFormat:@"%@_roster_coredata.sqlite", self.username];
    self.rosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithDatabaseFilename:rosterCoreDataFilename storeOptions:nil];
    self.roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage dispatchQueue:dispatch_get_global_queue(0, 0)];
    [self.roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.roster activate:_xmppStream];
    
    NSString *messageCoreDataFilename = [NSString stringWithFormat:@"%@_message_coredata.sqlite", self.username];
    self.messageStorage = [[XMPPMessageArchivingCoreDataStorage alloc] initWithDatabaseFilename:messageCoreDataFilename storeOptions:nil];
    self.messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:self.messageStorage];
    [self.messageArchiving activate:self.xmppStream];
    
    self.reconnect = [[XMPPReconnect alloc] init];
    [self.reconnect activate:self.xmppStream];
}

- (void)connect {
    if ([self.xmppStream isConnected]) {
        [self.xmppStream disconnect];
    }
    
    NSString *jidStr = [self getJidStr:self.username];
    self.xmppStream.myJID = [XMPPJID jidWithString:jidStr];
    
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        NSLog(@"Connect error: %@", error.localizedDescription);
    }
}

- (void)teardown {
    self->_allFriends = nil;;
    self->_friendsRequest = nil;
    self->_onlineFriends = nil;
    self.onlineFriendUsernames = nil;
    self->_messages = nil;
    
    [self.roster removeDelegate:self];
    
    [self.roster deactivate];
    [self.messageArchiving deactivate];
    [self.reconnect deactivate];
    
    self.roster = nil;
    self.rosterStorage = nil;
    self.messageArchiving = nil;
    self.messageStorage = nil;
    self.reconnect = nil;
}

#pragma mark - public

- (void)loginWithUsername:(NSString *)username password:(NSString *)password callback:(void(^)(BOOL, NSError *))loginCB {
    self.isLogin = YES;
    
    //    [self teardown];
    
    self.loginCB = loginCB;
    self.username = username;
    self.password = password;
    
    [self configModules];
    [self connect];
}

- (void)registerWithUsername:(NSString *)username password:(NSString *)password withCallback:(void(^)(BOOL, NSError *))registerCB {
    self.isLogin = NO;
    self.username = username;
    self.password = password;
    self.registerCB = registerCB;
    [self connect];
}

- (BOOL)isConnected {
    return [self.xmppStream isConnected];
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmppStream sendElement:presence];
    [self fetchAllFriends];
}

- (void)goOfflineWithCallback:(void(^)(BOOL ret))goOfflineCB {
    self.goOfflineCB = goOfflineCB;
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmppStream sendElement:presence];
    self.goOfflineCB(YES);
    [self teardown];
}

- (void)addNewFriend:(NSString *)username withCallback:(void(^)())addNewFriendCB {
    self.addNewFriendCB = addNewFriendCB;
    [self.roster addUser:[XMPPJID jidWithString:[self getJidStr:username]] withNickname:nil];
    self.addNewFriendCB();
}

- (void)accepteNewFriend:(NSString *)username withCallback:(void(^)())accepteNewFriendCB {
    self.acceptNewFriendCB = accepteNewFriendCB;
    [self.roster acceptPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:[self getJidStr:username]] andAddToRoster:YES];
    [self.friendsRequest removeObject:username];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFriendsListShouldUpdate object:nil];
    [XMPPDemoToast showToastWithMessage:[NSString stringWithFormat:@"“%@” has become your friend.", username]];
    if (self.acceptNewFriendCB != nil) {
        self.acceptNewFriendCB();
    }
}

- (void)rejectNewFriend:(NSString *)username withCallback:(void(^)())rejectNewFriendCB {
    self.rejectNewFriendCB = rejectNewFriendCB;
    [self.roster rejectPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:[self getJidStr:username]]];
    [self.friendsRequest removeObject:username];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFriendsListShouldUpdate object:nil];
    [XMPPDemoToast showToastWithMessage:[NSString stringWithFormat:@"You have rejected “%@”.", username]];
    if (self.rejectNewFriendCB != nil) {
        self.rejectNewFriendCB();
    }
}

- (void)removeFriend:(NSString *)username withCallback:(void(^)())removeFriendCB {
    self.removeFriendCB = removeFriendCB;
    [self.roster removeUser:[XMPPJID jidWithString:[self getJidStr:username]]];
    if (self.removeFriendCB != nil) {
        self.removeFriendCB();
    }
}

- (void)sendTextMessage:(NSString *)message toUser:(NSString *)username {
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:[self getJidStr:username]]];
    [msg addBody:message];
    [self.xmppStream sendElement:msg];
}

- (NSArray<XMPPUserCoreDataStorageObject *> *)queryFriendsWithKey:(NSString *)key {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"jidStr contains %@", key];
    NSArray<XMPPUserCoreDataStorageObject *> *userObjects = [self.rosterStorage.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:NULL];
    return userObjects;
}

- (BOOL)isFriendOnline:(NSString *)username {
    return [self.onlineFriendUsernames containsObject:username];
}

- (void)fetchMessagesForUsername:(NSString *)username {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    NSString *jidStr = [[XMPPHelper sharedInstance] getJidStr:username];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@", jidStr];
    fetchRequest.predicate = predicate;
    NSManagedObjectContext *context = self.messageStorage.mainThreadManagedObjectContext;
    self.messageFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.messageFetchedResultsController.delegate = self;
    [self.messageFetchedResultsController performFetch:nil];
    
    self->_messages = [self.messageStorage.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (void)stopFetchMessages {
    self->_messages = [[NSArray alloc] init];
    self.messageFetchedResultsController = nil;
}

- (void)fetchAllFriends {
    NSFetchRequest *rosterFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"jidStr" ascending:YES];
    rosterFetchRequest.sortDescriptors = @[sortDescriptor];
    NSManagedObjectContext *rosterManagedObjectContext = self.rosterStorage.mainThreadManagedObjectContext;
    self.rosterFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:rosterFetchRequest managedObjectContext:rosterManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.rosterFetchedResultsController.delegate = self;
    [self.rosterFetchedResultsController performFetch:nil];
    
    self->_allFriends = [self.rosterStorage.mainThreadManagedObjectContext executeFetchRequest:rosterFetchRequest error:nil];
}

#pragma mark - XMPPStreamDelegate

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    if (self.isLogin) {
        [self.xmppStream authenticateWithPassword:self.password error:nil];
    } else {
        [self.xmppStream registerWithPassword:self.password error:nil];
    }
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    NSLog(@"Register success.");
    self.registerCB(YES, nil);
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    NSLog(@"Register fail.");
    self.registerCB(NO, [NSError errorWithDomain:error.description code:-1 userInfo:nil]);
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    self.loginCB(YES, nil);
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"Authenticate fail: %@", error);
    self.loginCB(NO, [NSError errorWithDomain:error.description code:-1 userInfo:nil]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"%@", message);
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    if (![presence.from.user isEqualToString:self.username]) {
        if ([presence.type isEqualToString:@"available"]) {
            if (![self.onlineFriendUsernames containsObject:presence.from.user]) {
                [self.onlineFriendUsernames addObject:presence.from.user];
                [self.onlineFriends addObject:[self.rosterStorage userForJID:[XMPPJID jidWithString:[self getJidStr:presence.from.user]] xmppStream:self.xmppStream managedObjectContext:self.rosterStorage.mainThreadManagedObjectContext]];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFriendGoOnline object:nil userInfo:@{@"username" : [presence.from.user copy]}];
            }
        } else if ([presence.type isEqualToString:@"unavailable"]) {
            [self.onlineFriendUsernames removeObject:presence.from.user];
            for (XMPPUserCoreDataStorageObject *userObject in self.onlineFriends) {
                if ([userObject.jid.user isEqualToString:presence.from.user]) {
                    [self.onlineFriends removeObject:userObject];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFriendGoOffline object:nil userInfo:@{@"username" : [presence.from.user copy]}];
                    break;
                }
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kFriendsListShouldUpdate object:nil];
    }
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    NSLog(@"Send message success.");
}

#pragma mark - XMPPRosterDelegate

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    NSString *username = presence.from.user;
    if (![self.friendsRequest containsObject:username]) {
        [self.friendsRequest addObject:username];
        [XMPPDemoToast showToastWithMessage:[NSString stringWithFormat:@"“%@” wants to be your friend.", username]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFriendsListShouldUpdate object:nil];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (controller == self.rosterFetchedResultsController) {
        self->_allFriends = controller.fetchedObjects;
        [[NSNotificationCenter defaultCenter] postNotificationName:kFriendsListShouldUpdate object:nil];
    } else if (controller == self.messageFetchedResultsController) {
        self->_messages = controller.fetchedObjects;
        [[NSNotificationCenter defaultCenter] postNotificationName:kMessagesListShouldUpdate object:nil];
    }
}

@end
