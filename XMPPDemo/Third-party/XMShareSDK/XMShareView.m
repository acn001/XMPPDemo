//
//  XMShareView.m
//  XMShareSDKTest
//
//  Created by liuzuopeng01 on 15/9/8.
//  Copyright (c) 2015年 liuzuopeng01. All rights reserved.
//

#import "XMShareView.h"
#import "XMShareObject.h"
#import "XMShareDef.h"
#import "XMTranslucencyView.h"



/**
 *  面板显示相关的默认值定义
 */
#define kXMDefaultPlatformNameFontSize  (12.f)
#define kXMSharePlatformButtonImageSize (41.f)

#define kXMMaxPlatformColumnsPerRow     (4)
#define kXMDefaultSharePanelHeight      (238.f)
#define kXMSharePlatformButtonWidth     (89.f)
#define kXMSharePlatformButtonHeight    (78.f)
#define kXMShareCancelButtonHeight      (42.f)
#define kXMShareSpacingToMargin         (10.f) // 控件至边框的间距
#define kXMShareSpacingPlatformToCancel (20.f) // 分享平台按钮至取消按钮间距

#define kXMDefaultPlatformNameFontColor (UIColorFromRGB(0x22222d))
#define kXMDefaultShareViewColor        ([UIColor whiteColor])

#define kXMCancelButtonNormalImageName      (@"XMSharePanelCancelButton_normal")
#define kXMCancelButtonHighlightedImageName (@"XMSharePanelCancelButton_selected")

#define kXMShareSeparatorLineColor      (UIColorFromRGB(0xe1e1e1))
#define kXMShareSeparatorLineHeight     (0.5f)



@interface NSBundle (NSString)
+ (NSBundle *)bundleWithString:(NSString *)subBundleName;
@end

@implementation NSBundle (NSString)

+ (NSBundle *)bundleWithString:(NSString *)subBundleName
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:subBundleName ofType:@"bundle"];
    return [NSBundle bundleWithPath:bundlePath];
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                                    BEGIN XMTextImageButton
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

#define kTextImageButtonSpacingDefault (8.f)
#define kTextImageButtonPlaceholder    (5.f)


typedef NS_ENUM(NSUInteger, XMTextImageButtonType) {
    kXMTextImageButtonTypeLeftText,  // 文字在左，图片在右
    kXMTextImageButtonTypeRightText, // 文字在右，图片在左
    kXMTextImageButtonTypeTopText,   // 文字在上，图片在下
    kXMTextImageButtonTypeBottomText,// 文字在下，图片在上
};

@interface XMTextImageButton : UIButton

@property (nonatomic, assign, readonly) NSUInteger type;
@property (nonatomic, assign, readonly) CGFloat    spacing;
@property (nonatomic, copy, readonly)   NSString  *title;
@property (nonatomic, strong, readonly) UIImage   *image;

+ (XMTextImageButton *)buttonWithTitle:(NSString *)title image:(UIImage *)image;

@end

@implementation XMTextImageButton

+ (XMTextImageButton *)buttonWithTitle:(NSString *)title image:(UIImage *)image
{
    XMTextImageButton *aButton = [XMTextImageButton buttonWithType:UIButtonTypeCustom];
    if (aButton) {
        [aButton _initWithTitle:title image:image];
    }

    return aButton;
}


#pragma mark - setter property for XMTextImageButton

- (void)setType:(NSUInteger)type
{
    _type = type;
    
    [self layoutIfNeeded];
}


- (void)setSpacing:(CGFloat)spacing
{
    _spacing = spacing;
    
    [self layoutIfNeeded];
}


#pragma mark - private method for XMTextImageButton

- (void)_initWithTitle:(NSString *)title image:(UIImage *)image
{
    _type = kXMTextImageButtonTypeBottomText;
    _spacing = kTextImageButtonSpacingDefault;
    _title = title;
    _image = image;
    
    [self _initCustomViews];
}


