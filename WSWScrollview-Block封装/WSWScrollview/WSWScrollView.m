//
//  WSWScrollView.m
//  WSWScrollview
//
//  Created by shengwei on 16/3/7.
//  Copyright © 2016年 laolai. All rights reserved.
//

#import "WSWScrollView.h"
#import "UIImageView+WebCache.h"



@interface WSWScrollView ()<UIScrollViewDelegate>
{
    //记录当前图片下标
    int _currentImageIndex;
    //记录下一张图片下标
    int _nextImageIndex;
    //记录传过来的数组是不是本地图片
    BOOL _isLocalImagesArray;
}
//滚动视图
@property (nonatomic, strong) UIScrollView   *scrollView;
//第一个图片
@property (nonatomic, strong) UIImageView    *firstImageView;
//第二个图片
@property (nonatomic, strong) UIImageView    *secondImageView;
//图片的数据源
@property (nonatomic, strong) NSMutableArray *imageDataSource;
//页面控制器
@property (nonatomic, strong) UIPageControl  *pageController;
//时间控制器
@property (nonatomic, strong) NSTimer        *timer;
@end


@implementation WSWScrollView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

-(void)addImagesArray:(NSArray *)imagesArray currentImageClick:(CurrentImageClick)currentImageClickBlock
{
    self.currentImageClickBlock = currentImageClickBlock;
    
    _isLocalImagesArray = NO;
    NSArray *array =[NSArray arrayWithArray:imagesArray];
    
    self.imageDataSource = [[NSMutableArray alloc] init];
    for (int i = 0; i<array.count; i++) {
        UIImage *image = [UIImage imageNamed:array[i]];
        if (!image) {
            continue;
        }
        _isLocalImagesArray = YES;
        //如果是本地图片,则把数组中的图片名,转化成图片保存到图片数据源数组中
        [self.imageDataSource addObject:image];
    }
    
    if (!_isLocalImagesArray) {
        //如果是网络图片,则把图片链接地址添加到图片数据源数组中
        self.imageDataSource = [NSMutableArray arrayWithArray:array];
    }
    
    //设置第一张图片
    if (_isLocalImagesArray) {
        //本地图片
        self.firstImageView.image = self.imageDataSource[_currentImageIndex];
    }else{
        //网络加载图片
        [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:[self.imageDataSource firstObject]]];
        
        //(在这里可以选择使用下面方法,添加占位图片,防止网络慢,轮播图白屏)
        //        [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:[self.urlImagesGroup firstObject]] placeholderImage:[UIImage imageNamed:@"火影01"]];
    }
    
    //设置pageController 的页数
    self.pageController.numberOfPages = self.imageDataSource.count;
    
    
    //添加时间控制器
    [self addTimer];
}


//初始化视图
- (void)initView
{
    //初始化当前图片(默认下标为0);
    _currentImageIndex = 0;
    //初始化timer间隔时间
    _timeInterval = 3.0;
    
    //添加滚动视图
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.frame), 0);
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * 3, CGRectGetHeight(self.frame));
    //添加点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [scrollView addGestureRecognizer:tap];
    //添加到父视图上
    [self addSubview:scrollView];
    self.scrollView = scrollView;

    //给滚动视图添加两个UIImageView
    UIImageView *firstImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.firstImageView = firstImageView;
    UIImageView *secondImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.secondImageView = secondImageView;

    [self.scrollView addSubview:secondImageView];
    [self.scrollView addSubview:firstImageView];
    
    //    先设置第一张图片的位置,在滚动视图的正中央
    self.firstImageView.frame = CGRectMake(CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));

    //设置pageController(这里可以根据个人喜好自定义)
    UIPageControl *pageController = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 20)];
    
    pageController.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) - 20);
    
    //设置pageController 的页数
    pageController.numberOfPages = self.imageDataSource.count;

    pageController.currentPage = 0;
    [self addSubview:pageController];
    self.pageController = pageController;
}

//添加将要出现的视图
- (void)addImageViewWith:(float)offsetX
{
    //添加将要出现的视图的中心点X坐标
    static float nextImageViewCenterX = 0.f;
    
    //判断滚动方向
    if (offsetX < CGRectGetWidth(self.frame)) {
        //从左往右
        nextImageViewCenterX = (CGRectGetWidth(self.frame)  + offsetX) / 2;
        _nextImageIndex = _currentImageIndex - 1;
    }
    else if (offsetX > CGRectGetWidth(self.frame)){
        //从右往左
        nextImageViewCenterX = (CGRectGetWidth(self.frame) * 3 + offsetX) / 2;
        _nextImageIndex = _currentImageIndex + 1;
    }else{
        nextImageViewCenterX = CGRectGetWidth(self.frame) / 2;
    }
    
    //这块是完成轮播的关键(比如有四张图片:一二三四,轮播的排列是这样的:四一二三四一)
        if (_nextImageIndex == -1) {
            _nextImageIndex = (int)self.imageDataSource.count - 1;
        }else if (_nextImageIndex == self.imageDataSource.count){
            _nextImageIndex = 0;
        }
    //添加将要出现的图片
    [self addNextImageWith:self.secondImageView];
    //设置将要出现图片的中心点
    CGPoint center = CGPointMake(nextImageViewCenterX , CGRectGetHeight(self.frame)/2);
    self.secondImageView.center = center ;
}

# pragma mark - 点击的block -
- (void)tapClick:(UITapGestureRecognizer *)tap{
    !self.currentImageClickBlock ? : self.currentImageClickBlock(_currentImageIndex + 1);
}


//视图持续滚动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self addImageViewWith:scrollView.contentOffset.x];
}

// 减速完成(分页滑动是会减速的)
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self endRollScrollViewWith:scrollView];
}
// 滑动动画结束 setContentOffset: animated:YES 动画结束调用
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self endRollScrollViewWith:scrollView];
}
//结束滚动后,重置页面
-(void)endRollScrollViewWith:(UIScrollView *)scrollView
{
    //判断是否完成翻页
    if (scrollView.contentOffset.x != CGRectGetWidth(self.frame)) {
        //更新当前图片下标
        _currentImageIndex = _nextImageIndex;
        //给第一张相框添加图片
        [self addNextImageWith:self.firstImageView];
        //让视图瞬间回到中间位置
        [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame), 0)];
        self.pageController.currentPage = _currentImageIndex;
    }
}

//给第一个相框/第二个相框添加图片
- (void)addNextImageWith:(UIImageView *)imageView;
{
    if (_isLocalImagesArray) {
        //添加将要出现视图的本地图片
        imageView.image = self.imageDataSource[_nextImageIndex];
    }else{
        //添加将要出现视图的网络图片
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.imageDataSource[_nextImageIndex]]];
    }
}

//添加一个时间控制器
- (void)addTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(rollImages) userInfo:nil repeats:YES];
    self.timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)rollImages
{
    if (self.imageDataSource.count == 0) {
        return;
    }
    
    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame) * 2, 0) animated:YES];
    
}

//清除时间控制器
- (void)clearTimer
{
    [_timer invalidate];
    _timer = nil;
}

//手动拖动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //开始拖动的时候,清除时间控制器
    [self clearTimer];
}
//结束拖动的时候,新增时间控制器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addTimer];
}


@end
