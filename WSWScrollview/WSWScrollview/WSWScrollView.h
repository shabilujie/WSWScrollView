//
//  WSWScrollView.h
//  WSWScrollview
//
//  Created by shengwei on 16/3/7.
//  Copyright © 2016年 laolai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSWScrollViewDataSource;
@protocol WSWScrollViewDelegate;

@interface WSWScrollView : UIView

@property (nonatomic, assign)  id<WSWScrollViewDelegate> delegate;
@property (nonatomic, assign)  id<WSWScrollViewDataSource> dataSource;

//计时器的间隔时间
@property (nonatomic, assign) CGFloat timeInterval;
@end
/**
 *  DataSource
 */
@protocol WSWScrollViewDataSource <NSObject>

@required
/**
 *  给轮播视图提供数据源数组
 *
 *  @param scrollView
 *
 *  @return
 */
- (NSArray *)imagesArrayForWSWScrollView:(WSWScrollView *)scrollView;

@end

/**
 *  Delegate
 */
@protocol WSWScrollViewDelegate <NSObject>

@optional
/**
 *  点击事件
 *
 *  @param scrollView
 *  @param indexPath
 */
- (void)wswScroView:(WSWScrollView *)scrollView didSelectRowAtIndexPath:(NSInteger)index;

@end