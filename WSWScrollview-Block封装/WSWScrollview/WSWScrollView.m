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
//第三个图片
@property (nonatomic, strong) UIImageView    *thirdImageView;
//图片的数据源
@property (nonatomic, strong) NSMutableArray *imageDataSource;
//页面控制器
@property (nonatomic, strong) UIPageControl  *pageController;
//第三种模式,每张图片的frame
@property (nonatomic, assign) CGRect         centerItemFrame;
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


-(instancetype)initWithFrame:(CGRect)frame andScrollViewMode:(ScrollViewMode)scrollViewMode
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollViewMode = scrollViewMode;
        [self initView];
    }
    return self;
}
//提供数据源
- (void)addImagesArray:(NSArray *)imagesArray centerItemFrame:(CGRect)centerItemFrame currentImageClick:(CurrentImageClick)currentImageClickBlock
{
    self.currentImageClickBlock = currentImageClickBlock;
    _isLocalImagesArray = NO;
    
    //设置默认值,防止代理协议中没有设置每张图片的大小(确保设置了,可以删除下一行代码)
    self.centerItemFrame = CGRectMake(50, 100, self.frame.size.width - 100, 200);
    self.centerItemFrame = centerItemFrame;
    
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
    
    //设置pageController 的页数
    self.pageController.numberOfPages = self.imageDataSource.count;

    //添加时间控制器
    [self addTimer];

    if (self.scrollViewMode != ScrollWithThreePages) {
        [self addNextImageWith:self.firstImageView WithImageIndex:_currentImageIndex];
    }else{
        [self addNextImageWith:self.firstImageView WithImageIndex:self.imageDataSource.count -1];
        [self addNextImageWith:self.secondImageView WithImageIndex:_currentImageIndex];
        [self addNextImageWith:self.thirdImageView WithImageIndex:_currentImageIndex + 1];
    }
    
    if (self.scrollViewMode == ScrollWithThreePages) {
        //重新布局第三种
        [self initSubviews];
    }
}


//初始化视图
- (void)initView
{
    //初始化当前图片(默认下标为0);
    _currentImageIndex = 0;
    //初始化timer间隔时间(默认3.0s)
    _timeInterval = 3.0;
    
    //添加滚动视图
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.clipsToBounds  = NO;

    //添加点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [scrollView addGestureRecognizer:tap];
    //添加到父视图上
    [self addSubview:scrollView];
    self.scrollView = scrollView;

    //给滚动视图添加两个UIImageView
    UIImageView *firstImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.firstImageView = firstImageView;
    
    UIImageView *secondImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.secondImageView = secondImageView;

    [self.scrollView addSubview:secondImageView];
    [self.scrollView addSubview:firstImageView];
    
    if (self.scrollViewMode != ScrollWithThreePages) {

        //默认和视差,用一样的双UIImageView就可以搞定
        scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.frame), 0);
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * 3, CGRectGetHeight(self.frame));
        
        //    先设置第一张图片的位置,在滚动视图的正中央
        self.firstImageView.frame = CGRectMake(CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }else{
        //第三种模式,需要3个UIImageView(最优)
        UIImageView *thirdImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.thirdImageView = thirdImageView;
        [self.scrollView addSubview:thirdImageView];
    }

    //设置pageController(这里可以根据个人喜好自定义)
    UIPageControl *pageController = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 20)];
    pageController.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) - 20);
    //设置pageController 的页数
    pageController.numberOfPages = self.imageDataSource.count;
    pageController.currentPage = 0;
    [self addSubview:pageController];
    self.pageController = pageController;
}

