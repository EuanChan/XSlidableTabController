//
//  XSlidableTab.m
//  cncn.
//
//  Created by Euan Chan on 13-10-9.
//  Copyright (c) 2013 cncn. All rights reserved.
//

#import "XSlidableTab.h"

static const NSInteger kBtnWidthDefault = 60;
static const NSInteger kBtnHeightDefault = 29;
static const NSInteger kBtnGapDefault = 10;
static const NSInteger kBtnFontSizeDefault = 15;

@interface XSlidableTab ()

@property (strong, nonatomic) NSMutableArray *titles;
@property (strong, nonatomic) NSMutableArray *titleBtnFrameArr;

@property (strong, nonatomic) UIScrollView   *scrollView;
@property (assign, nonatomic) CGFloat         scrollViewMarginLeft;
@property (assign, nonatomic) CGFloat         scrollViewMarginRight;

@property (assign, nonatomic) NSInteger       selectIndex;
@property (strong, nonatomic) UIImageView    *selectedBgView;

@end

@implementation XSlidableTab

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupDefault];
    }
    return self;
}

- (void)setupDefault
{
    _btnWidth = kBtnWidthDefault;
    _btnHeight = kBtnHeightDefault;
    _btnGap = kBtnGapDefault;
    _btnFontSize = kBtnFontSizeDefault;
    _scrollViewMarginLeft = _btnGap;
    _scrollViewMarginRight = _btnGap;
    
    self.titleColorNormal = kUITabMenuTextColor;
    self.titleColorSelected = kUITabMenuTextColorSelect;
    
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tab_menu_bg"]];
}

static const NSInteger kTitleBtnBaseTag = 2047;
- (void)updateWithTitles:(NSArray *)titles
{
    self.titles = [NSMutableArray arrayWithArray:titles];
    self.titleBtnFrameArr = [[NSMutableArray alloc] initWithCapacity:[self.titles count]];
    
    [self.scrollView removeFromSuperview];
    CGRect rtContent = CGRectMake(_scrollViewMarginLeft, 0, self.bounds.size.width - _scrollViewMarginLeft - _scrollViewMarginRight, self.bounds.size.height);
    self.scrollView = [[UIScrollView alloc] initWithFrame:rtContent];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    CGFloat posX = _btnGap;
    for (NSInteger i = 0; i < [self.titles count]; ++i) {
        NSString *title = self.titles[i];
        CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:_btnFontSize] constrainedToSize:CGSizeMake(CGFLOAT_MAX, _btnHeight)];
        
        CGRect rtTitleBtn = CGRectMake(posX, 0, titleSize.width + _btnGap * 2, _btnHeight);
        UIButton *titleBtn = [[UIButton alloc] initWithFrame:rtTitleBtn];
        [titleBtn setTag:kTitleBtnBaseTag + i];
        [titleBtn setTitle:title forState:UIControlStateNormal];
        [titleBtn setTitleColor:self.titleColorNormal forState:UIControlStateNormal];
        [titleBtn setTitleColor:self.titleColorSelected forState:UIControlStateHighlighted];
        [titleBtn setTitleColor:self.titleColorSelected forState:UIControlStateSelected];
        [titleBtn.titleLabel setFont:[UIFont systemFontOfSize:_btnFontSize]];
        [titleBtn addTarget:self action:@selector(titleBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:titleBtn];
        
        self.titleBtnFrameArr[i] = @[@(rtTitleBtn.origin.x), @(rtTitleBtn.origin.y), @(rtTitleBtn.size.width), @(rtTitleBtn.size.height)];
        posX = rtTitleBtn.origin.x + rtTitleBtn.size.width;
    }
    
    // extend button width if titles cannt fill the scrollview.
    if (posX < self.scrollView.bounds.size.width - _btnGap) {
        CGFloat diff = self.scrollView.bounds.size.width - posX - _btnGap;
        CGFloat diffEach = diff / (CGFloat)[self.titles count];
        for (NSInteger i = 0; i < [self.titles count]; ++i) {
            UIView *titleBtn = [self.scrollView viewWithTag:kTitleBtnBaseTag + i];
            [titleBtn setLeft:titleBtn.frame.origin.x + diffEach * (CGFloat)i];
            [titleBtn setWidth:titleBtn.frame.size.width + diffEach];
            self.titleBtnFrameArr[i] = @[@(titleBtn.origin.x), @(titleBtn.origin.y), @(titleBtn.frame.size.width), @(titleBtn.size.height)];
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(posX, _btnHeight);
    
    // setup the selected background view.
    UIImage *selectedImg = [UIImage imageNamed:@"tab_menu_btn_selected"];
    CGRect rtSelectImg = [self btnAtIndex:_selectIndex].frame;
    self.selectedBgView = [[UIImageView alloc] initWithFrame:rtSelectImg];
    [self.selectedBgView setImage:[selectedImg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 12, 10, 12)]];
    [self.scrollView insertSubview:self.selectedBgView atIndex:0];
    
    [self updateSelectedTitle:[self btnAtIndex:_selectIndex]];
}

- (void)titleBtnTapped:(UIButton *)senderBtn
{
    NSInteger tappedIndex = senderBtn.tag - kTitleBtnBaseTag;
    if (tappedIndex == _selectIndex)
        return;
    
    [self updateTabMenuSelectedIndex:tappedIndex];
    [self didSelectedAtIndex:_selectIndex];
}