- (void)_initCustomViews
{
    [self setClipsToBounds:NO];
    [self.titleLabel setClipsToBounds:NO];
    [self.imageView setClipsToBounds:NO];
    [self setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    [self setTitle:_title forState:UIControlStateNormal];
    [self setTitleColor:kXMDefaultPlatformNameFontColor forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont systemFontOfSize:kXMDefaultPlatformNameFontSize]];
    
    [self setImage:_image forState:UIControlStateNormal];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIEdgeInsets titleInset = UIEdgeInsetsZero;
    UIEdgeInsets imageInset = UIEdgeInsetsZero;
    
    CGSize  titleSize = [_title sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    CGSize  imageSize = _image.size;
    CGFloat totalWidth = CGRectGetWidth(self.bounds);
    CGFloat totalHeight = CGRectGetHeight(self.bounds);
    CGFloat placeholder = kTextImageButtonPlaceholder; // 图片离边框的间距
    CGFloat spacing = _spacing; //图片与文件之间的间距
    
    switch (_type) {
        case kXMTextImageButtonTypeLeftText: {
            titleInset = UIEdgeInsetsMake((totalHeight - titleSize.height) * 0.5, - (imageSize.width - placeholder) , 0, 0);
            imageInset = UIEdgeInsetsMake((totalHeight - imageSize.height) * 0.5, titleSize.width + spacing + placeholder, 0, 0);
        }
            break;
            
        case kXMTextImageButtonTypeRightText: {
            titleInset = UIEdgeInsetsMake((totalHeight - titleSize.height) * 0.5, spacing + placeholder , 0, 0);
            imageInset = UIEdgeInsetsMake((totalHeight - imageSize.height) * 0.5, placeholder, 0, 0);
        }
            break;
            
        case kXMTextImageButtonTypeTopText: {
            titleInset = UIEdgeInsetsMake(placeholder, (totalWidth - titleSize.width) * 0.5 - imageSize.width, 0, 0);
            imageInset = UIEdgeInsetsMake(titleSize.height + spacing + placeholder, (totalWidth - imageSize.width) * 0.5, 0, 0);
        }
            break;
            
        case kXMTextImageButtonTypeBottomText: {
            titleInset = UIEdgeInsetsMake(imageSize.height + spacing + placeholder, (totalWidth - titleSize.width) * 0.5 - imageSize.width, 0, 0);
            imageInset = UIEdgeInsetsMake(placeholder, (totalWidth - imageSize.width) * 0.5, 0, 0);
        }
            break;
            
        default:
            break;
    }
    
    self.titleEdgeInsets = titleInset;
    self.imageEdgeInsets = imageInset;
}

@end
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                                    END XMTextImageButton
//
////////////////////////////////////////////////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                                    BEGIN XMShareView
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - XMShareView

@interface XMShareView ()

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong, readwrite) NSArray<NSString *> *platforms;
@property (nonatomic, strong, readwrite) NSMutableArray<UIButton *> *buttons;

@end


@implementation XMShareView

- (instancetype)init
{
    if ((self = [super init])) {
        self.frame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), kXMDefaultSharePanelHeight);
        self.backgroundColor = kXMDefaultShareViewColor;
    }
    return self;
}


+ (XMShareView *)shareViewWithPlatforms:(NSArray<NSString *> *)platforms
{
    XMShareView *shareView = [[XMShareView alloc] init];
    if (shareView) {
        [shareView setWillBeDisplayedPlatforms:platforms];
    }
    return shareView;
}


- (void)setWillBeDisplayedPlatforms:(NSArray<NSString *> *)platforms
{
    self.platforms = platforms;
    
    /**
     *  add cancel button
     */
    CGFloat offsetY = kXMDefaultSharePanelHeight - kXMShareSpacingToMargin - kXMShareCancelButtonHeight;
    
    self.cancelButton.frame = CGRectMake(kXMShareSpacingToMargin, offsetY, CGRectGetWidth([[UIScreen mainScreen] bounds]) - 2 * kXMShareSpacingToMargin, kXMShareCancelButtonHeight);
    self.frame = CGRectMake(0, CGRectGetHeight([[UIScreen mainScreen] bounds]), CGRectGetWidth([[UIScreen mainScreen] bounds]), kXMDefaultSharePanelHeight);
}


#pragma mark - events

- (void)didTapSharePlatform:(id)sender
{
    if ([sender isKindOfClass:[XMTextImageButton class]]) {
        XMTextImageButton *aButton = (XMTextImageButton *)sender;
        
        if ([self.delegate respondsToSelector:@selector(shareView:didTapWithPlatformIndex:)]) {
            [self.delegate shareView:self didTapWithPlatformIndex:aButton.tag];
        }
    }
}


- (void)didTapCancelButton:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        if ([self.delegate respondsToSelector:@selector(shareView:didTapCancelButton:)]) {
            [self.delegate shareView:self didTapCancelButton:sender];
        }
    }
}


#pragma mark - helper | private method
/**
 *  获得可滚动的视图容器
 *
 *  @param size 内容大小
 *
 *  @return 滚动视图
 */