//添加将要出现的视图(默认模式&&视差模式)
- (void)ScrollWithParallaxAddImageViewWith:(float)offsetX
{
    //添加将要出现的视图的中心点X坐标
    static float nextImageViewCenterX = 0.f;
    //判断滚动方向
    if (offsetX < CGRectGetWidth(self.frame)) {
        //从左往右
        if (self.scrollViewMode == ScrollWithDefault) {
            nextImageViewCenterX = CGRectGetWidth(self.frame)/ 2;
        }else{
            nextImageViewCenterX = (CGRectGetWidth(self.frame)  + offsetX) / 2;
        }
        _nextImageIndex = _currentImageIndex - 1;
    }
    else if (offsetX > CGRectGetWidth(self.frame)){
        //从右往左
        if (self.scrollViewMode ==ScrollWithDefault) {
            nextImageViewCenterX = CGRectGetWidth(self.frame) * 2.5f;
        }else{
            nextImageViewCenterX = (CGRectGetWidth(self.frame) * 3 + offsetX) / 2;
        }
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
    [self addNextImageWith:self.secondImageView WithImageIndex:_nextImageIndex];
    //设置将要出现图片的中心点
    CGPoint center = CGPointMake(nextImageViewCenterX , CGRectGetHeight(self.frame)/2);
    self.secondImageView.center = center ;
}
//第三种模式
- (void)ScrollWithThreePagesAddImageViewWith:(float)offsetX
{
    //添加将要出现的视图的中心点X坐标
    static float nextImageViewCenterX = 0.f;
    //判断滚动方向
    if (offsetX < CGRectGetWidth(self.centerItemFrame) * 2) {
        //从左往右
        
        if ((CGRectGetWidth(self.centerItemFrame) * 2 - offsetX) > (([UIScreen mainScreen].bounds.size.width - CGRectGetWidth(self.centerItemFrame)) / 2)) {
            
            nextImageViewCenterX = CGRectGetWidth(self.centerItemFrame)/ 2;
            _nextImageIndex = _currentImageIndex - 2;
        }else{
            nextImageViewCenterX = CGRectGetWidth(self.centerItemFrame) * 3.5f;
            _nextImageIndex = _currentImageIndex + 1;
        }
        
        //这块是完成轮播的关键(比如有四张图片:一二三四,轮播的排列是这样的:四一二三四一)
        if (_nextImageIndex == -1) {
            _nextImageIndex = (int)self.imageDataSource.count - 1;
        }else if (_nextImageIndex == self.imageDataSource.count){
            _nextImageIndex = 0;
        }else if (_nextImageIndex == -2){
            _nextImageIndex = (int)self.imageDataSource.count - 2;

        }
        
        [self addNextImageWith:self.thirdImageView WithImageIndex:_nextImageIndex];
        //设置将要出现图片的中心点
        CGPoint center = CGPointMake(nextImageViewCenterX , CGRectGetHeight(self.centerItemFrame)/2);
        self.thirdImageView.center = center ;
    }
    else if (offsetX > CGRectGetWidth(self.centerItemFrame) * 2){
        //从右往左

        if (offsetX - (CGRectGetWidth(self.centerItemFrame) * 2) > (([UIScreen mainScreen].bounds.size.width - CGRectGetWidth(self.centerItemFrame)) / 2)) {
            
            nextImageViewCenterX = CGRectGetWidth(self.centerItemFrame) * 4.5f;
            _nextImageIndex = _currentImageIndex + 2;
        }else{
            nextImageViewCenterX = CGRectGetWidth(self.centerItemFrame) * 1.5f;
            _nextImageIndex = _currentImageIndex - 1;
        }
        
        //这块是完成轮播的关键(比如有四张图片:一二三四,轮播的排列是这样的:四一二三四一)
        if (_nextImageIndex == -1) {
            _nextImageIndex = (int)self.imageDataSource.count - 1;
        }else if (_nextImageIndex == self.imageDataSource.count){
            _nextImageIndex = 0;
        }else if (_nextImageIndex == self.imageDataSource.count + 1){
            _nextImageIndex = 1;
        }
        [self addNextImageWith:self.firstImageView WithImageIndex:_nextImageIndex];
        //设置将要出现图片的中心点
        CGPoint center = CGPointMake(nextImageViewCenterX , CGRectGetHeight(self.centerItemFrame)/2);
        self.firstImageView.center = center ;
        
    }else{
//        nextImageViewCenterX = CGRectGetWidth(self.frame) / 2;
    }
    
}

# pragma mark - 点击的代理 -
- (void)tapClick:(UITapGestureRecognizer *)tap{
    !self.currentImageClickBlock ? : self.currentImageClickBlock(_currentImageIndex + 1);
}


//视图持续滚动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    switch (self.scrollViewMode) {
        case ScrollWithDefault:
        case ScrollWithParallax:
        {
            //默认模式和视差模式,用同一个方法
            [self ScrollWithParallaxAddImageViewWith:scrollView.contentOffset.x];
            break;
        }
        case ScrollWithThreePages:
        {
            [self ScrollWithThreePagesAddImageViewWith:scrollView.contentOffset.x];

            break;
        }
        default:
            break;
    }
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
    if (self.scrollViewMode != ScrollWithThreePages) {
        if (scrollView.contentOffset.x != CGRectGetWidth(self.frame)) {
            //更新当前图片下标
            _currentImageIndex = _nextImageIndex;
            //给第一张相框添加图片
            [self addNextImageWith:self.firstImageView WithImageIndex:_nextImageIndex];
            //让视图瞬间回到中间位置
            [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame), 0)];
            self.pageController.currentPage = _currentImageIndex;
        }
    }else{
        if (scrollView.contentOffset.x > CGRectGetWidth(self.centerItemFrame) * 2) {
            //更新当前图片下标
            
            _currentImageIndex++;
            if (_currentImageIndex == self.imageDataSource.count) {
                _currentImageIndex = 0;
            }
        }else if (scrollView.contentOffset.x < CGRectGetWidth(self.centerItemFrame) * 2){
            _currentImageIndex--;
            if (_currentImageIndex == -1) {
                _currentImageIndex = (int)self.imageDataSource.count - 1;
            }
        }
        //让三张图片归位
        [self resetFrameWithImageIndex:_currentImageIndex];
        [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.centerItemFrame) * 2, 0)];
        self.pageController.currentPage = _currentImageIndex;
    }
    
}

