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

typedef void(^CurrentImageClick)(NSInteger index);

@interface WSWScrollView : UIView

//时间控制器
@property (nonatomic, strong) NSTimer           *timer;
//滚动视图的样式
@property (nonatomic, assign) ScrollViewMode    scrollViewMode;
//计时器的间隔时间
@property (nonatomic, assign) CGFloat           timeInterval;
//当前图片点击的block
@property (nonatomic, copy  ) CurrentImageClick currentImageClickBlock;
//占位图，默认加载图片
@property(nonatomic,copy)UIImage *placeHolderImg;
//是否自动旋转
@property(nonatomic,assign)Boolean autoScroll;

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
 *  传入照片和轮播方式,返回单击图片的回调block
 *
 *  @param imagesArray            传入本地图片或者网络图片源
 *  @param scrollViewMode         轮播的方式
 *  @param currentImageClickBlock 图片点击的回调
 */
- (void)addImagesArray:(NSArray *)imagesArray centerItemFrame:(CGRect)centerItemFrame currentImageClick:(CurrentImageClick)currentImageClickBlock;

/**
 *  添加一个时间控制器(用于手动控制)
 */
- (void)addTimer;
/**
 *  清除事件控制器(用于手动控制)
 */
- (void)clearTimer;

@end
s