- (UIScrollView *)_containerOfScrollViewWithSize:(CGSize)size
{
    UIScrollView *aScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), size.height)];
    
    aScrollView.backgroundColor = [UIColor clearColor];
    aScrollView.contentSize = size;
    aScrollView.pagingEnabled = YES;
    aScrollView.showsHorizontalScrollIndicator = NO;
    aScrollView.showsVerticalScrollIndicator = NO;
    
    return aScrollView;
}


/**
 *  获取显示面板上平台的名称
 *
 *  @param platform 平台类型
 *
 *  @return 可见的平台名称
 */
- (NSString *)_shownTitleForPlatformName:(NSString *)platformName
{
    return [[NSBundle mainBundle] localizedStringForKey:platformName value:nil table:kXMTableStringFileName];
}


/**
 *  获取显示面板上的平台图片
 *
 *  @param platform 公开的平台名称
 *
 *  @return 可点击的平台图片
 */
- (UIImage *)_shownImageForPlatformName:(NSString *)platform
{
    NSString *imageName = nil;
    
    XMSharePlatform platformType = [self _platformTypeForPlatformName:platform];
    switch (platformType) {
        case kXMSharePlatformQQFriend: {
            imageName = kXMSharePlatformQQFriendImageName;
        }
            break;
            
        case kXMSharePlatformQQZone: {
            imageName = kXMSharePlatformQQZoneImageName;
        }
            break;
            
        case kXMSharePlatformWeixinSession: {
            imageName = kXMSharePlatformWeixinSessionImageName;
        }
            break;
            
        case kXMSharePlatformWeixinTimeline: {
            imageName = kXMSharePlatformWeixinTimelineImageName;
        }
            break;
        
        case kXMSharePlatformSinaWeibo: {
            imageName = kXMSharePlatformSinaWeiboImageName;
        }
            break;
            
        case kXMSharePlatformCopyLink: {
            imageName = kXMSharePlatformCopyLinkImageName;
        }
            break;
            
        case kXMSharePlatformSMS: {
            imageName = kXMSharePlatformSMSImageName;
        }
            break;
            
        case kXMSharePlatformEmail: {
            imageName = kXMSharePlatformEmailImageName;
        }
            break;
          
        case kXMSharePlatformBaiduHi: {
            imageName = kXMSharePlatformBaiduHiImageName;
        }
            break;
            
        case kXMSharePlatformMoreOptions: {
            imageName = kXMSharePlatformMoreOptionsImageName;
        }
            break;
            
        default: {
            XM_SHARE_LOG(@"UnSupported Platform ~^~");
        }
            break;
    }
    
    if (!imageName) {
        return nil;
    }

    return [UIImage imageNamed:imageName];
}


- (XMSharePlatform)_platformTypeForPlatformName:(NSString *)platformName
{
    if ([platformName isEqualToString:kXM_SHARE_PLATFORM_QQ_FRIEND]) {
        return kXMSharePlatformQQFriend;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_QQ_ZONE]) {
        return kXMSharePlatformQQZone;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_WEIXIN_SESSION]) {
        return kXMSharePlatformWeixinSession;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_WEIXIN_TIMELINE]) {
        return kXMSharePlatformWeixinTimeline;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_SINAWEIBO]) {
        return kXMSharePlatformSinaWeibo;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_BAIDUHI]) {
        return kXMSharePlatformBaiduHi;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_SMS]) {
        return kXMSharePlatformSMS;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_EMAIL]) {
        return kXMSharePlatformEmail;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_COPY_LINK]) {
        return kXMSharePlatformCopyLink;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_MORE_OPTIONS]) {
        return kXMSharePlatformMoreOptions;
    } else {
        return kXMSharePlatformUnSupported;
    }    
}


- (NSArray *)_thirdPlatforms
{
    NSMutableArray<NSString *> *filterPlatforms = [NSMutableArray<NSString *> array];
    NSArray<NSString *> *containPlatforms = @[
                                  kXM_SHARE_PLATFORM_QQ_FRIEND,
                                  kXM_SHARE_PLATFORM_QQ_ZONE,
                                  kXM_SHARE_PLATFORM_WEIXIN_SESSION,
                                  kXM_SHARE_PLATFORM_WEIXIN_TIMELINE,
                                  kXM_SHARE_PLATFORM_SINAWEIBO,
                                  kXM_SHARE_PLATFORM_BAIDUHI
                                  ];
    for (NSString *name in self.platforms) {
        if ([containPlatforms containsObject:name]) {
            [filterPlatforms addObject:name];
        }
    }
    return filterPlatforms;
}


