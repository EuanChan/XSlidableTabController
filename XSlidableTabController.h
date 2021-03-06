//
//  XSlidableTabController.h
//  cncn.
//
//  Created by Euan Chan on 13-10-9.
//  Copyright (c) 2013 cncn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XSlidableTab;
@protocol XSlidableTabControllerDelegate;
@interface XSlidableTabController : UIViewController

@property (assign, nonatomic) id<XSlidableTabControllerDelegate> delegate;

@property (strong, nonatomic, readonly) XSlidableTab *tabView;
@property (strong, nonatomic, readonly) UIScrollView *scrollView;

@property (assign, nonatomic, readonly) NSInteger tabHeight;

- (id)initWithTabHeight:(NSInteger)tabHeight;
- (NSArray *)viewControllers;
- (void)setViewControllers:(NSArray *)viewControllerArr;

@end


@protocol XSlidableTabControllerDelegate <NSObject>

- (void)didSwitchToTabAtIndex:(NSInteger)index;

@end