- (void)updateTabMenuWithPageOffsetRate:(CGFloat)offsetPagingRate
{
    // when scroll out of first/last page, let the highlight position where it's.
    NSInteger lastPage = [self.titles count] - 1;
    if (offsetPagingRate < 0 || (int)offsetPagingRate > lastPage)
        return;
    
    CGFloat highlightPosX = 0.f;
    CGFloat highlightWidth = 0.f;
    NSInteger leftPageIndex = offsetPagingRate;
    
    if (offsetPagingRate <= 0.f) {
        highlightPosX = [self.titleBtnFrameArr[0][0] floatValue];
        highlightWidth = [self.titleBtnFrameArr[0][2] floatValue];
        
    } else if (offsetPagingRate > (CGFloat)lastPage) {
        highlightPosX = [self.titleBtnFrameArr[lastPage][0] floatValue];
        highlightWidth = [self.titleBtnFrameArr[lastPage][2] floatValue];
        
    } else if (offsetPagingRate - (int)offsetPagingRate == 0.f) {
        highlightPosX = [self.titleBtnFrameArr[leftPageIndex][0] floatValue];
        highlightWidth = [self.titleBtnFrameArr[leftPageIndex][2] floatValue];
        
    } else {
        highlightPosX = [self.titleBtnFrameArr[leftPageIndex][0] floatValue];
        NSInteger rightPageIndex = leftPageIndex + 1;
        CGFloat leftTitleW = [self.titleBtnFrameArr[leftPageIndex][2] integerValue];
        CGFloat rightTitleW = [self.titleBtnFrameArr[rightPageIndex][2] integerValue];
        
        CGFloat rate = offsetPagingRate - (int)offsetPagingRate;
        highlightPosX += leftTitleW * rate;
        highlightWidth = leftTitleW * (1.f - rate) + rightTitleW * rate;
    }
    
    CGRect rtHighlight = CGRectMake(highlightPosX, 0, highlightWidth, self.selectedBgView.frame.size.height);
    [self.selectedBgView setFrame:rtHighlight];
}

- (void)updateTabMenuSelectedIndex:(NSInteger)page
{
    UIButton *btnWillDeSelect = [self btnAtIndex:_selectIndex];
    [self updateDeSelectTitle:btnWillDeSelect];
    UIButton *btnWillSelected = [self btnAtIndex:page];
    [self updateSelectedTitle:btnWillSelected];
    
    _selectIndex = page;
    
    [UIView
     animateWithDuration:0.3
     animations:^{
         [self.selectedBgView setFrame:btnWillSelected.frame];
     } completion:^(BOOL finished) {
     }];
    
    // make pre title or next title entire visible.
    if (page > 0 && page < [_titles count] - 1) {
        UIButton *preBtn = [self btnAtIndex:_selectIndex - 1];
        if (![self checkThenMoveBtnEntireVisibleHideInLeftSideIfNeed:preBtn]) {
            UIButton *nextBtn = [self btnAtIndex:_selectIndex + 1];
            [self checkThenMoveBtnEntireVisibleHideInRightSideIfNeed:nextBtn];
        }
    } else if (page == 0) {
        [self checkThenMoveBtnEntireVisibleHideInLeftSideIfNeed:[self btnAtIndex:0]];
    } else if (page == [_titles count] - 1) {
        [self checkThenMoveBtnEntireVisibleHideInRightSideIfNeed:[self btnAtIndex:[_titles count] - 1]];
    }
}

- (BOOL)checkThenMoveBtnEntireVisibleHideInLeftSideIfNeed:(UIButton *)button
{
    CGRect rtBtn = [self.scrollView convertRect:button.frame toView:self];
    if (rtBtn.origin.x < -_scrollViewMarginLeft) {
        CGPoint offset = self.scrollView.contentOffset;
        offset.x += rtBtn.origin.x - _scrollViewMarginLeft;
        [self.scrollView setContentOffset:offset animated:YES];
        return YES;
    }
    return NO;
}

- (BOOL)checkThenMoveBtnEntireVisibleHideInRightSideIfNeed:(UIButton *)button
{
    CGRect rtBtn = [self.scrollView convertRect:button.frame toView:self];
    if (rtBtn.origin.x + rtBtn.size.width > self.scrollView.frame.size.width + _scrollViewMarginRight) {
        // make next btn entire visible.
        CGFloat outWidth = self.scrollView.frame.size.width - rtBtn.origin.x - rtBtn.size.width + _scrollViewMarginRight;
        CGPoint offset = self.scrollView.contentOffset;
        offset.x -= outWidth;
        [self.scrollView setContentOffset:offset animated:YES];
        return YES;
    }
    return NO;
}

- (void)updateSelectedTitle:(UIButton *)titleBtn
{
    titleBtn.selected = YES;
}

- (void)updateDeSelectTitle:(UIButton *)titleBtn
{
    titleBtn.selected = NO;
}

- (UIButton *)btnAtIndex:(NSInteger)index
{
    UIButton *btn = (UIButton *)[_scrollView viewWithTag:(kTitleBtnBaseTag + index)];
    return btn;
}

- (void)didSelectedAtIndex:(NSInteger)index
{
    if ([_delegate respondsToSelector:@selector(segmentedController:tappedAtIndex:)])
        [_delegate segmentedController:self tappedAtIndex:index];
}

@end