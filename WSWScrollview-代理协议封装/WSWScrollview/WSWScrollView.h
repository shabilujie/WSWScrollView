//
//  WSWScrollView.h
//  WSWScrollview
//
//  Created by shengwei on 16/3/7.
//  Copyright © 2016年 laolai. All rights reserved.
/*
 
 提示:网络图片加载,直接用的SDWebImage,想用系统原生方法或者其他下载图片框架或者需要图片本地化的,可以手动去.m中替换加载网络图片部分的代码
 
 */

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ScrollWithDefault = 1,//默认情况..最常见的一屏一屏滚动
    ScrollWithParallax,//有视差的滚动
    ScrollWithThreePages,//显示三张图片
} ScrollViewMode ;

@protocol WSWScrollViewDataSource;
@protocol WSWScrollViewDelegate;

@interface WSWScrollView : UIView

@property (nonatomic, assign) id<WSWScrollViewDelegate  > delegate;
@property (nonatomic, assign) id<WSWScrollViewDataSource> dataSource;

//时间控制器
@property (nonatomic, strong) NSTimer                 *timer;
//滚动视图的样式
@property (nonatomic, assign) ScrollViewMode          scrollViewMode;
//计时器的间隔时间
@property (nonatomic, assign) CGFloat                 timeInterval;

/**
 *  实例化方法
 *
 *  @param frame          轮播图区域
 *  @param scrollViewMode 轮播方式:1.正常左右衔接轮播;2.上下叠加视差轮播;3,多屏图片轮播
 *
 *  @return
 */
- (instancetype)initWithFrame:(CGRect)frame andScrollViewMode:(ScrollViewMode)scrollViewMode;


/**
 *  添加一个时间控制器(用于手动控制)
 */
- (void)addTimer;
/**
 *  清除事件控制器(用于手动控制)
 */
- (void)clearTimer;


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

/**
 *  给模式三提供每张图片的大小
 *
 *  @param scrollView
 *
 *  @return
 */
- (CGRect)scrollViewWithThreePagesCenterItemFrameForWSWScrollView:(WSWScrollView *)scrollView;
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