- (NSArray *)_generalPlatforms
{
    NSMutableArray<NSString *> *filterPlatforms = [NSMutableArray<NSString *> array];
    NSArray<NSString *> *containPlatforms = @[
                                  kXM_SHARE_PLATFORM_SMS,
                                  kXM_SHARE_PLATFORM_EMAIL,
                                  kXM_SHARE_PLATFORM_COPY_LINK,
                                  kXM_SHARE_PLATFORM_MORE_OPTIONS
                                  ];
    for (NSString *name in self.platforms) {
        if ([containPlatforms containsObject:name]) {
            [filterPlatforms addObject:name];
        }
    }
    return filterPlatforms;
}


- (UIView *)_separatorView {
    UIView *separator = [[UIView alloc] init];
    separator.backgroundColor = kXMShareSeparatorLineColor;
    separator.frame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), kXMShareSeparatorLineHeight);
    return separator;
}


#pragma mark - getter property

- (NSMutableArray<UIButton *> *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray<UIButton *> array];
    }
    return _buttons;
}


- (UIButton *)cancelButton {
    if (!_cancelButton) {
        CGFloat offsetY = kXMDefaultSharePanelHeight - kXMShareSpacingToMargin - kXMShareCancelButtonHeight;
        UIImage *normalImage = [UIImage imageNamed:kXMCancelButtonNormalImageName];
        UIImage *highlightedImage = [UIImage imageNamed:kXMCancelButtonHighlightedImageName];
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setFrame:CGRectMake(kXMShareSpacingToMargin, offsetY, CGRectGetWidth([[UIScreen mainScreen] bounds]) - 2 * kXMShareSpacingToMargin, kXMShareCancelButtonHeight)];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:kXMDefaultPlatformNameFontColor forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[normalImage stretchableImageWithLeftCapWidth:2 topCapHeight:2] forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[highlightedImage stretchableImageWithLeftCapWidth:2 topCapHeight:2] forState:UIControlStateHighlighted];
        [_cancelButton addTarget:self action:@selector(didTapCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_cancelButton];
    }
    
    return _cancelButton;
}

@end
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                                    END XMShareView
//
////////////////////////////////////////////////////////////////////////////////////////////////////////







////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                                    BEGIN XMSDefaultView
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMSDefaultView

/**
 *  默认的分享视图面板实现：多页显示方式，每页两行，每行最多显示四个分享平台
 */
@implementation XMSDefaultView

+ (XMSDefaultView *)shareViewWithPlatforms:(NSArray<NSString *> *)platforms
{
    XMSDefaultView *aView = [[XMSDefaultView alloc] init];
    if (aView) {
        [aView setWillBeDisplayedPlatforms:platforms];
    }
    return aView;
}


- (void)setWillBeDisplayedPlatforms:(NSArray<NSString *> *)platforms
{
    [super setWillBeDisplayedPlatforms:platforms];
    [self _setupPlatforms];
}


