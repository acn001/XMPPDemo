//
//  XMPPHelper.h
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kFriendsListShouldUpdate = @"FriendsListShouldUpdate";
static NSString * const kMessagesListShouldUpdate = @"MessagesListShouldUpdate";
static NSString * const kFriendGoOnline = @"FriendGoOnline";
static NSString * const kFriendGoOffline = @"FriendGoOffline";

@class XMPPUserCoreDataStorageObject, XMPPMessageArchiving_Message_CoreDataObject;

@interface XMPPHelper : NSObject

@property (nonatomic, strong, readonly) NSArray<XMPPUserCoreDataStorageObject *> *allFriends;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *friendsRequest;
@property (nonatomic, strong, readonly) NSMutableArray<XMPPUserCoreDataStorageObject *> *onlineFriends;
@property (nonatomic, strong, readonly) NSArray<XMPPMessageArchiving_Message_CoreDataObject *> *messages;

@property (nonatomic, copy) void(^loginCB)(BOOL, NSError *);
@property (nonatomic, copy) void(^registerCB)(BOOL, NSError *);
@property (nonatomic, copy) void(^goOfflineCB)(BOOL);
@property (nonatomic, copy) void(^addNewFriendCB)();
@property (nonatomic, copy) void(^acceptNewFriendCB)();
@property (nonatomic, copy) void(^rejectNewFriendCB)();
@property (nonatomic, copy) void(^removeFriendCB)();
@property (nonatomic, copy) void(^sendMessageCB)(BOOL);

@property (nonatomic, copy) NSString *chatingUser;

+ (instancetype)sharedInstance;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password callback:(void(^)(BOOL, NSError *))loginCB;
- (void)registerWithUsername:(NSString *)username password:(NSString *)password withCallback:(void(^)(BOOL, NSError *))registerCB;
- (BOOL)isConnected;

- (void)goOnline;
- (void)goOfflineWithCallback:(void(^)(BOOL))goOfflineCB;

- (void)addNewFriend:(NSString *)username withCallback:(void(^)())addNewFriendCB;
- (void)accepteNewFriend:(NSString *)username withCallback:(void(^)())accepteNewFriendCB;
- (void)rejectNewFriend:(NSString *)username withCallback:(void(^)())rejectNewFriendCB;
- (void)removeFriend:(NSString *)username withCallback:(void(^)())removeFriendCB;

- (void)sendTextMessage:(NSString *)message toUser:(NSString *)username;

- (NSArray<XMPPUserCoreDataStorageObject *> *)queryFriendsWithKey:(NSString *)key;
- (BOOL)isFriendOnline:(NSString *)username;
- (void)fetchMessagesForUsername:(NSString *)username;
- (void)stopFetchMessages;

@end
