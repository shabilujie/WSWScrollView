//
//  ViewController.m
//  WSWScrollview
//
//  Created by shengwei on 16/3/7.
//  Copyright © 2016年 laolai. All rights reserved.
//

#import "ViewController.h"
#import "WSWScrollView.h"



@interface ViewController ()<WSWScrollViewDelegate,WSWScrollViewDataSource>
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    //调用方法-->就是直接创建一个对象,
    WSWScrollView *scrollView = [[WSWScrollView alloc] initWithFrame:CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width , 200) andScrollViewMode:3];
    /*
     时间间隔一定要写在.datasource = self之前,因为.dataSource调用了创建时间控制器,
     之后再设置间隔时间的话,就没有作用了
     */
//    scrollView.timeInterval = 1.f;
    //给自己上两个代理
    scrollView.dataSource = self;
    scrollView.delegate = self;
    //添加带父视图上
    [self.view addSubview:scrollView];
    

}

#pragma mark - WSWScrollViewDataSource -
//实现协议,这个是必须的,就是传递一个图片数组,本地的就直接上传文件字符串名,网络就穿字符串链接地址.
- (NSArray *)imagesArrayForWSWScrollView:(WSWScrollView *)scrollView
{
//#if   1是网络图片,0是本地图片(你可以手动更改试一试);
#if 1
    
    NSArray *array = @[
                       @"http://image.wisewanzhi.com/474c907f303cc954485f3528406dd826@4e_0o_0l_1216h_828w_90q.jpg",
                       @"http://image.wisewanzhi.com/5ab274f45ef761d533f07d6c89189477@4e_0o_0l_1216h_828w_90q.jpg",
                       @"http://image.wisewanzhi.com/e7c77dbc518f96315f24f1b6e3d064e2@4e_0o_0l_1216h_828w_90q.jpg",
                       @"http://image.wisewanzhi.com/9f641db222dfbec094013c2da03ef9a8@4e_0o_0l_1216h_828w_90q.jpg"
                       ];
    
#else
    NSArray *array = @[
                       @"火影01",
                       @"火影02",
                       @"火影03",
                       @"火影04",
                       ];
#endif
    return array;
}


-(CGRect)scrollViewWithThreePagesCenterItemFrameForWSWScrollView:(WSWScrollView *)scrollView
{
    CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 100, 200);
    return rect;
}


#pragma mark - WSWScrollViewDelegate -
//点击的代理,点后返回图片的位置,然后你就可以随便操作了
- (void)wswScroView:(WSWScrollView *)scrollView didSelectRowAtIndexPath:(NSInteger)index
{
    NSLog(@"--->我点的这是第%ld张图片",(long)index);
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