- (void)_setupPlatforms
{
    const NSInteger counts = [self.platforms count]; // 可显示的平台数
    const NSInteger platformsPerRow = kXMMaxPlatformColumnsPerRow; // 单行可显示的最大平台数
    const NSInteger maxRowsPerPage = 2;  // 单页可显示的最大行数
    const NSInteger maxPlatformsPerPage = platformsPerRow * maxRowsPerPage;
    const NSInteger rows = (counts + (platformsPerRow - 1)) / platformsPerRow; // 可显示的总行数
    const NSInteger pages = (rows + (maxRowsPerPage - 1)) / maxRowsPerPage;    // 页数
    const CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    
    CGFloat rowSpacing = 0.f;                        // 行与行之间的间隙
    CGFloat leftSpacing = 0.f;
    CGFloat topSpacing  = kXMShareSpacingToMargin;  // 滚动视图距离上边界的距离
    CGFloat pWidth = kXMSharePlatformButtonWidth;   // 默认单个分享按钮的宽度
    CGFloat pHeight = kXMSharePlatformButtonHeight; // 单个分享按钮的高度
    CGFloat spacing = 0.f;                           //分享按钮之间的间距
    CGFloat actualContainerHeight = (rows >= maxRowsPerPage) ? maxRowsPerPage * kXMSharePlatformButtonHeight : kXMSharePlatformButtonHeight + rowSpacing * (maxRowsPerPage - 1);
    CGFloat actualSharePanelHeight = 2 * kXMShareSpacingToMargin + actualContainerHeight + kXMShareSpacingPlatformToCancel + kXMShareCancelButtonHeight;
    
    /**
     *  当屏幕宽度不容忍放下默认定义的4个按钮宽度时，按钮宽度变小，之间间距为0
     *  否则，按钮宽度为默认宽度kXMSharePlatformButtonWidth，间距根据计算所得
     */
    if ((width - 2 * leftSpacing) > (pWidth * platformsPerRow)) {
        pWidth = kXMSharePlatformButtonWidth;
        spacing = (width - pWidth * platformsPerRow - 2 * leftSpacing) / (platformsPerRow + 1); //分享按钮之间的间距
    } else {
        pWidth = (width - 2 * leftSpacing) / platformsPerRow;
        spacing = 0.f;
    }
    
    //添加滚动视图
    UIScrollView *containerView = [self _containerOfScrollViewWithSize:CGSizeMake(width * pages, actualContainerHeight)];
    [containerView setFrame:CGRectMake(0, topSpacing, width, actualContainerHeight)];
    [self addSubview:containerView];
    
    // layout cancel button
    self.frame = CGRectMake(0, CGRectGetHeight([[UIScreen mainScreen] bounds]), width, actualSharePanelHeight);
    self.cancelButton.frame = CGRectMake(kXMShareSpacingToMargin, actualSharePanelHeight - kXMShareSpacingToMargin - kXMShareCancelButtonHeight, CGRectGetWidth([[UIScreen mainScreen] bounds]) - 2 * kXMShareSpacingToMargin, kXMShareCancelButtonHeight);
    
    //对每页进行处理
    CGFloat offsetX = leftSpacing + spacing, offsetY = 0.f;
    for (NSInteger pageIdx = 0; pageIdx < pages; pageIdx++) {
        
        NSInteger platformsOfCurrentPage = MIN(counts, (pageIdx + 1) * maxPlatformsPerPage)  - pageIdx * maxPlatformsPerPage;
        NSInteger rowsOfCurrentPage = (platformsOfCurrentPage + (platformsPerRow - 1)) / platformsPerRow; //当前页的行数
        
        // 初始化每页分享按钮的开始显示位置
        offsetX = pageIdx * width + leftSpacing + spacing;
        offsetY = 0.f;
        for (NSInteger rowIdx = 0; rowIdx < rowsOfCurrentPage; rowIdx++) {
            
            NSInteger platformsOfCurrentRow = MIN(platformsOfCurrentPage, (rowIdx + 1) * platformsPerRow) - rowIdx * platformsPerRow;
        
            if (rowsOfCurrentPage <= 1) {
                spacing = (width - pWidth * platformsOfCurrentRow) / (platformsOfCurrentRow + 1);
            }
            
            offsetY = rowIdx * (pHeight + rowSpacing);
            // 对每行中每个平台进行处理
            for (NSInteger colIdx = 0; colIdx < platformsOfCurrentRow; colIdx++) {
                offsetX = pageIdx * width + leftSpacing + (colIdx + 1) * spacing + colIdx * pWidth;
                
                NSInteger tagIdx = pageIdx * maxRowsPerPage * platformsPerRow + rowIdx * platformsPerRow + colIdx;
                NSString *name = [self.platforms objectAtIndex:tagIdx];
                NSString *title = [self _shownTitleForPlatformName:name];
                UIImage  *platformImage = [self _shownImageForPlatformName:name];
                
                XMTextImageButton *aButton = [XMTextImageButton buttonWithTitle:title image:platformImage];
                [aButton setFrame:CGRectMake(offsetX, offsetY, pWidth, pHeight)];
                [aButton addTarget:self action:@selector(didTapSharePlatform:) forControlEvents:UIControlEventTouchUpInside];
                [aButton setTag:tagIdx];

                [containerView addSubview:aButton];
                [self.buttons addObject:aButton];
            }
        }
    }
}

@end
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                                    END XMSDefaultView
//
////////////////////////////////////////////////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                                    BEGIN XMSLineScrollView
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - XMSLineScrollView

/**
 *  可滚动的分享视图面板实现
 */
@implementation XMSLineScrollView

+ (XMSLineScrollView *)shareViewWithPlatforms:(NSArray<NSString *> *)platforms
{
    XMSLineScrollView *aView = [[XMSLineScrollView alloc] init];
    if (aView) {
        [aView setWillBeDisplayedPlatforms:platforms];
    }
    return aView;
}


- (void)setWillBeDisplayedPlatforms:(NSArray<NSString *> *)platforms
{
    [super setWillBeDisplayedPlatforms:platforms];
    
    [self _setupPlatforms];
}