- (void)resetFrameWithImageIndex:(NSInteger)imageIndex
{
    //设置三个视图的初始位置
    [self scrollViewWithThreePagesRetFrame];
    [self addNextImageWith:self.secondImageView WithImageIndex:imageIndex];
    NSInteger firstImageIndex = imageIndex - 1;
    if (firstImageIndex == -1) {
        firstImageIndex = (int)self.imageDataSource.count - 1;
    }
    [self addNextImageWith:self.firstImageView WithImageIndex:firstImageIndex];
    NSInteger thirdImageIndex = imageIndex + 1;
    if (thirdImageIndex == self.imageDataSource.count){
        thirdImageIndex = 0;
    }
    [self addNextImageWith:self.thirdImageView WithImageIndex:thirdImageIndex];
    
}


//给第一个相框/第二个相框添加图片
- (void)addNextImageWith:(UIImageView *)imageView WithImageIndex:(NSInteger)imageIndex;
{
    if (_isLocalImagesArray) {
        //添加将要出现视图的本地图片
        imageView.image = self.imageDataSource[imageIndex];
    }else{
        //添加将要出现视图的网络图片
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.imageDataSource[imageIndex]]];
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
    if (self.scrollViewMode != ScrollWithThreePages) {
        [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame) * 2, 0) animated:YES];
    }else{
        [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.centerItemFrame) * 3, 0) animated:YES];
    }
    
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


-(void) initSubviews
{
    _scrollView.frame = self.centerItemFrame;
    _scrollView.center = CGPointMake(self.frame.size.width/2 , _scrollView.center.y);
    //如果是第三种模式,那就要一下子创建五个UIImageView,并让滚动视图置中
    _scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.centerItemFrame)*2, 0);
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.centerItemFrame) * 5, CGRectGetHeight(self.centerItemFrame));

    //设置三个视图的初始位置
    [self scrollViewWithThreePagesRetFrame];
}
//模式三,让三个视图归位
- (void)scrollViewWithThreePagesRetFrame
{
    self.firstImageView.frame = CGRectMake(CGRectGetWidth(self.centerItemFrame), 0,CGRectGetWidth(self.centerItemFrame), CGRectGetHeight(self.centerItemFrame));
    self.secondImageView.frame = CGRectMake(CGRectGetWidth(self.centerItemFrame) * 2, 0,CGRectGetWidth(self.centerItemFrame), CGRectGetHeight(self.centerItemFrame));
    self.thirdImageView.frame = CGRectMake(CGRectGetWidth(self.centerItemFrame) * 3, 0,CGRectGetWidth(self.centerItemFrame), CGRectGetHeight(self.centerItemFrame));
}

//点击左右两张图片.等同于操作中间图片
-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self)
    {
        return self.scrollView;
    }
    else
    {
        return hitView;
    }
}


@end