/**
 ******************************************************************************
 *******************************  Layout As Follow ****************************
 ******************************************************************************
 *
 *  ----topSpacing---
 *  ---thirdPlatforms(leftSpacing + platform + spacing + ... + leftSpacing)---
 *  ---rowSpacing---
 *  ---separatorView---
 *  ---rowSpacing---
 *  ---generalsPlatforms(leftSpacing + platform + spacing + ... + leftSpacing)---
 *  ---kXMShareSpacingPlatformToCancel---
 *  ---cancelButton---
 *  ---topSpacing---
 */
- (void)_setupPlatforms
{
    const NSArray<NSString *> *thirdPlatforms = [self _thirdPlatforms];
    const NSArray<NSString *> *generalPlatforms = [self _generalPlatforms];
    
    const CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    const CGFloat pWidth = kXMSharePlatformButtonWidth; // 单个分享按钮的宽度
    const CGFloat pHeight = kXMSharePlatformButtonHeight; // 单个分享按钮的高度
    const CGFloat topSpacing = 10.f;
    const CGFloat rowSpacing = 5.f; // 行与行之间的间隙
    const CGFloat spacing = 0.f; // 平台按钮之间的间距
    const CGFloat marginSpacing = 0.f;
    CGFloat offsetX = marginSpacing;
    CGFloat offsetY = topSpacing;
    CGFloat totalHeight = topSpacing;
    
    //添加第三方平台滚动视图
    CGFloat contentWidth = width;
    NSInteger tagIndex = 0;
    
    if ([thirdPlatforms count] > 0) {

        contentWidth = marginSpacing * 2 + ([thirdPlatforms count] * (pWidth + spacing) - spacing);
        
        UIScrollView *thirdContainerView = [self _containerOfScrollViewWithSize:CGSizeMake(contentWidth, pHeight)];
        thirdContainerView.pagingEnabled = NO;
        thirdContainerView.frame = CGRectMake(0, offsetY, width, pHeight);
        thirdContainerView.contentSize = CGSizeMake(MAX(contentWidth, width), pHeight);
        [self addSubview:thirdContainerView];
        
        for (NSString *name in thirdPlatforms) {
            NSString *titleString = [self _shownTitleForPlatformName:name];
            UIImage  *imageString = [self _shownImageForPlatformName:name];
            
            offsetX = marginSpacing + ([thirdPlatforms indexOfObject:name]) * (pWidth + spacing);
            
            XMTextImageButton *aButton = [XMTextImageButton buttonWithTitle:titleString image:imageString];
            [aButton setFrame:CGRectMake(offsetX, 0.f, pWidth, pHeight)];
            [aButton addTarget:self action:@selector(didTapSharePlatform:) forControlEvents:UIControlEventTouchUpInside];
            [aButton setTag:tagIndex++];
            
            [thirdContainerView addSubview:aButton];
            [self.buttons addObject:aButton];
        }
        
        offsetY += CGRectGetHeight(thirdContainerView.bounds);
        totalHeight += CGRectGetHeight(thirdContainerView.bounds);
    }
    
    if ([self _showMiddleSeparatorLineWithThirdPlatforms:thirdPlatforms generalPlatforms:generalPlatforms]) {
        UIView *separatorView = [self _separatorView];
        separatorView.frame = CGRectMake(0.f, offsetY + rowSpacing / 2, width, kXMShareSeparatorLineHeight);
        [self addSubview:separatorView];
        
        offsetY += kXMShareSeparatorLineHeight;
        totalHeight += kXMShareSeparatorLineHeight;
    }
    
    //添加其它平台可滚动视图
    if ([generalPlatforms count] > 0) {
        
        totalHeight += rowSpacing;
        offsetY += rowSpacing;
        
        contentWidth = marginSpacing * 2 + ([generalPlatforms count] * (pWidth + spacing) - spacing);
        
        UIScrollView *othersContainerView = [self _containerOfScrollViewWithSize:CGSizeMake(contentWidth, pHeight)];
        othersContainerView.pagingEnabled = NO;
        othersContainerView.frame = CGRectMake(0, offsetY, width, pHeight);
        othersContainerView.contentSize = CGSizeMake(MAX(contentWidth, width), pHeight);
        [self addSubview:othersContainerView];
        
        for (NSString *name in generalPlatforms) {
            NSString *titleString = [self _shownTitleForPlatformName:name];
            UIImage  *imageString = [self _shownImageForPlatformName:name];
           
            offsetX = marginSpacing + [generalPlatforms indexOfObject:name] * (pWidth + spacing);
            
            XMTextImageButton *aButton = [XMTextImageButton buttonWithTitle:titleString image:imageString];
            [aButton setFrame:CGRectMake(offsetX, 0.f, pWidth, pHeight)];
            [aButton addTarget:self action:@selector(didTapSharePlatform:) forControlEvents:UIControlEventTouchUpInside];
            [aButton setTag:tagIndex++];
            
            [othersContainerView addSubview:aButton];
            [self.buttons addObject:aButton];
        }
        
        offsetY += CGRectGetHeight(othersContainerView.bounds);
        totalHeight += CGRectGetHeight(othersContainerView.bounds);
    }
    
    offsetY += kXMShareSpacingPlatformToCancel;
    totalHeight += kXMShareSpacingPlatformToCancel;
    self.cancelButton.frame = CGRectMake(kXMShareSpacingToMargin, offsetY, CGRectGetWidth([[UIScreen mainScreen] bounds]) - 2 * kXMShareSpacingToMargin, kXMShareCancelButtonHeight);
    
    totalHeight += (kXMShareCancelButtonHeight + topSpacing);
    self.frame = CGRectMake(0, CGRectGetHeight([[UIScreen mainScreen] bounds]), width, totalHeight);
}


#pragma mark - private for XMSLineScrollView

- (BOOL)_showMiddleSeparatorLineWithThirdPlatforms:(const NSArray<NSString *> * const)thirdPlatforms generalPlatforms:(const NSArray<NSString *> * const)generalPlatforms {
    return ([thirdPlatforms count] > 0) && ([generalPlatforms count] > 0);
}

@end
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                                    END XMSLineScrollView
//
////////////////////////////////////////////////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                                    BEGIN XMSLineToOneView
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - XMSLineToOneView
/**
 *  多行单个平台的分享面板实现
 */
@implementation XMSLineToOneView

+ (XMSLineToOneView *)shareViewWithPlatforms:(NSArray<NSString *> *)platforms
{
    XMSLineToOneView *aView = [[XMSLineToOneView alloc] init];
    if (aView) {
        [aView setWillBeDisplayedPlatforms:platforms];
    }
    return aView;
}


- (void)setWillBeDisplayedPlatforms:(NSArray<NSString *> *)platforms
{
    [super setWillBeDisplayedPlatforms:platforms];
    
    [self _setupPlatforms];
}


- (void)_setupPlatforms
{
    NSInteger counts = [self.platforms count]; // 可显示的平台数
    NSInteger rows = counts; // 单页可显示的行数
    
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CGFloat height = kXMDefaultSharePanelHeight;
    CGFloat heightOfRow = 50.f;
    CGFloat spacing = 12.f; // 默认平台之间的间隙
    
    //添加滚动视图
    UIScrollView *containerView = [self _containerOfScrollViewWithSize:CGSizeMake(width, height)];
    containerView.contentSize = CGSizeMake(width, rows * (heightOfRow + spacing) - spacing);
    [self addSubview:containerView];
    
    CGFloat offsetX = 12.f, offsetY = 24.f ;
    //对每行进行处理
    for (NSInteger rowIdx = 0; rowIdx < rows; rowIdx++) {
        NSString *name = [self.platforms objectAtIndex:rowIdx];
        NSString *title = [self _shownTitleForPlatformName:name];
        UIImage  *platformImage = [self _shownImageForPlatformName:name];
    
        XMTextImageButton *aButton = [XMTextImageButton buttonWithTitle:title image:platformImage];
        [aButton setFrame:CGRectMake(offsetX, offsetY, width, heightOfRow)];
        [aButton setBackgroundColor:[UIColor clearColor]];
        [aButton setTag:rowIdx];
        [aButton addTarget:self action:@selector(didTapSharePlatform:) forControlEvents:UIControlEventTouchUpInside];
        
        [containerView addSubview:aButton];
        
        offsetY = offsetY + CGRectGetHeight(aButton.frame) + spacing;
    }
}

@end
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                                    END XMSLineToOneView
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

BOOL panelIsShowing = NO;

/**
 *  Extension Of XMSharePanel
 */
@interface XMSharePanel ()
<
XMTranslucencyViewDelegate,
XMShareViewDelegate
>
@property (nonatomic, assign, readwrite) XMSharePanelStyle panel;
@property (nonatomic, strong, readwrite) NSArray<NSString *> *platforms;
@property (nonatomic, strong, readwrite) XMShareObject *shareObject;
@property (nonatomic, strong, readwrite) XMShareView *containerView;
@property (nonatomic, strong, readwrite) XMTranslucencyView *translucencyView;
@end

/**
 *  Implementation Of XMSharePanel
 */
@implementation XMSharePanel

+ (XMSharePanel *)sharePanelWithStyle:(XMSharePanelStyle)panelStyle
{
    XMSharePanel *sharePanel = [[XMSharePanel alloc] init];
    
    sharePanel.panel = panelStyle;
    
    switch (panelStyle) {
        case kXMSharePanelLineToOne: {
            sharePanel.containerView = [[XMSLineToOneView alloc] init];
        }
            break;
            
        case kXMSharePanelLineScroll: {
            sharePanel.containerView = [[XMSLineScrollView alloc] init];
        }
            break;
            
        default: { // XMSharePanelDefault
            sharePanel.containerView = [[XMSDefaultView alloc] init];
        }
            break;
    }
    [sharePanel.containerView setDelegate:sharePanel];
    
    return sharePanel;
}


+ (XMSharePanel *)sharePanelWithStyle:(XMSharePanelStyle)style displayedPlatforms:(NSArray<NSString *> *)platforms shareObject:(XMShareObject *)shareObject
{
    XMSharePanel *aPanel = [XMSharePanel sharePanelWithStyle:style];
    [aPanel setWillBeDisplayedPlatforms:platforms shareObject:shareObject];
    return aPanel;
}


- (void)setWillBeDisplayedPlatforms:(NSArray<NSString *> *)platforms shareObject:(XMShareObject *)shareObject
{
    self.shareObject = shareObject;
    self.platforms = platforms;
    
    [self.containerView setWillBeDisplayedPlatforms:platforms];
}


- (void)dealloc {
    [_containerView.layer removeAllAnimations];
    [_containerView removeFromSuperview];
    _containerView = nil;
    
    [_translucencyView.layer removeAllAnimations];
    [_translucencyView removeFromSuperview];
    _translucencyView = nil;
}


- (void)showWithCompletionHandler:(XMAnimationCompletionHandler)animationCompletionHandler
{
    panelIsShowing = YES;
    
    // add animations
    [self.translucencyView addSubview:self.containerView];
    __weak typeof(self) weakSelf = self;
    [self.translucencyView showWithCompletionHandler:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        strongSelf.containerView.frame = CGRectMake(0, CGRectGetHeight(screenRect), CGRectGetWidth(screenRect), CGRectGetHeight(strongSelf.containerView.frame));
        strongSelf.containerView.alpha = 0.5f;
        
        [UIView animateWithDuration:0.2 animations:^{
            __strong typeof(weakSelf) strongSelf2 = weakSelf;
            strongSelf2.containerView.frame = CGRectMake(0, CGRectGetHeight(screenRect) - CGRectGetHeight(strongSelf2.containerView.frame), CGRectGetWidth(screenRect), CGRectGetHeight(strongSelf2.containerView.frame));
            strongSelf2.containerView.alpha = 1.0f;
        }];
    }];
}


- (void)dismissWithCompletionHandler:(XMAnimationCompletionHandler)animationCompletionHandler
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^(void) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        CGRect containerFrame = strongSelf.containerView.frame;
        containerFrame.origin.y = CGRectGetHeight([[UIScreen mainScreen] bounds]);
        strongSelf.containerView.frame = containerFrame;
    } completion:^(BOOL finished) {
        __weak typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.containerView.hidden = YES;
        strongSelf.containerView.alpha  = 0;
        [strongSelf.containerView removeFromSuperview];
        
        [strongSelf.translucencyView dismissWithCompletionHandler:animationCompletionHandler];
    }];
    
    panelIsShowing = NO;
}


#pragma mark - delegate event for XMShareViewDelegate

- (void)shareView:(XMShareView *)aView didTapCancelButton:(UIButton *)tappedButton
{
    if ([tappedButton isKindOfClass:[UIButton class]]) {
        [self dismissWithCompletionHandler:nil];
    }
}


- (void)shareView:(XMShareView *)aView didTapWithPlatformIndex:(NSUInteger)tappedIndex
{
    if ([self.delegate respondsToSelector:@selector(sharePanel:didTapWithPlatformIndex:)]) {
        [self.delegate sharePanel:self didTapWithPlatformIndex:tappedIndex];
    }
}


#pragma mark - delegate event for XMTranslucencyViewDelegate

- (void)translucencyView:(UIView *)view didTapGuesture:(UITapGestureRecognizer *)tapGesture
{
    [self dismissWithCompletionHandler:nil];
}


#pragma mark - getter property

- (XMTranslucencyView *)translucencyView
{
    if (!_translucencyView) {
        _translucencyView = [[XMTranslucencyView alloc] init];
        _translucencyView.delegate = self;
    }
    return _translucencyView;
}


#pragma mark - to assure showing single panel

+ (BOOL)isShowing {
    return panelIsShowing;
}

@end
     